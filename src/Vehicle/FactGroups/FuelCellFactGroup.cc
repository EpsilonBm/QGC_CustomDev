#include "FuelCellFactGroup.h"
#include "Vehicle.h"
#include "mavlink_msg_fuel_cell_status.h"

FuelCellFactGroup::FuelCellFactGroup(QObject* parent)
    : FactGroup(1000, ":/json/Vehicle/FuelCellFact.json", parent)
    // Should be loaded via json, or U can init like this:
    // , _systemStatusFact(0, "systemStatus", FactMetaData::valueTypeUint16,this)
    , _bottleCapacity(9.0)      // 默认9L氢气瓶
    , _maxEnergy(3.0)           // 默认3度电
    , _avgPower(0.0)            // 平均功率初始化为0
{
    // 设置默认语音播报阈值 (每10%播报一次)
    _voiceAlertThresholds << 100.0 << 50.0 << 30.0 << 10.0 << 0.0;
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
}

// 添加语音播报阈值设置方法
void FuelCellFactGroup::setVoiceAlertThresholds(const QList<double>& thresholds)
{
    _voiceAlertThresholds = thresholds;
}

// 添加检查和播报方法
void FuelCellFactGroup::checkAndAnnounceFuelLevel()
{
    double currentPercentage = _percentRemainingFact.rawValue().toDouble();

    // 检查是否为有效数值
    if (qIsNaN(currentPercentage) || currentPercentage < 0 || currentPercentage > 100) {
        return;
    }

    // 找到最接近的播报阈值
    double closestThreshold = -1.0;
    for (double threshold : _voiceAlertThresholds) {
        if (currentPercentage <= threshold + _announcementTolerance) {
            // 检查是否已经播报过这个阈值
            if (_lastAnnouncedPercentage < 0 ||
                qAbs(currentPercentage - _lastAnnouncedPercentage) > _announcementTolerance) {
                // 检查是否接近这个阈值
                if (qAbs(currentPercentage - threshold) <= _announcementTolerance) {
                    closestThreshold = threshold;
                    break;
                }
                }
        }
    }

    if (closestThreshold >= 0 && closestThreshold != _lastAnnouncedPercentage) {
        // 更新上次播报的百分比
        _lastAnnouncedPercentage = closestThreshold;

        // 触发语音播报信号
        QString announcement;
        if (closestThreshold == 0.0) {
            announcement = QStringLiteral("氢燃料电池电量耗尽");
        } else if (closestThreshold <= 10.0) {
            announcement = QStringLiteral("氢燃料电池电量极低，剩余百分之10");
        } else if (closestThreshold <= 30.0) {
            announcement = QStringLiteral("氢燃料电池电量提醒，剩余百分之30");
        } else if (closestThreshold <= 50.0) {
            announcement = QStringLiteral("氢燃料电池电量提醒，剩余百分之50");
        } else {
            announcement = QStringLiteral("氢燃料电池电量百分之%1").arg(qRound(closestThreshold));
        }

        // 发出信号用于语音播报
        emit fuelLevelAnnouncementNeeded(announcement);
    }
}

void FuelCellFactGroup::setBottleCapacity(double capacity, double maxEnergy)
{
    _bottleCapacity = capacity;
    _bottleCapacityFact.setRawValue(capacity);
    // TODO: Add relationship between bottle capacity and max energy
    _maxEnergy = maxEnergy;
}

void FuelCellFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_FUEL_CELL_STATUS) {
        return;
    }

    mavlink_fuel_cell_status_t status;
    mavlink_msg_fuel_cell_status_decode(&message, &status);

    _systemStatusFact.setRawValue(status.system_status);
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

    // 在这里添加语音播报检查
    checkAndAnnounceFuelLevel();

    // 5. Determine status string
    // TODO: match it after getting the specific meaning from the SEEEX
    // QString statusStr = "NORMAL";
    // if (status.fault_id != 0) {
    //     statusStr = "FAULT";
    // } else if (_highestTemperatureFact.rawValue().toDouble() > 80.0) {
    //     statusStr = "HIGH_TEMP";
    // } else if (_loadVoltageFact.rawValue().toDouble() < 20.0 && _loadVoltageFact.rawValue().toDouble() > 0) {
    //     statusStr = "LOW_VOLTAGE";
    // }
    // _statusFact.setRawValue(statusStr);
}