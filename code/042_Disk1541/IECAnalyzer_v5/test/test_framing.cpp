// Synthetic framing regression tests for IECDecodeCore.
//
// The headline case is "idle window": when a transaction ends, the controller
// releases CLK before it releases DATA, so the final CLK-high window stays open
// for the whole idle period (seconds) and contains DATA activity. A decoder that
// treats "DATA rises before the next CLK fall" as a byte start will latch onto
// that stale window and then read the RTS edge of the NEXT transaction as bit 0,
// turning the first byte $28 (LISTEN device 8) into $50 (TALK device 16) while
// every following byte still decodes correctly.
//
// Build:
//   g++ -std=c++11 -I<AnalyzerSDK>/include test_framing.cpp -o tf && ./tf
#include "../src/IECDecodeCore.h"
#include <cstdio>
#include <string>
#include <vector>

namespace
{
struct Tr
{
    U64 s;
    int v;
};

// Minimal stand-in for AnalyzerChannelData: the core only needs these four.
struct Chan
{
    std::vector<Tr> T;
    size_t cur = 0;
    BitState GetBitState() const
    {
        return T[ cur ].v ? BIT_HIGH : BIT_LOW;
    }
    U64 GetSampleNumber() const
    {
        return T[ cur ].s;
    }
    void AdvanceToNextEdge()
    {
        if( cur + 1 < T.size() )
            cur++;
    }
    bool DoMoreTransitionsExistInCurrentData() const
    {
        return cur + 1 < T.size();
    }
};

// Emits the edge pattern the v19 6502 driver actually produces (times in ns).
struct Gen
{
    std::vector<Tr> A, C, D;
    int a = 1, c = 1, d = 1;
    U64 t = 0;
    Gen()
    {
        A.push_back( { 0, 1 } );
        C.push_back( { 0, 1 } );
        D.push_back( { 0, 1 } );
        t = 1000000;
    }
    void adv( U64 n )
    {
        t += n;
    }
    void setA( int v )
    {
        if( a != v )
        {
            a = v;
            A.push_back( { t, v } );
        }
    }
    void setC( int v )
    {
        if( c != v )
        {
            c = v;
            C.push_back( { t, v } );
        }
    }
    void setD( int v )
    {
        if( d != v )
        {
            d = v;
            D.push_back( { t, v } );
        }
    }
    void byte( U8 b, bool cmd, bool eoi )
    {
        setA( cmd ? 0 : 1 );
        setD( 0 );
        setC( 0 );
        adv( 80000 ); // REST
        setC( 1 );
        adv( 300000 ); // RTS: CLK released, DATA still low
        setD( 1 );     // RFD: listener releases DATA while CLK is high
        if( eoi )
        {
            adv( 250000 );
            setD( 0 );
            adv( 60000 );
            setD( 1 ); // listener's EOI acknowledge blip
        }
        adv( 45000 );
        setC( 0 );
        adv( 34000 );
        for( int k = 0; k < 8; k++ )
        {
            setD( ( b >> k ) & 1 );
            adv( 84000 ); // place bit while CLK is LOW
            setC( 1 );
            adv( 117000 ); // CLK high: sample point, DATA steady
            setC( 0 );
            adv( 22000 );
            setD( 1 );
            adv( 97000 ); // DATA released between bits (CLK low)
        }
        setD( 0 );
        adv( 60000 ); // ACK
    }
    // End of transaction: CLK released first, DATA released later, long idle.
    void idle( U64 n )
    {
        setC( 1 );
        adv( 50000 );
        setD( 1 );
        adv( n );
    }
};

std::string decode( Gen& g )
{
    Chan A, C, D;
    A.T = g.A;
    C.T = g.C;
    D.T = g.D;
    std::string out;
    char buf[ 16 ];
    IECDecodeCore( &A, &C, &D, false, [ & ]( U8 b, bool atn, bool eoi, U64, U64, const std::vector<U64>& ) {
        snprintf( buf, sizeof( buf ), "%02X%s%s ", b, atn ? "c" : "", eoi ? "!" : "" );
        out += buf;
    } );
    if( !out.empty() )
        out.erase( out.size() - 1 );
    return out;
}

int failures = 0;
void check( const char* name, const std::string& got, const std::string& want )
{
    bool ok = ( got == want );
    if( !ok )
        failures++;
    printf( "%-26s %s\n            got  [%s]\n", name, ok ? "PASS" : "FAIL", got.c_str() );
    if( !ok )
        printf( "            want [%s]\n", want.c_str() );
}
} // namespace

int main()
{
    { // The regression: stale idle window must not steal the next byte's RTS.
        Gen g;
        g.byte( 0x28, true, false );
        g.byte( 0xE0, true, false );
        g.byte( 0x3F, true, false );
        g.setA( 1 );
        g.idle( 17000000000ULL ); // ~17 s of idle with CLK left released
        g.byte( 0x28, true, false );
        g.byte( 0xF1, true, false );
        g.byte( 0x40, false, false );
        g.byte( 0x57, false, true );
        check( "idle window / first byte", decode( g ), "28c E0c 3Fc 28c F1c 40 57!" );
    }
    { // OPEN + filename, EOI on the last filename byte.
        Gen g;
        g.byte( 0x28, true, false );
        g.byte( 0xF1, true, false );
        std::string fn = "@0:OUT,P,W";
        for( size_t i = 0; i < fn.size(); i++ )
            g.byte( (U8)fn[ i ], false, i + 1 == fn.size() );
        g.byte( 0x3F, true, false );
        check( "filename + EOI", decode( g ), "28c F1c 40 30 3A 4F 55 54 2C 50 2C 57! 3Fc" );
    }
    { // Data phase, EOI on the final data byte only.
        Gen g;
        g.byte( 0x28, true, false );
        g.byte( 0x61, true, false );
        for( int i = 0; i < 4; i++ )
            g.byte( (U8)i, false, false );
        g.byte( 0xFF, false, true );
        g.byte( 0x3F, true, false );
        check( "data + EOI on last", decode( g ), "28c 61c 00 01 02 03 FF! 3Fc" );
    }
    { // Command bytes are never flagged EOI.
        Gen g;
        g.byte( 0x3F, true, true ); // even with an EOI-shaped ready phase
        check( "command never EOI", decode( g ), "3Fc" );
    }

    printf( "\n%s\n", failures == 0 ? "ALL PASS" : "FAILURES" );
    return failures == 0 ? 0 : 1;
}
