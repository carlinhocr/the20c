#ifndef IEC_ANALYZER_SETTINGS
#define IEC_ANALYZER_SETTINGS

#include <AnalyzerSettings.h>
#include <AnalyzerTypes.h>

// Settings for the Commodore IEC serial bus analyzer.
//
// The IEC bus carries the whole protocol on three active-low, open-collector
// lines: ATN, CLK and DATA. This analyzer needs all three.
class IECAnalyzerSettings : public AnalyzerSettings
{
  public:
    IECAnalyzerSettings();
    virtual ~IECAnalyzerSettings();

    virtual bool SetSettingsFromInterfaces();
    void UpdateInterfacesFromSettings();
    virtual void LoadSettings( const char* settings );
    virtual const char* SaveSettings();

    // Channels
    Channel mAtnChannel;
    Channel mClkChannel;
    Channel mDataChannel;

    // Reserved / persisted for settings-format compatibility with earlier
    // builds. Framing is now fully automatic (see IECAnalyzer::WorkerThread),
    // so these absolute-microsecond values are no longer used by the decoder.
    U32 mEoiThresholdUs;
    U32 mByteGapUs;

    // If you probe the inverted (active-high) side of a transceiver or the VIA
    // port pins instead of the bus wire itself, enable this to flip every line.
    bool mInverted;

  protected:
    AnalyzerSettingInterfaceChannel mAtnChannelInterface;
    AnalyzerSettingInterfaceChannel mClkChannelInterface;
    AnalyzerSettingInterfaceChannel mDataChannelInterface;
    AnalyzerSettingInterfaceBool mInvertedInterface;
};

#endif // IEC_ANALYZER_SETTINGS
