#include "FuelCellManager.h"
#include <QtMath>
#include <QDebug>

FuelCellManager::FuelCellManager(QObject *parent)
    : FactGroup(1000, "", parent) // 不使用JSON文件，直接在C++中定义元数据
    , _bottleCapacity(9.0)      // 默认9L氢气瓶
    , _maxEnergy(3.0)           // 默认3度电
    , _avgPower(0.0)            // 平均功率初始化为0
{
    _initFacts();
}

void FuelCellManager::_initFacts()
{
    // Voltage
    _voltageFact = new Fact(0, "voltage", FactMetaData::valueTypeDouble, this);
    FactMetaData* voltageMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    voltageMeta->setName("voltage");
    voltageMeta->setRawUnits("V");
    voltageMeta->setDecimalPlaces(2);
    _voltageFact->setMetaData(voltageMeta);
    _addFact(_voltageFact, _voltageFact->name());

    // Current
    _currentFact = new Fact(0, "current", FactMetaData::valueTypeDouble, this);
    FactMetaData* currentMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    currentMeta->setName("current");
    currentMeta->setRawUnits("A");
    currentMeta->setDecimalPlaces(2);
    _currentFact->setMetaData(currentMeta);
    _addFact(_currentFact, _currentFact->name());

    // Pressure
    _pressureFact = new Fact(0, "pressure", FactMetaData::valueTypeDouble, this);
    FactMetaData* pressureMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    pressureMeta->setName("pressure");
    pressureMeta->setRawUnits("bar");
    pressureMeta->setDecimalPlaces(2);
    _pressureFact->setMetaData(pressureMeta);
    _addFact(_pressureFact, _pressureFact->name());

    // Temperature
    _temperatureFact = new Fact(0, "temperature", FactMetaData::valueTypeDouble, this);
    FactMetaData* tempMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    tempMeta->setName("temperature");
    tempMeta->setRawUnits("degC");
    tempMeta->setDecimalPlaces(1);
    _temperatureFact->setMetaData(tempMeta);
    _addFact(_temperatureFact, _temperatureFact->name());

    // Power
    _powerFact = new Fact(0, "power", FactMetaData::valueTypeDouble, this);
    FactMetaData* powerMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    powerMeta->setName("power");
    powerMeta->setRawUnits("W");
    powerMeta->setDecimalPlaces(1);
    _powerFact->setMetaData(powerMeta);
    _addFact(_powerFact, _powerFact->name());

    // Remaining Energy
    _remainingEnergyFact = new Fact(0, "remainingEnergy", FactMetaData::valueTypeDouble, this);
    FactMetaData* energyMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    energyMeta->setName("remainingEnergy");
    energyMeta->setRawUnits("kWh");
    energyMeta->setDecimalPlaces(2);
    _remainingEnergyFact->setMetaData(energyMeta);
    _addFact(_remainingEnergyFact, _remainingEnergyFact->name());

    // Remaining Time
    _remainingTimeFact = new Fact(0, "remainingTime", FactMetaData::valueTypeDouble, this);
    FactMetaData* timeMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    timeMeta->setName("remainingTime");
    timeMeta->setRawUnits("h");
    timeMeta->setDecimalPlaces(2);
    _remainingTimeFact->setMetaData(timeMeta);
    _addFact(_remainingTimeFact, _remainingTimeFact->name());

    // Percent Remaining
    _percentRemainingFact = new Fact(0, "percentRemaining", FactMetaData::valueTypeDouble, this);
    FactMetaData* percentMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    percentMeta->setName("percentRemaining");
    percentMeta->setRawUnits("%");
    percentMeta->setDecimalPlaces(0);
    _percentRemainingFact->setMetaData(percentMeta);
    _addFact(_percentRemainingFact, _percentRemainingFact->name());

    // Status Description
    _statusFact = new Fact(0, "status", FactMetaData::valueTypeString, this);
    FactMetaData* statusMeta = new FactMetaData(FactMetaData::valueTypeString);
    statusMeta->setName("status");
    _statusFact->setMetaData(statusMeta);
    _addFact(_statusFact, _statusFact->name());

    _statusFact->setRawValue("WAITING");

    // Bottle Capacity
    _bottleCapacityFact = new Fact(0, "bottleCapacity", FactMetaData::valueTypeDouble, this);
    FactMetaData* bottleMeta = new FactMetaData(FactMetaData::valueTypeDouble);
    bottleMeta->setName("bottleCapacity");
    bottleMeta->setRawUnits("L");
    bottleMeta->setDecimalPlaces(1);
    _bottleCapacityFact->setMetaData(bottleMeta);
    _addFact(_bottleCapacityFact, _bottleCapacityFact->name());
    _bottleCapacityFact->setRawValue(_bottleCapacity);
}

void FuelCellManager::setBottleCapacity(double capacity, double maxEnergy)
{
    _bottleCapacity = capacity;
    _bottleCapacityFact->setRawValue(capacity);
    _maxEnergy = maxEnergy;
}

void FuelCellManager::handleFuelCellStatus(const mavlink_fuel_cell_status_t& status)
{
    _voltageFact->setRawValue(status.voltage_v);
    _currentFact->setRawValue(status.current_a);
    _pressureFact->setRawValue(status.hydrogen_pressure_bar);
    _temperatureFact->setRawValue(status.stack_temperature_c);

    // 1. 计算瞬时功率 (kW)
    double instantaneous_power_kw = (status.voltage_v * status.current_a) / 1000.0; // 转换为kW

    // 2. 将瞬时功率添加到历史队列
    _powerHistory.enqueue(instantaneous_power_kw);
    if (_powerHistory.size() > 10) {
        _powerHistory.dequeue(); // 保持最多10个数据点
    }

    // 3. 计算平均功率
    double power_sum = 0.0;
    for (double power : _powerHistory) {
        power_sum += power;
    }
    _avgPower = power_sum / _powerHistory.size();

    // 4. 计算剩余电量
    // 压强转换为百分比 (2-35 bar 对应 0%-100%)
    double min_pressure = 2.0;  // 最小有效压力
    double max_pressure = 35.0; // 最大压力
    double pressure_range = max_pressure - min_pressure; // 压力范围: 33.0 bar

    // 将实际压力映射到0-100%范围内
    double percentage = qBound(0.0,
        ((status.hydrogen_pressure_bar - min_pressure) / pressure_range) * 100.0,
        100.0);

    double remaining_energy = (_maxEnergy * percentage) / 100.0; // 剩余电量 (kWh)

    // 5. 计算剩余时间 (小时)
    double remaining_time_hours = 0.0;
    if (_avgPower > 0.001) { // 避免除零，假设最小功率为1W
        remaining_time_hours = remaining_energy / _avgPower;
    }

    // 更新计算出的 Facts
    _powerFact->setRawValue(instantaneous_power_kw * 1000.0); // W
    _remainingEnergyFact->setRawValue(remaining_energy);
    _remainingTimeFact->setRawValue(remaining_time_hours);
    _percentRemainingFact->setRawValue(percentage);

    // 6. 生成状态描述
    QString statusStr = "NORMAL";
    if (status.fault_flags != 0) {
        statusStr = "FAULT";
    } else if (status.stack_temperature_c > 80) {
        statusStr = "HIGH_TEMP";
    } else if (status.voltage_v < 20.0) {
        statusStr = "LOW_VOLTAGE";
    }
    _statusFact->setRawValue(statusStr);

    // 11. 检查警报条件
    if (status.stack_temperature_c > 80) {
        emit temperatureAlert(status.stack_temperature_c);
    }
    if (status.fault_flags != 0) {
        emit faultDetected(status.fault_flags);
    }
}
