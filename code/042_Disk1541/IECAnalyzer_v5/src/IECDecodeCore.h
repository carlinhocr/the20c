#ifndef IEC_DECODE_CORE_H
#define IEC_DECODE_CORE_H

#include <LogicPublicTypes.h>
#include <cstddef>
#include <vector>

// ---------------------------------------------------------------------------
// Handshake-based IEC byte framing, by CLK-window classification.
//
// Framing follows the protocol handshake, not timing: this driver clocks bytes
// back-to-back (inter-byte gap == inter-bit gap), so no timing-gap method can
// work. Per byte, the talker drives CLK and the listener owns DATA; on the bus
// wire (active-low: released = HIGH, asserted = LOW):
//
//   RTS   talker releases CLK  -> CLK rises, DATA still held LOW
//   RFD   listener releases DATA -> DATA rises *while CLK is HIGH*
//   8x bit  talker sets DATA while CLK is LOW, then releases CLK; each CLK
//           rising edge samples one bit (LSB first, wire HIGH = bit 1)
//   ACK   listener pulls DATA LOW
//
// METHOD: look at every "CLK-high window" - the span from a CLK rising edge to
// the following CLK falling edge - and classify it by whether DATA moves inside
// it:
//
//   * DATA transitions during the window  -> HANDSHAKE window (the RTS/RFD
//     ready phase, since the listener releases DATA while CLK is high).
//   * DATA is steady during the window    -> BIT window; the bit value is the
//     DATA level (wire HIGH = 1).
//
// A byte is then simply: a handshake window followed by 8 consecutive bit
// windows. Each new handshake window re-arms and discards any partial bit
// group, so the decoder is self-synchronising - it cannot drift, and it needs
// no assumption about how many CLK edges a byte occupies.
//
// WHY RE-ARMING MATTERS: when the bus goes idle, CLK is left released (HIGH)
// for a long time, so that final "window" can span seconds and will certainly
// contain DATA activity - it therefore looks like a handshake. The next window
// is the real RTS of the following byte, which is also a handshake and re-arms,
// discarding the stale one. An earlier version instead consumed a fixed 9 CLK
// edges per byte, so such a stale idle window made the FIRST byte of a
// transaction absorb the RTS edge as bit 0 and drop bit 7 ($28 read as $50).
//
// EOI ("last byte"): the listener answers the talker's stall by pulsing DATA
// LOW inside the ready phase, so the arming window holds extra DATA edges
// (rise, fall, rise) instead of just the single RFD rise. Only data-phase bytes
// (ATN released) can be EOI; command bytes never are.
//
// Transitions are read once into memory using only the basic channel calls
// (GetBitState / GetSampleNumber / AdvanceToNextEdge /
// DoMoreTransitionsExistInCurrentData); all framing is done on those lists, so
// behaviour is identical inside Logic 2 and in off-line tests.
// ---------------------------------------------------------------------------
template <class CH, class EMIT>
void IECDecodeCore( CH* atnCh, CH* clkCh, CH* dataCh, bool inverted, EMIT emit )
{
    struct Tr
    {
        U64 sample;
        bool high; // wire level, inversion already applied
    };

    auto readAll = [ & ]( CH* c, std::vector<Tr>& out ) {
        auto wire = [ & ]() -> bool {
            BitState b = c->GetBitState();
            bool h = ( b == BIT_HIGH );
            return inverted ? !h : h;
        };
        out.push_back( { c->GetSampleNumber(), wire() } ); // initial level
        while( c->DoMoreTransitionsExistInCurrentData() )
        {
            c->AdvanceToNextEdge();
            out.push_back( { c->GetSampleNumber(), wire() } );
        }
    };

    std::vector<Tr> clk, data, atn;
    readAll( clkCh, clk );
    readAll( dataCh, data );
    readAll( atnCh, atn );
    if( clk.size() < 2 || data.empty() || atn.empty() )
        return;

    auto levelAt = []( const std::vector<Tr>& v, U64 s ) -> bool {
        size_t lo = 0, hi = v.size();
        while( lo < hi )
        {
            size_t mid = ( lo + hi ) / 2;
            if( v[ mid ].sample <= s )
                lo = mid + 1;
            else
                hi = mid;
        }
        return lo == 0 ? v.front().high : v[ lo - 1 ].high;
    };

    // Index of the first DATA transition strictly after sample s.
    auto firstDataAfter = [ & ]( U64 s ) -> size_t {
        size_t lo = 0, hi = data.size();
        while( lo < hi )
        {
            size_t mid = ( lo + hi ) / 2;
            if( data[ mid ].sample <= s )
                lo = mid + 1;
            else
                hi = mid;
        }
        return lo;
    };

    U8 byte = 0;
    int nbits = 0;
    bool armed = false;
    bool eoiPending = false;
    bool atnAsserted = false;
    std::vector<U64> bitSamples;
    bitSamples.reserve( 8 );

    for( size_t i = 1; i < clk.size(); i++ )
    {
        if( !clk[ i ].high )
            continue; // want CLK rising edges only
        if( i + 1 >= clk.size() )
            break; // no closing fall: incomplete window at end of capture
        U64 rise = clk[ i ].sample;
        U64 fall = clk[ i + 1 ].sample;

        // Count DATA transitions strictly inside the CLK-high window. An edge
        // exactly at the CLK fall belongs to the next (bit-setup) phase.
        int edges = 0;
        for( size_t j = firstDataAfter( rise ); j < data.size() && data[ j ].sample < fall; j++ )
            edges++;

        if( edges > 0 )
        {
            // Handshake (ready) window: (re)arm and drop any partial byte.
            armed = true;
            nbits = 0;
            byte = 0;
            bitSamples.clear();
            eoiPending = ( edges >= 2 ); // RFD rise + listener's EOI blip
            continue;
        }

        if( !armed )
            continue; // bits before any handshake: not a framed byte

        if( levelAt( data, rise ) )
            byte |= ( 1 << nbits ); // wire HIGH = bit 1, LSB first
        if( nbits == 0 )
            atnAsserted = !levelAt( atn, rise ); // ATN LOW = asserted (command)
        bitSamples.push_back( rise );
        nbits++;

        if( nbits == 8 )
        {
            bool eoi = eoiPending && !atnAsserted;
            emit( byte, atnAsserted, eoi, bitSamples.front(), bitSamples.back(), bitSamples );
            armed = false;
            nbits = 0;
            byte = 0;
            bitSamples.clear();
        }
    }
}

#endif // IEC_DECODE_CORE_H
