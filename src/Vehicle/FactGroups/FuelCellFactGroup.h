#pragma once

#include "FactGroup.h"
#include "QGCMAVLink.h"
#include <QQueue>

class FuelCellFactGroup : public FactGroup
{
    Q_OBJECT

public:
    explicit FuelCellFactGroup(QObject* parent = nullptr);

    // 设置氢气瓶容量和最大电量
    void setBottleCapacity(double capacity, double maxEnergy);

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
    Q_PROPERTY(Fact* instantPower         READ instantPower         CONSTANT)
    Q_PROPERTY(Fact* remainingEnergy      READ remainingEnergy      CONSTANT)
    Q_PROPERTY(Fact* remainingTime        READ remainingTime        CONSTANT)
    Q_PROPERTY(Fact* percentRemaining     READ percentRemaining     CONSTANT)
    Q_PROPERTY(Fact* bottleCapacity       READ bottleCapacity       CONSTANT)

    // Fact 访问器 (C++侧使用，QML侧直接通过属性名访问)
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
    Fact* instantPower          () { return &_instantPowerFact; }
    Fact* remainingEnergy       () { return &_remainingEnergyFact; }
    Fact* remainingTime         () { return &_remainingTimeFact; }
    Fact* percentRemaining      () { return &_percentRemainingFact; }
    Fact* bottleCapacity        () { return &_bottleCapacityFact; }

    void handleMessage(Vehicle* vehicle, mavlink_message_t& message);

signals:
    // FactGroup 会自动处理 Fact 值的变化信号
    // 我们保留特定的报警信号
    // TODO: realize them.
    void efficiencyAlert(double efficiency);
    void temperatureAlert(double temperature);
    void pressureAlert(double pressure);
    void faultDetected(uint32_t fault_flags);

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
    Fact _instantPowerFact;
    Fact _remainingEnergyFact;
    Fact _remainingTimeFact;
    Fact _percentRemainingFact;
    Fact _bottleCapacityFact;

    // 燃料电池参数
    double _bottleCapacity;      // 氢气瓶容量 (L)
    double _maxEnergy;           // 最大电量 (kWh)
    double _avgPower;            // 平均功率 (kW)
    QQueue<double> _powerHistory; // 功率历史数据队列
};