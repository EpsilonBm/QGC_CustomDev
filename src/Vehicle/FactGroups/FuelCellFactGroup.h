#pragma once

#include "FactGroup.h"
#include "QGCMAVLink.h"

class FuelCellFactGroup : public FactGroup
{
    Q_OBJECT

public:
    FuelCellFactGroup(QObject* parent = nullptr);

    Q_PROPERTY(Fact* systemStatus         READ systemStatus         CONSTANT)
    Q_PROPERTY(Fact* loadVoltage          READ loadVoltage          CONSTANT)
    Q_PROPERTY(Fact* errorCode            READ errorCode            CONSTANT)
    Q_PROPERTY(Fact* highestTemperatureId READ highestTemperatureId CONSTANT)
    Q_PROPERTY(Fact* highestTemperature   READ highestTemperature   CONSTANT)
    Q_PROPERTY(Fact* highestFanSpeed      READ highestFanSpeed      CONSTANT)
    Q_PROPERTY(Fact* lowestVoltageId      READ lowestVoltageId      CONSTANT)
    Q_PROPERTY(Fact* lowestVoltage        READ lowestVoltage        CONSTANT)
    Q_PROPERTY(Fact* faultId              READ faultId              CONSTANT)
    Q_PROPERTY(Fact* faultDcFlag          READ faultDcFlag          CONSTANT)
    Q_PROPERTY(Fact* faultFcFlag          READ faultFcFlag          CONSTANT)
    Q_PROPERTY(Fact* dcOutputCurrent      READ dcOutputCurrent      CONSTANT)
    Q_PROPERTY(Fact* dcInputPower         READ dcInputPower         CONSTANT)
    Q_PROPERTY(Fact* dcOutputPower        READ dcOutputPower        CONSTANT)
    Q_PROPERTY(Fact* pressureLowestId     READ pressureLowestId     CONSTANT)
    Q_PROPERTY(Fact* pressureLowest       READ pressureLowest       CONSTANT)
    Q_PROPERTY(Fact* pressureTotal        READ pressureTotal        CONSTANT)

    Fact* systemStatus          () { return &_systemStatusFact; }
    Fact* loadVoltage           () { return &_loadVoltageFact; }
    Fact* errorCode             () { return &_errorCodeFact; }
    Fact* highestTemperatureId  () { return &_highestTemperatureIdFact; }
    Fact* highestTemperature    () { return &_highestTemperatureFact; }
    Fact* highestFanSpeed       () { return &_highestFanSpeedFact; }
    Fact* lowestVoltageId       () { return &_lowestVoltageIdFact; }
    Fact* lowestVoltage         () { return &_lowestVoltageFact; }
    Fact* faultId               () { return &_faultIdFact; }
    Fact* faultDcFlag           () { return &_faultDcFlagFact; }
    Fact* faultFcFlag           () { return &_faultFcFlagFact; }
    Fact* dcOutputCurrent       () { return &_dcOutputCurrentFact; }
    Fact* dcInputPower          () { return &_dcInputPowerFact; }
    Fact* dcOutputPower         () { return &_dcOutputPowerFact; }
    Fact* pressureLowestId      () { return &_pressureLowestIdFact; }
    Fact* pressureLowest        () { return &_pressureLowestFact; }
    Fact* pressureTotal         () { return &_pressureTotalFact; }

    void handleMessage(Vehicle* vehicle, mavlink_message_t& message) override;

private:
    Fact _systemStatusFact;
    Fact _loadVoltageFact;
    Fact _errorCodeFact;
    Fact _highestTemperatureIdFact;
    Fact _highestTemperatureFact;
    Fact _highestFanSpeedFact;
    Fact _lowestVoltageIdFact;
    Fact _lowestVoltageFact;
    Fact _faultIdFact;
    Fact _faultDcFlagFact;
    Fact _faultFcFlagFact;
    Fact _dcOutputCurrentFact;
    Fact _dcInputPowerFact;
    Fact _dcOutputPowerFact;
    Fact _pressureLowestIdFact;
    Fact _pressureLowestFact;
    Fact _pressureTotalFact;
};