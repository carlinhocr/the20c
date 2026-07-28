#include "IECAnalyzerSettings.h"
#include <AnalyzerHelpers.h>

IECAnalyzerSettings::IECAnalyzerSettings()
    : mAtnChannel( UNDEFINED_CHANNEL ),
      mClkChannel( UNDEFINED_CHANNEL ),
      mDataChannel( UNDEFINED_CHANNEL ),
      mEoiThresholdUs( 250 ),
      mByteGapUs( 90 ),
      mInverted( false )
{
    mAtnChannelInterface.SetTitleAndTooltip( "ATN", "Attention line. LOW = command phase, HIGH = data phase." );
    mAtnChannelInterface.SetChannel( mAtnChannel );

    mClkChannelInterface.SetTitleAndTooltip( "CLK", "Clock line, driven by the talker. DATA is sampled on each CLK rising edge." );
    mClkChannelInterface.SetChannel( mClkChannel );

    mDataChannelInterface.SetTitleAndTooltip( "DATA", "Data line. On the bus wire HIGH = bit 1, LOW = bit 0." );
    mDataChannelInterface.SetChannel( mDataChannel );

    mInvertedInterface.SetTitleAndTooltip( "Signals inverted",
                                           "Enable if you probe an inverting buffer or the VIA/CIA port pins instead of the bus wire." );
    mInvertedInterface.SetValue( mInverted );

    AddInterface( &mAtnChannelInterface );
    AddInterface( &mClkChannelInterface );
    AddInterface( &mDataChannelInterface );
    AddInterface( &mInvertedInterface );

    AddExportOption( 0, "Export as text/csv file" );
    AddExportExtension( 0, "text", "txt" );
    AddExportExtension( 0, "csv", "csv" );

    ClearChannels();
    AddChannel( mAtnChannel, "ATN", false );
    AddChannel( mClkChannel, "CLK", false );
    AddChannel( mDataChannel, "DATA", false );
}

IECAnalyzerSettings::~IECAnalyzerSettings()
{
}

bool IECAnalyzerSettings::SetSettingsFromInterfaces()
{
    Channel atn = mAtnChannelInterface.GetChannel();
    Channel clk = mClkChannelInterface.GetChannel();
    Channel data = mDataChannelInterface.GetChannel();

    if( atn == UNDEFINED_CHANNEL || clk == UNDEFINED_CHANNEL || data == UNDEFINED_CHANNEL )
    {
        SetErrorText( "Please select a channel for ATN, CLK and DATA." );
        return false;
    }

    if( atn == clk || atn == data || clk == data )
    {
        SetErrorText( "ATN, CLK and DATA must each be on a different channel." );
        return false;
    }

    mAtnChannel = atn;
    mClkChannel = clk;
    mDataChannel = data;
    mInverted = mInvertedInterface.GetValue();

    ClearChannels();
    AddChannel( mAtnChannel, "ATN", true );
    AddChannel( mClkChannel, "CLK", true );
    AddChannel( mDataChannel, "DATA", true );

    return true;
}

void IECAnalyzerSettings::UpdateInterfacesFromSettings()
{
    mAtnChannelInterface.SetChannel( mAtnChannel );
    mClkChannelInterface.SetChannel( mClkChannel );
    mDataChannelInterface.SetChannel( mDataChannel );
    mInvertedInterface.SetValue( mInverted );
}

void IECAnalyzerSettings::LoadSettings( const char* settings )
{
    SimpleArchive text_archive;
    text_archive.SetString( settings );

    text_archive >> mAtnChannel;
    text_archive >> mClkChannel;
    text_archive >> mDataChannel;
    text_archive >> mEoiThresholdUs;
    text_archive >> mByteGapUs;
    text_archive >> mInverted;

    ClearChannels();
    AddChannel( mAtnChannel, "ATN", true );
    AddChannel( mClkChannel, "CLK", true );
    AddChannel( mDataChannel, "DATA", true );

    UpdateInterfacesFromSettings();
}

const char* IECAnalyzerSettings::SaveSettings()
{
    SimpleArchive text_archive;

    text_archive << mAtnChannel;
    text_archive << mClkChannel;
    text_archive << mDataChannel;
    text_archive << mEoiThresholdUs;
    text_archive << mByteGapUs;
    text_archive << mInverted;

    return SetReturnString( text_archive.GetString() );
}
