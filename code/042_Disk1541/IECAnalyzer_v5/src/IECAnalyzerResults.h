#ifndef IEC_ANALYZER_RESULTS
#define IEC_ANALYZER_RESULTS

#include <AnalyzerResults.h>

// Frame.mType values: the decoded role of the byte.
enum IECFrameType
{
    IEC_DATA = 0,    // ordinary data byte (ATN released)
    IEC_LISTEN,      // $20..$3E  LISTEN device
    IEC_UNLISTEN,    // $3F       UNLISTEN
    IEC_TALK,        // $40..$5E  TALK device
    IEC_UNTALK,      // $5F       UNTALK
    IEC_SEC_DATA,    // $60..$6F  secondary: DATA channel
    IEC_SEC_CLOSE,   // $E0..$EF  secondary: CLOSE channel
    IEC_SEC_OPEN,    // $F0..$FF  secondary: OPEN channel
    IEC_CMD_OTHER    // command byte under ATN that matched nothing above
};

// Frame.mData2 flag bits.
#define IEC_FLAG_COMMAND ( 1 << 0 ) // byte was sent while ATN was asserted
#define IEC_FLAG_EOI ( 1 << 1 )     // byte was preceded by the EOI pause (last byte)
#define IEC_FLAG_PARTIAL ( 1 << 2 ) // fewer than 8 bits were captured for this byte

class IECAnalyzer;
class IECAnalyzerSettings;

class IECAnalyzerResults : public AnalyzerResults
{
  public:
    IECAnalyzerResults( IECAnalyzer* analyzer, IECAnalyzerSettings* settings );
    virtual ~IECAnalyzerResults();

    virtual void GenerateBubbleText( U64 frame_index, Channel& channel, DisplayBase display_base );
    virtual void GenerateExportFile( const char* file, DisplayBase display_base, U32 export_type_user_id );

    virtual void GenerateFrameTabularText( U64 frame_index, DisplayBase display_base );
    virtual void GeneratePacketTabularText( U64 packet_id, DisplayBase display_base );
    virtual void GenerateTransactionTabularText( U64 transaction_id, DisplayBase display_base );

  protected: // functions
    // Builds a set of human-readable descriptions (longest first) for a frame.
    void BuildStrings( const Frame& frame, DisplayBase display_base, std::string& long_str, std::string& mid_str,
                       std::string& short_str );

  protected: // vars
    IECAnalyzer* mAnalyzer;
    IECAnalyzerSettings* mSettings;
};

#endif // IEC_ANALYZER_RESULTS
