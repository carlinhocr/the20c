#include "IECAnalyzer.h"
#include "IECAnalyzerSettings.h"
#include "IECDecodeCore.h"
#include <AnalyzerChannelData.h>
#include <vector>

IECAnalyzer::IECAnalyzer()
    : Analyzer2(),
      mSettings(),
      mAtn( nullptr ),
      mClk( nullptr ),
      mData( nullptr ),
      mSampleRateHz( 0 ),
      mSimulationInitialized( false )
{
    SetAnalyzerSettings( &mSettings );
    // Required for the FrameV2 objects built in EmitByte() to reach Logic 2's
    // data table, Terminal view and any HLAs. Without this call Logic 2 falls
    // back to the legacy Frame objects, which only render the timeline bubbles -
    // so the decoded payload never shows up as readable text.
    UseFrameV2();
}

IECAnalyzer::~IECAnalyzer()
{
    KillThread();
}

void IECAnalyzer::SetupResults()
{
    mResults.reset( new IECAnalyzerResults( this, &mSettings ) );
    SetAnalyzerResults( mResults.get() );
    // Byte bubbles render on the DATA row; bit markers land on CLK.
    mResults->AddChannelBubblesWillAppearOn( mSettings.mDataChannel );
}

BitState IECAnalyzer::WireLevel( AnalyzerChannelData* channel )
{
    BitState raw = channel->GetBitState();
    return mSettings.mInverted ? Invert( raw ) : raw;
}

void IECAnalyzer::EmitByte( U8 byte, bool atn_asserted, bool eoi, bool partial, U64 start_sample, U64 end_sample,
                            const std::vector<U64>& bit_samples )
{
    U8 type = IEC_DATA;
    if( atn_asserted )
    {
        if( byte >= 0x20 && byte <= 0x3E )
            type = IEC_LISTEN;
        else if( byte == 0x3F )
            type = IEC_UNLISTEN;
        else if( byte >= 0x40 && byte <= 0x5E )
            type = IEC_TALK;
        else if( byte == 0x5F )
            type = IEC_UNTALK;
        else if( byte >= 0x60 && byte <= 0x6F )
            type = IEC_SEC_DATA;
        else if( byte >= 0xE0 && byte <= 0xEF )
            type = IEC_SEC_CLOSE;
        else if( byte >= 0xF0 && byte <= 0xFF )
            type = IEC_SEC_OPEN;
        else
            type = IEC_CMD_OTHER;
    }

    Frame frame;
    frame.mData1 = byte;
    U64 flags = 0;
    if( atn_asserted )
        flags |= IEC_FLAG_COMMAND;
    if( eoi )
        flags |= IEC_FLAG_EOI;
    if( partial )
        flags |= IEC_FLAG_PARTIAL;
    frame.mData2 = flags;
    frame.mType = type;
    frame.mFlags = 0;
    if( partial )
        frame.mFlags |= DISPLAY_AS_WARNING_FLAG;
    frame.mStartingSampleInclusive = start_sample;
    frame.mEndingSampleInclusive = end_sample;
    mResults->AddFrame( frame );

    for( size_t k = 0; k < bit_samples.size(); k++ )
        mResults->AddMarker( bit_samples[ k ], AnalyzerResults::UpArrow, mSettings.mClkChannel );
    if( eoi )
        mResults->AddMarker( start_sample, AnalyzerResults::Start, mSettings.mDataChannel );

    // FrameV2 powers the Logic 2 data table and protocol search.
    FrameV2 v2;
    v2.AddByte( "value", byte );
    v2.AddBoolean( "eoi", eoi );
    v2.AddString( "phase", atn_asserted ? "command" : "data" );

    const char* type_str = "data";
    switch( type )
    {
    case IEC_LISTEN:
        type_str = "listen";
        v2.AddInteger( "device", byte - 0x20 );
        break;
    case IEC_TALK:
        type_str = "talk";
        v2.AddInteger( "device", byte - 0x40 );
        break;
    case IEC_UNLISTEN:
        type_str = "unlisten";
        break;
    case IEC_UNTALK:
        type_str = "untalk";
        break;
    case IEC_SEC_OPEN:
        type_str = "open";
        v2.AddInteger( "channel", byte - 0xF0 );
        break;
    case IEC_SEC_CLOSE:
        type_str = "close";
        v2.AddInteger( "channel", byte - 0xE0 );
        break;
    case IEC_SEC_DATA:
        type_str = "data_channel";
        v2.AddInteger( "channel", byte - 0x60 );
        break;
    case IEC_CMD_OTHER:
        type_str = "command";
        break;
    case IEC_DATA:
    default:
        type_str = "data";
        // Logic 2's Terminal view renders the bytes carried under the "data"
        // key of frames typed "data" (the same convention Async Serial uses).
        // Adding it here - and ONLY for data-phase bytes - means the terminal
        // shows the file payload as continuous text, e.g. the filename followed
        // by the file contents, instead of one bubble per byte. Command bytes
        // are deliberately left out so they don't pollute the text stream.
        v2.AddByte( "data", byte );
        if( byte >= 0x20 && byte <= 0x7E )
        {
            char c[ 2 ] = { (char)byte, 0 };
            v2.AddString( "ascii", c );
        }
        break;
    }
    mResults->AddFrameV2( v2, type_str, start_sample, end_sample );

    mResults->CommitResults();
    ReportProgress( end_sample );
}

void IECAnalyzer::WorkerThread()
{
    mSampleRateHz = GetSampleRate();
    mAtn = GetAnalyzerChannelData( mSettings.mAtnChannel );
    mClk = GetAnalyzerChannelData( mSettings.mClkChannel );
    mData = GetAnalyzerChannelData( mSettings.mDataChannel );

    // Framing is handshake-based and timing-independent: see IECDecodeCore.h.
    // The core calls back here once per decoded byte; EmitByte builds the frame,
    // markers and tabular/export rows.
    IECDecodeCore( mAtn, mClk, mData, mSettings.mInverted,
                   [ & ]( U8 byte, bool atn_asserted, bool eoi, U64 start_sample, U64 end_sample,
                          const std::vector<U64>& bit_samples ) {
                       EmitByte( byte, atn_asserted, eoi, false, start_sample, end_sample, bit_samples );
                       ReportProgress( end_sample );
                   } );
}

bool IECAnalyzer::NeedsRerun()
{
    return false;
}

U32 IECAnalyzer::GenerateSimulationData( U64 minimum_sample_index, U32 device_sample_rate,
                                         SimulationChannelDescriptor** simulation_channels )
{
    if( mSimulationInitialized == false )
    {
        mSimulationDataGenerator.Initialize( GetSimulationSampleRate(), &mSettings );
        mSimulationInitialized = true;
    }

    return mSimulationDataGenerator.GenerateSimulationData( minimum_sample_index, device_sample_rate, simulation_channels );
}

U32 IECAnalyzer::GetMinimumSampleRateHz()
{
    // The IEC bus is slow; 1 MS/s resolves every edge comfortably.
    return 1000000;
}

const char* IECAnalyzer::GetAnalyzerName() const
{
    return "Commodore IEC v5";
}

const char* GetAnalyzerName()
{
    return "Commodore IEC v5";
}

Analyzer* CreateAnalyzer()
{
    return new IECAnalyzer();
}

void DestroyAnalyzer( Analyzer* analyzer )
{
    delete analyzer;
}
