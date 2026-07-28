#include "IECAnalyzerResults.h"
#include <AnalyzerHelpers.h>
#include "IECAnalyzer.h"
#include "IECAnalyzerSettings.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdio>

IECAnalyzerResults::IECAnalyzerResults( IECAnalyzer* analyzer, IECAnalyzerSettings* settings )
    : AnalyzerResults(), mAnalyzer( analyzer ), mSettings( settings )
{
}

IECAnalyzerResults::~IECAnalyzerResults()
{
}

static const char* FrameTypeName( U8 type )
{
    switch( type )
    {
    case IEC_LISTEN:
        return "LISTEN";
    case IEC_UNLISTEN:
        return "UNLISTEN";
    case IEC_TALK:
        return "TALK";
    case IEC_UNTALK:
        return "UNTALK";
    case IEC_SEC_OPEN:
        return "OPEN";
    case IEC_SEC_CLOSE:
        return "CLOSE";
    case IEC_SEC_DATA:
        return "DATA-CH";
    case IEC_CMD_OTHER:
        return "CMD";
    case IEC_DATA:
    default:
        return "DATA";
    }
}

void IECAnalyzerResults::BuildStrings( const Frame& frame, DisplayBase display_base, std::string& long_str, std::string& mid_str,
                                       std::string& short_str )
{
    U8 byte = (U8)frame.mData1;
    bool eoi = ( frame.mData2 & IEC_FLAG_EOI ) != 0;
    bool partial = ( frame.mData2 & IEC_FLAG_PARTIAL ) != 0;

    char num_str[ 32 ];
    AnalyzerHelpers::GetNumberString( byte, display_base, 8, num_str, sizeof( num_str ) );

    std::ostringstream lo, mi, sh;

    if( ( frame.mData2 & IEC_FLAG_COMMAND ) != 0 )
    {
        // Command byte (sent under ATN).
        const char* name = FrameTypeName( frame.mType );
        switch( frame.mType )
        {
        case IEC_LISTEN:
        {
            int dev = byte - 0x20;
            lo << "LISTEN device " << dev << " [" << num_str << "]";
            mi << "LISTEN " << dev;
            sh << "L" << dev;
            break;
        }
        case IEC_TALK:
        {
            int dev = byte - 0x40;
            lo << "TALK device " << dev << " [" << num_str << "]";
            mi << "TALK " << dev;
            sh << "T" << dev;
            break;
        }
        case IEC_UNLISTEN:
            lo << "UNLISTEN [" << num_str << "]";
            mi << "UNLISTEN";
            sh << "UNL";
            break;
        case IEC_UNTALK:
            lo << "UNTALK [" << num_str << "]";
            mi << "UNTALK";
            sh << "UNT";
            break;
        case IEC_SEC_OPEN:
        {
            int ch = byte - 0xF0;
            lo << "OPEN channel " << ch << " [" << num_str << "]";
            mi << "OPEN ch" << ch;
            sh << "O" << ch;
            break;
        }
        case IEC_SEC_CLOSE:
        {
            int ch = byte - 0xE0;
            lo << "CLOSE channel " << ch << " [" << num_str << "]";
            mi << "CLOSE ch" << ch;
            sh << "C" << ch;
            break;
        }
        case IEC_SEC_DATA:
        {
            int ch = byte - 0x60;
            lo << "DATA channel " << ch << " [" << num_str << "]";
            mi << "DATA ch" << ch;
            sh << "D" << ch;
            break;
        }
        default:
            lo << "Command " << num_str;
            mi << "CMD " << num_str;
            sh << num_str;
            break;
        }
        (void)name;
    }
    else
    {
        // Data byte. Show value plus a printable character if applicable.
        lo << num_str;
        if( byte >= 0x20 && byte <= 0x7E )
        {
            lo << " '" << (char)byte << "'";
        }
        mi << num_str;
        sh << num_str;
    }

    if( eoi )
    {
        lo << "  (EOI)";
        mi << " EOI";
    }
    if( partial )
    {
        lo << "  !partial";
        mi << " !";
        sh << "!";
    }

    long_str = lo.str();
    mid_str = mi.str();
    short_str = sh.str();
}

void IECAnalyzerResults::GenerateBubbleText( U64 frame_index, Channel& channel, DisplayBase display_base )
{
    ClearResultStrings();
    Frame frame = GetFrame( frame_index );

    std::string long_str, mid_str, short_str;
    BuildStrings( frame, display_base, long_str, mid_str, short_str );

    // Logic shows whichever string fits the available width; provide several.
    AddResultString( short_str.c_str() );
    AddResultString( mid_str.c_str() );
    AddResultString( long_str.c_str() );
}

void IECAnalyzerResults::GenerateFrameTabularText( U64 frame_index, DisplayBase display_base )
{
#ifdef SUPPORTS_PROTOCOL_SEARCH
    Frame frame = GetFrame( frame_index );
    ClearTabularText();

    std::string long_str, mid_str, short_str;
    BuildStrings( frame, display_base, long_str, mid_str, short_str );
    AddTabularText( long_str.c_str() );
#endif
}

void IECAnalyzerResults::GenerateExportFile( const char* file, DisplayBase display_base, U32 export_type_user_id )
{
    std::ofstream file_stream( file, std::ios::out );

    U64 trigger_sample = mAnalyzer->GetTriggerSample();
    U32 sample_rate = mAnalyzer->GetSampleRate();

    file_stream << "Time [s],Phase,Type,Value,ASCII,EOI" << std::endl;

    U64 num_frames = GetNumFrames();
    for( U64 i = 0; i < num_frames; i++ )
    {
        Frame frame = GetFrame( i );

        char time_str[ 128 ];
        AnalyzerHelpers::GetTimeString( frame.mStartingSampleInclusive, trigger_sample, sample_rate, time_str, sizeof( time_str ) );

        char value_str[ 32 ];
        AnalyzerHelpers::GetNumberString( frame.mData1, display_base, 8, value_str, sizeof( value_str ) );

        bool is_cmd = ( frame.mData2 & IEC_FLAG_COMMAND ) != 0;
        bool eoi = ( frame.mData2 & IEC_FLAG_EOI ) != 0;

        U8 byte = (U8)frame.mData1;
        char ascii[ 8 ] = "";
        if( !is_cmd && byte >= 0x20 && byte <= 0x7E )
            std::snprintf( ascii, sizeof( ascii ), "%c", (char)byte );

        file_stream << time_str << "," << ( is_cmd ? "ATN" : "DATA" ) << "," << FrameTypeName( frame.mType ) << "," << value_str << ","
                    << ascii << "," << ( eoi ? "1" : "0" ) << std::endl;

        if( UpdateExportProgressAndCheckForCancel( i, num_frames ) == true )
        {
            file_stream.close();
            return;
        }
    }

    file_stream.close();
}

void IECAnalyzerResults::GeneratePacketTabularText( U64 /*packet_id*/, DisplayBase /*display_base*/ )
{
    // not supported
}

void IECAnalyzerResults::GenerateTransactionTabularText( U64 /*transaction_id*/, DisplayBase /*display_base*/ )
{
    // not supported
}
