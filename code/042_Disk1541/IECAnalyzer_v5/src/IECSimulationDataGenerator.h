#ifndef IEC_SIMULATION_DATA_GENERATOR
#define IEC_SIMULATION_DATA_GENERATOR

#include <SimulationChannelDescriptor.h>
#include <string>

class IECAnalyzerSettings;

class IECSimulationDataGenerator
{
  public:
    IECSimulationDataGenerator();
    ~IECSimulationDataGenerator();

    void Initialize( U32 simulation_sample_rate, IECAnalyzerSettings* settings );
    U32 GenerateSimulationData( U64 newest_sample_requested, U32 sample_rate, SimulationChannelDescriptor** simulation_channel );

  protected:
    IECAnalyzerSettings* mSettings;
    U32 mSimulationSampleRateHz;

    SimulationChannelDescriptorGroup mGroup;
    SimulationChannelDescriptor* mAtn;
    SimulationChannelDescriptor* mClk;
    SimulationChannelDescriptor* mData;

    // microseconds -> samples
    U32 Us( double microseconds );

    // Drive ATN to the wanted bus level (asserted = LOW on the wire).
    void SetAtnAsserted( bool asserted );
    // Clock one byte out (LSB first). atn_asserted picks command vs data phase;
    // eoi inserts the long pre-byte pause that flags the last byte.
    void SendByte( U8 byte, bool atn_asserted, bool eoi );
    // Emit one canned read-a-file transaction (LISTEN/OPEN/data/TALK/.../CLOSE).
    void SendTransaction();
};

#endif // IEC_SIMULATION_DATA_GENERATOR
