#ifndef IEC_ANALYZER_H
#define IEC_ANALYZER_H

#include <Analyzer.h>
#include "IECAnalyzerSettings.h"
#include "IECAnalyzerResults.h"
#include "IECSimulationDataGenerator.h"
#include <memory>
#include <vector>

class ANALYZER_EXPORT IECAnalyzer : public Analyzer2
{
  public:
    IECAnalyzer();
    virtual ~IECAnalyzer();

    virtual void SetupResults();
    virtual void WorkerThread();

    virtual U32 GenerateSimulationData( U64 newest_sample_requested, U32 sample_rate, SimulationChannelDescriptor** simulation_channels );
    virtual U32 GetMinimumSampleRateHz();

    virtual const char* GetAnalyzerName() const;
    virtual bool NeedsRerun();

  protected: // helpers
    // Returns the logical wire level of a channel at its current position,
    // accounting for the "inverted probe" setting.
    BitState WireLevel( AnalyzerChannelData* channel );
    // Classifies a finished byte and emits a frame + markers.
    void EmitByte( U8 byte, bool atn_asserted, bool eoi, bool partial, U64 start_sample, U64 end_sample,
                   const std::vector<U64>& bit_samples );

  protected: // vars
    IECAnalyzerSettings mSettings;
    std::unique_ptr<IECAnalyzerResults> mResults;

    AnalyzerChannelData* mAtn;
    AnalyzerChannelData* mClk;
    AnalyzerChannelData* mData;

    U32 mSampleRateHz;

    IECSimulationDataGenerator mSimulationDataGenerator;
    bool mSimulationInitialized;
};

extern "C" ANALYZER_EXPORT const char* __cdecl GetAnalyzerName();
extern "C" ANALYZER_EXPORT Analyzer* __cdecl CreateAnalyzer();
extern "C" ANALYZER_EXPORT void __cdecl DestroyAnalyzer( Analyzer* analyzer );

#endif // IEC_ANALYZER_H
