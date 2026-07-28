#include "IECSimulationDataGenerator.h"
#include "IECAnalyzerSettings.h"
#include <AnalyzerHelpers.h>
#include <string>

// Bus levels are wired-OR active-low: released = HIGH, asserted = LOW.
// The simulation drives the actual bus wire (non-inverted), so it should be
// decoded with "Signals inverted" left unchecked. It models the byte handshake
// and EOI timing, but not the electrical turnaround (which device owns CLK).

// Rough timings, in microseconds. The decoder is timing-independent (it follows
// the handshake, not the clock rate), so these only need to look plausible.
static const double kRestUs = 20.0;     // both lines low before a byte
static const double kRtsUs = 20.0;      // after talker releases CLK
static const double kRfdUs = 20.0;      // after listener releases DATA
static const double kSetupUs = 20.0;    // CLK low, talker placing the bit
static const double kHoldUs = 10.0;     // extra settle after DATA is set
static const double kValidUs = 40.0;    // CLK high, bit sampled on the rising edge
static const double kAckUs = 40.0;      // listener holds DATA low to acknowledge
static const double kEoiPauseUs = 300.0; // talker stalls CLK-high to flag EOI
static const double kEoiBlipUs = 60.0;   // listener's DATA-low EOI acknowledge

IECSimulationDataGenerator::IECSimulationDataGenerator()
    : mSettings( nullptr ), mSimulationSampleRateHz( 0 ), mAtn( nullptr ), mClk( nullptr ), mData( nullptr )
{
}

IECSimulationDataGenerator::~IECSimulationDataGenerator()
{
}

void IECSimulationDataGenerator::Initialize( U32 simulation_sample_rate, IECAnalyzerSettings* settings )
{
    mSimulationSampleRateHz = simulation_sample_rate;
    mSettings = settings;

    // All three lines idle HIGH (released).
    mAtn = mGroup.Add( mSettings->mAtnChannel, mSimulationSampleRateHz, BIT_HIGH );
    mClk = mGroup.Add( mSettings->mClkChannel, mSimulationSampleRateHz, BIT_HIGH );
    mData = mGroup.Add( mSettings->mDataChannel, mSimulationSampleRateHz, BIT_HIGH );

    // A little idle lead-in.
    mGroup.AdvanceAll( Us( 200.0 ) );
}

U32 IECSimulationDataGenerator::Us( double microseconds )
{
    double samples = microseconds * 1e-6 * (double)mSimulationSampleRateHz;
    if( samples < 1.0 )
        samples = 1.0;
    return (U32)samples;
}

void IECSimulationDataGenerator::SetAtnAsserted( bool asserted )
{
    // Asserted = LOW on the wire.
    mAtn->TransitionIfNeeded( asserted ? BIT_LOW : BIT_HIGH );
}

void IECSimulationDataGenerator::SendByte( U8 byte, bool atn_asserted, bool eoi )
{
    SetAtnAsserted( atn_asserted );

    // REST: both CLK and DATA pulled low before the byte.
    mData->TransitionIfNeeded( BIT_LOW );
    mClk->TransitionIfNeeded( BIT_LOW );
    mGroup.AdvanceAll( Us( kRestUs ) );

    // RTS: talker releases CLK (CLK -> HIGH).
    mClk->TransitionIfNeeded( BIT_HIGH );
    mGroup.AdvanceAll( Us( kRtsUs ) );

    // RFD: listener releases DATA while CLK is HIGH. This DATA rising edge is the
    // start-of-byte marker the decoder keys on.
    mData->TransitionIfNeeded( BIT_HIGH );
    mGroup.AdvanceAll( Us( kRfdUs ) );

    if( eoi )
    {
        // Talker stalls with CLK released; the listener times out and blips DATA
        // low, then releases it again - the EOI acknowledge.
        mGroup.AdvanceAll( Us( kEoiPauseUs ) );
        mData->TransitionIfNeeded( BIT_LOW );
        mGroup.AdvanceAll( Us( kEoiBlipUs ) );
        mData->TransitionIfNeeded( BIT_HIGH );
        mGroup.AdvanceAll( Us( kRfdUs ) );
    }

    // 8 data bits, LSB first. The talker sets the bit while CLK is low, then
    // releases CLK; that rising edge is the sample point.
    for( int i = 0; i < 8; i++ )
    {
        bool bit_one = ( ( byte >> i ) & 0x01 ) != 0;

        mClk->TransitionIfNeeded( BIT_LOW );
        mGroup.AdvanceAll( Us( kSetupUs ) );
        mData->TransitionIfNeeded( bit_one ? BIT_HIGH : BIT_LOW ); // 1 = released HIGH
        mGroup.AdvanceAll( Us( kHoldUs ) );
        mClk->TransitionIfNeeded( BIT_HIGH );
        mGroup.AdvanceAll( Us( kValidUs ) );
    }

    // ACK: listener pulls DATA low to acknowledge the byte. The next byte starts
    // from REST (CLK pulled low again at the top of SendByte).
    mData->TransitionIfNeeded( BIT_LOW );
    mGroup.AdvanceAll( Us( kAckUs ) );
}

void IECSimulationDataGenerator::SendTransaction()
{
    // A simplified "read file ABC from device 8, channel 0" exchange, modeled on
    // the worked example in the protocol guide. Command bytes go under ATN.

    // Phase 1 - OPEN
    SendByte( 0x28, true, false );  // LISTEN device 8
    SendByte( 0xF0, true, false );  // OPEN, channel 0
    const char* name = "0:ABC";     // (shortened filename)
    for( const char* p = name; *p; ++p )
    {
        bool last = ( *( p + 1 ) == 0 );
        SendByte( (U8)*p, false, last ); // data; EOI on the final character
    }
    SendByte( 0x3F, true, false ); // UNLISTEN

    // Idle between phases.
    mGroup.AdvanceAll( Us( 300.0 ) );

    // Phase 2 - TALK + (turnaround not modeled) + data
    SendByte( 0x48, true, false ); // TALK device 8
    SendByte( 0x60, true, false ); // DATA secondary, channel 0
    const char* content = "ABC";
    for( const char* p = content; *p; ++p )
    {
        bool last = ( *( p + 1 ) == 0 );
        SendByte( (U8)*p, false, last ); // data; 'C' carries EOI
    }
    SendByte( 0x5F, true, false ); // UNTALK

    mGroup.AdvanceAll( Us( 300.0 ) );

    // Phase 3 - CLOSE
    SendByte( 0x28, true, false ); // LISTEN device 8
    SendByte( 0xE0, true, false ); // CLOSE, channel 0
    SendByte( 0x3F, true, false ); // UNLISTEN

    // Longer idle so successive transactions are visually separated.
    SetAtnAsserted( false );
    mGroup.AdvanceAll( Us( 1500.0 ) );
}

U32 IECSimulationDataGenerator::GenerateSimulationData( U64 newest_sample_requested, U32 sample_rate,
                                                        SimulationChannelDescriptor** simulation_channel )
{
    U64 adjusted_largest_sample_requested =
        AnalyzerHelpers::AdjustSimulationTargetSample( newest_sample_requested, sample_rate, mSimulationSampleRateHz );

    while( mClk->GetCurrentSampleNumber() < adjusted_largest_sample_requested )
    {
        SendTransaction();
    }

    *simulation_channel = mGroup.GetArray();
    return mGroup.GetCount();
}
