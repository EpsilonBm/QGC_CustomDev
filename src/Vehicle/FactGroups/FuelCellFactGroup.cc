#include "FuelCellFactGroup.h"
#include "Vehicle.h"
#include "mavlink_msg_fuel_cell_status.h"

FuelCellFactGroup::FuelCellFactGroup(QObject* parent)
    : FactGroup(1000, ":/json/Vehicle/FuelCellFact.json", parent)
    , _systemStatusFact         (0, "systemStatus",         FactMetaData::valueTypeUint16,  this)
    , _loadVoltageFact          (0, "loadVoltage",          FactMetaData::valueTypeDouble,  this)
    , _errorCodeFact            (0, "errorCode",            FactMetaData::valueTypeUint16,  this)
    , _highestTemperatureIdFact (0, "highestTemperatureId", FactMetaData::valueTypeUint16,  this)
    , _highestTemperatureFact   (0, "highestTemperature",   FactMetaData::valueTypeDouble,  this)
    , _highestFanSpeedFact      (0, "highestFanSpeed",      FactMetaData::valueTypeUint16,  this)
    , _lowestVoltageIdFact      (0, "lowestVoltageId",      FactMetaData::valueTypeUint16,  this)
    , _lowestVoltageFact        (0, "lowestVoltage",        FactMetaData::valueTypeDouble,  this)
    , _faultIdFact              (0, "faultId",              FactMetaData::valueTypeUint16,  this)
    , _faultDcFlagFact          (0, "faultDcFlag",          FactMetaData::valueTypeUint16,  this)
    , _faultFcFlagFact          (0, "faultFcFlag",          FactMetaData::valueTypeUint16,  this)
    , _dcOutputCurrentFact      (0, "dcOutputCurrent",      FactMetaData::valueTypeDouble,  this)
    , _dcInputPowerFact         (0, "dcInputPower",         FactMetaData::valueTypeDouble,  this)
    , _dcOutputPowerFact        (0, "dcOutputPower",        FactMetaData::valueTypeDouble,  this)
    , _pressureLowestIdFact     (0, "pressureLowestId",     FactMetaData::valueTypeUint16,  this)
    , _pressureLowestFact       (0, "pressureLowest",       FactMetaData::valueTypeDouble,  this)
    , _pressureTotalFact        (0, "pressureTotal",        FactMetaData::valueTypeDouble,  this)
    , _instantPowerFact         (0, "instantPower",         FactMetaData::valueTypeDouble,  this)
    , _remainingEnergyFact      (0, "remainingEnergy",      FactMetaData::valueTypeDouble,  this)
    , _remainingTimeFact        (0, "remainingTime",        FactMetaData::valueTypeDouble,  this)
    , _percentRemainingFact     (0, "percentRemaining",     FactMetaData::valueTypeDouble,  this)
    , _bottleCapacityFact       (0, "bottleCapacity",       FactMetaData::valueTypeDouble,  this)
    , _maxEnergyFact            (0, "maxEnergy",            FactMetaData::valueTypeDouble,  this)
    , _bottleCapacity(9.0)      // 默认9L氢气瓶
    , _maxEnergy(3.0)           // 默认3度电
    , _avgPower(0.0)            // 平均功率初始化为0
    , _announcementTimer(new QTimer(this)) // 初始化定时器

{
    // 设置定时器每秒触发一次
    _announcementTimer->setInterval(12000); // 1000ms = 1s
    connect(_announcementTimer, &QTimer::timeout, this, &FuelCellFactGroup::checkAndAnnounceFuelLevel);
    _addFact(&_systemStatusFact,         _systemStatusFact.name());
    _addFact(&_loadVoltageFact,          _loadVoltageFact.name());
    _addFact(&_errorCodeFact,            _errorCodeFact.name());
    _addFact(&_highestTemperatureIdFact, _highestTemperatureIdFact.name());
    _addFact(&_highestTemperatureFact,   _highestTemperatureFact.name());
    _addFact(&_highestFanSpeedFact,      _highestFanSpeedFact.name());
    _addFact(&_lowestVoltageIdFact,      _lowestVoltageIdFact.name());
    _addFact(&_lowestVoltageFact,        _lowestVoltageFact.name());
    _addFact(&_faultIdFact,              _faultIdFact.name());
    _addFact(&_faultDcFlagFact,          _faultDcFlagFact.name());
    _addFact(&_faultFcFlagFact,          _faultFcFlagFact.name());
    _addFact(&_dcOutputCurrentFact,      _dcOutputCurrentFact.name());
    _addFact(&_dcInputPowerFact,         _dcInputPowerFact.name());
    _addFact(&_dcOutputPowerFact,        _dcOutputPowerFact.name());
    _addFact(&_pressureLowestIdFact,     _pressureLowestIdFact.name());
    _addFact(&_pressureLowestFact,       _pressureLowestFact.name());
    _addFact(&_pressureTotalFact,        _pressureTotalFact.name());
    _addFact(&_instantPowerFact,         _instantPowerFact.name());
    _addFact(&_remainingEnergyFact,      _remainingEnergyFact.name());
    _addFact(&_remainingTimeFact,        _remainingTimeFact.name());
    _addFact(&_percentRemainingFact,     _percentRemainingFact.name());
    _addFact(&_bottleCapacityFact,       _bottleCapacityFact.name());
    _addFact(&_maxEnergyFact,            _maxEnergyFact.name());

    // Initialize default values
    _bottleCapacityFact.setRawValue(_bottleCapacity);
    _maxEnergyFact.setRawValue(_maxEnergy);
}

// 添加检查和播报方法
void FuelCellFactGroup::checkAndAnnounceFuelLevel()
{
    // 获取当前数据
    double hydrogenPercentage = _percentRemainingFact.rawValue().toDouble();
    double stackTemperature = _highestTemperatureFact.rawValue().toDouble();
    double voltage = _loadVoltageFact.rawValue().toDouble();

    // 检查数据有效性
    if (qIsNaN(hydrogenPercentage) || hydrogenPercentage < 0 || hydrogenPercentage > 100 ||
        qIsNaN(stackTemperature) || qIsNaN(voltage)) {
        return;
    }

    // 构造播报内容
    QString announcement = QStringLiteral("氢燃料电池状态：氢气百分之%1，堆温%2，电压%3")
                              .arg(qRound(hydrogenPercentage))
                              .arg(qRound(stackTemperature))
                              .arg(qRound(voltage));

    // 发出信号用于语音播报
    emit fuelLevelAnnouncementNeeded(announcement);
}

void FuelCellFactGroup::handleCommunicationLost(bool lost)
{
    if (lost) {
        _announcementTimer->stop();
    } else {
        int status = _systemStatusFact.rawValue().toInt();
        if (status != 0 && status != 5 && status != 7) {
            if (!_announcementTimer->isActive()) {
                _announcementTimer->start();
            }
        }
    }
}

void FuelCellFactGroup::setBottleCapacity(double capacity, double maxEnergy)
{
    _bottleCapacity = capacity;
    _bottleCapacityFact.setRawValue(capacity);
    // TODO: Add relationship between bottle capacity and max energy
    _maxEnergy = maxEnergy;
    _maxEnergyFact.setRawValue(maxEnergy);
}

void FuelCellFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_FUEL_CELL_STATUS) {
        return;
    }

    mavlink_fuel_cell_status_t status;
    mavlink_msg_fuel_cell_status_decode(&message, &status);

    _systemStatusFact.setRawValue(status.system_status);
    // 根据 system_status 控制计时器启停
    switch (status.system_status) {
        case 0:
        case 5:
        case 7:
            if (_announcementTimer->isActive()) {
                _announcementTimer->stop();
                qDebug() << "Timer stopped due to system_status:" << status.system_status;
            }
            break;
        default:
            if (!_announcementTimer->isActive()) {
                _announcementTimer->start();
                qDebug() << "Timer started due to system_status:" << status.system_status;
            }
            break;
    }
    _loadVoltageFact.setRawValue(status.load_voltage / 10.0);
    _errorCodeFact.setRawValue(status.error_code);
    _highestTemperatureIdFact.setRawValue(status.highest_temperature_id);
    _highestTemperatureFact.setRawValue(status.highest_temperature / 10.0);
    _highestFanSpeedFact.setRawValue(status.highest_fan_speed);
    _lowestVoltageIdFact.setRawValue(status.lowest_voltage_id);
    _lowestVoltageFact.setRawValue(status.lowest_voltage / 10.0);
    _faultIdFact.setRawValue(status.fault_id);
    _faultDcFlagFact.setRawValue(status.fault_dc_flag);
    _faultFcFlagFact.setRawValue(status.fault_fc_flag);
    _dcOutputCurrentFact.setRawValue(status.dc_output_current / 10.0);
    _dcInputPowerFact.setRawValue(status.dc_input_power / 10.0);
    _dcOutputPowerFact.setRawValue(status.dc_output_power / 10.0);
    _pressureLowestIdFact.setRawValue(status.pressure_lowest_id);
    _pressureLowestFact.setRawValue(status.pressure_lowest / 10.0);
    _pressureTotalFact.setRawValue(status.pressure_total / 10.0);

    if (status.system_status == 0 || status.system_status == 5 || status.system_status == 7) {
        _announcementTimer->stop();
    } else {
        if (!_announcementTimer->isActive()) {
            _announcementTimer->start();
        }
    }

    // 1. Calculate instantaneous power (W)
    double instantaneous_power_w = _loadVoltageFact.rawValue().toDouble() * _dcOutputCurrentFact.rawValue().toDouble();
    _instantPowerFact.setRawValue(instantaneous_power_w);

    // 2. Update power history and calculate average power
    _powerHistory.enqueue(instantaneous_power_w / 1000.0); // Store as kW for avg calculation
    if (_powerHistory.size() > 10) {                         // Up to 10 data.
        _powerHistory.dequeue();
    }
    double power_sum = 0.0;                                  // Calculating average power
    for (double power : _powerHistory) {
        power_sum += power;
    }
    _avgPower = _powerHistory.isEmpty() ? 0.0 : (power_sum / _powerHistory.size());

    // 3. Calculate remaining energy and percentage from pressure
    double min_pressure = 2.0;
    double max_pressure = 35.0;
    double pressure_range = max_pressure - min_pressure;
    double percentage = qBound(0.0, ((_pressureTotalFact.rawValue().toDouble() - min_pressure) / pressure_range) * 100.0, 100.0);
    double remaining_energy = (_maxEnergy * percentage) / 100.0;
    _percentRemainingFact.setRawValue(percentage);
    _remainingEnergyFact.setRawValue(remaining_energy);

    // 4. Calculate remaining time
    double remaining_time_hours = 0.0;
    if (_avgPower > 0.001) { // Avoid division by zero (avg power in kW)
        remaining_time_hours = remaining_energy / _avgPower;
    }
    _remainingTimeFact.setRawValue(remaining_time_hours);

}

void FuelCellFactGroup::onCommunicationLostChanged(bool communicationLost)
{
    if (communicationLost) {
        // 连接丢失时停止计时器
        if (_announcementTimer->isActive()) {
            _announcementTimer->stop();
            qDebug() << "Timer stopped due to communication loss";
        }
    } else {
        // 连接恢复时启动计时器（前提是 system_status 允许）
        mavlink_fuel_cell_status_t status;
        status.system_status = _systemStatusFact.rawValue().toUInt(); // 获取当前 system_status

        switch (status.system_status) {
            case 0:
            case 5:
            case 7:
                // 不启动计时器
                break;
            default:
                if (!_announcementTimer->isActive()) {
                    _announcementTimer->start();
                    qDebug() << "Timer started due to communication restored";
                }
                break;
        }
    }
}
