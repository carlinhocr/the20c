// Validates the SHARED IECDecodeCore against a real Saleae CSV capture by
// driving it through a mock channel that mimics AnalyzerChannelData.
//
// Build:  g++ -std=c++11 -I<sdk_include> test_decode_csv.cpp -o t && ./t <csv>
#include "../src/IECDecodeCore.h"
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

// Mock channel: a sorted list of (sample, level) transitions + a cursor.
class MockChannel
{
  public:
    void init( std::vector<std::pair<U64, int>> trans )
    {
        mTrans = std::move( trans );
        mCursor = mTrans.empty() ? 0 : mTrans.front().first;
    }
    BitState GetBitState() { return levelAt( mCursor ) ? BIT_HIGH : BIT_LOW; }
    U64 GetSampleNumber() { return mCursor; }
    void AdvanceToNextEdge() { mCursor = nextEdgeAfter( mCursor ); }
    void AdvanceToAbsPosition( U64 s ) { mCursor = s; }
    U64 GetSampleOfNextEdge() { return nextEdgeAfter( mCursor ); }
    bool DoMoreTransitionsExistInCurrentData() { return idxAfter( mCursor ) < mTrans.size(); }
    bool WouldAdvancingToAbsPositionCauseTransition( U64 s )
    {
        size_t i = idxAfter( mCursor );
        return i < mTrans.size() && mTrans[ i ].first <= s;
    }

  private:
    std::vector<std::pair<U64, int>> mTrans;
    U64 mCursor = 0;
    int levelAt( U64 s )
    {
        // last transition with sample <= s
        size_t lo = 0, hi = mTrans.size();
        while( lo < hi )
        {
            size_t mid = ( lo + hi ) / 2;
            if( mTrans[ mid ].first <= s )
                lo = mid + 1;
            else
                hi = mid;
        }
        return lo == 0 ? mTrans.front().second : mTrans[ lo - 1 ].second;
    }
    size_t idxAfter( U64 s )
    {
        size_t lo = 0, hi = mTrans.size();
        while( lo < hi )
        {
            size_t mid = ( lo + hi ) / 2;
            if( mTrans[ mid ].first <= s )
                lo = mid + 1;
            else
                hi = mid;
        }
        return lo; // first index with sample > s
    }
    U64 nextEdgeAfter( U64 s )
    {
        size_t i = idxAfter( s );
        return i < mTrans.size() ? mTrans[ i ].first : s; // clamp at end
    }
};

int main( int argc, char** argv )
{
    const char* path = argc > 1 ? argv[ 1 ] : "Session_15_using_v19_toWrite.csv";
    std::ifstream f( path );
    if( !f )
    {
        printf( "cannot open %s\n", path );
        return 2;
    }
    std::string line;
    std::getline( f, line ); // header
    // columns: Time,ATN,CLK,DATA,PB3,PB0,PB1,PB2,PB4
    std::vector<std::pair<U64, int>> atn, clk, data;
    int pa = -1, pc = -1, pd = -1;
    bool first = true;
    while( std::getline( f, line ) )
    {
        if( line.empty() )
            continue;
        std::stringstream ss( line );
        std::string cell;
        std::vector<std::string> c;
        while( std::getline( ss, cell, ',' ) )
            c.push_back( cell );
        if( c.size() < 4 )
            continue;
        double t = atof( c[ 0 ].c_str() );
        U64 s = (U64)( t * 1e9 + 0.5 ); // nanosecond samples
        int a = atoi( c[ 1 ].c_str() ), k = atoi( c[ 2 ].c_str() ), d = atoi( c[ 3 ].c_str() );
        if( first )
        {
            atn.push_back( { s, a } );
            clk.push_back( { s, k } );
            data.push_back( { s, d } );
            pa = a;
            pc = k;
            pd = d;
            first = false;
            continue;
        }
        if( a != pa )
        {
            atn.push_back( { s, a } );
            pa = a;
        }
        if( k != pc )
        {
            clk.push_back( { s, k } );
            pc = k;
        }
        if( d != pd )
        {
            data.push_back( { s, d } );
            pd = d;
        }
    }
    MockChannel mAtn, mClk, mData;
    mAtn.init( atn );
    mClk.init( clk );
    mData.init( data );

    struct Out
    {
        U8 byte;
        bool atn;
        bool eoi;
    };
    std::vector<Out> out;
    IECDecodeCore( &mAtn, &mClk, &mData, /*inverted=*/false,
                   [ & ]( U8 byte, bool atn_asserted, bool eoi, U64, U64, const std::vector<U64>& ) {
                       out.push_back( { byte, atn_asserted, eoi } );
                   } );

    printf( "decoded %zu bytes\n", out.size() );
    // Render a compact view
    auto phase = []( bool a ) { return a ? 'C' : 'd'; };
    printf( "first 20: " );
    for( size_t i = 0; i < out.size() && i < 20; i++ )
        printf( "%02X%c ", out[ i ].byte, phase( out[ i ].atn ) );
    printf( "\nlast 8 : " );
    for( size_t i = ( out.size() > 8 ? out.size() - 8 : 0 ); i < out.size(); i++ )
        printf( "%02X%c ", out[ i ].byte, phase( out[ i ].atn ) );
    printf( "\nEOI bytes: " );
    for( auto& o : out )
        if( o.eoi )
            printf( "$%02X ", o.byte );
    printf( "\n" );

    // ---- assertions ----
    bool ok = true;
    if( out.size() != 279 )
    {
        printf( "FAIL: expected 279 bytes\n" );
        ok = false;
    }
    // find exact 00..FF run among data-phase bytes
    std::vector<U8> dbytes;
    for( auto& o : out )
        if( !o.atn )
            dbytes.push_back( o.byte );
    bool found = false;
    for( size_t s = 0; s + 256 <= dbytes.size(); s++ )
    {
        bool run = true;
        for( int j = 0; j < 256; j++ )
            if( dbytes[ s + j ] != (U8)j )
            {
                run = false;
                break;
            }
        if( run )
        {
            found = true;
            break;
        }
    }
    printf( "exact 00..FF data run present: %s\n", found ? "yes" : "NO" );
    if( !found )
        ok = false;
    // EOI must be exactly {$57, $FF}
    std::vector<U8> eoi;
    for( auto& o : out )
        if( o.eoi )
            eoi.push_back( o.byte );
    bool eoiOk = ( eoi.size() == 2 && eoi[ 0 ] == 0x57 && eoi[ 1 ] == 0xFF );
    printf( "EOI exactly {$57,$FF}: %s\n", eoiOk ? "yes" : "NO" );
    if( !eoiOk )
        ok = false;

    printf( "%s\n", ok ? "ALL PASS" : "FAIL" );
    return ok ? 0 : 1;
}
