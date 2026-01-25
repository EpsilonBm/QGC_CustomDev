#include "FuelCellManager.h"
#include <QtMath>
#include <QDebug>

FuelCellManager::FuelCellManager(QObject *parent)
    : QObject(parent)
    , _avgEfficiencySum(0.0)
    , _efficiencySampleCount(0)
    , _minVoltage(999.0)
    , _maxTemperature(-999.0)
    , _bottleCapacity(9.0)      // 默认9L氢气瓶
    , _maxEnergy(3.0)           // 默认3度电
    , _avgPower(0.0)            // 平均功率初始化为0
{
}

void FuelCellManager::setBottleCapacity(double capacity, double maxEnergy)
{
    _bottleCapacity = capacity;
    _maxEnergy = maxEnergy;
}

void FuelCellManager::handleFuelCellStatus(const mavlink_fuel_cell_status_t& status)
{
    ProcessedFuelCellData data;
    data.timestamp = QDateTime::currentDateTime();
    data.voltage = status.voltage_v;
    data.current = status.current_a;
    data.hydrogen_pressure = status.hydrogen_pressure_bar;
    data.stack_temperature = status.stack_temperature_c;
    data.fault_flags = status.fault_flags;

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

    // 设置计算结果
    data.power_output = instantaneous_power_kw * 1000; // 瞬时功率 (W)
    data.efficiency = 0.0; // 在新逻辑中暂时不计算效率
    data.remaining_time_hours = remaining_time_hours;

    // 6. 生成状态描述
    if (status.fault_flags != 0) {
        data.status_description = "FAULT";
    } else if (status.stack_temperature_c > 80) {
        data.status_description = "HIGH_TEMP";
    } else if (status.voltage_v < 20.0) {
        data.status_description = "LOW_VOLTAGE";
    } else {
        data.status_description = "NORMAL";
    }

    // 7. 保存数据
    _lastProcessedData = data;

    // 8. 添加到历史队列（保留最近100个数据点）
    _dataHistory.enqueue(data);
    if (_dataHistory.size() > 100) {
        _dataHistory.dequeue();
    }

    // 9. 更新统计信息
    if (!_dataHistory.isEmpty()) {
        // 计算平均值
        double voltage_sum = 0, temp_sum = 0;
        int count = _dataHistory.size();

        for (const auto& data : _dataHistory) {
            voltage_sum += data.voltage;
            temp_sum += data.stack_temperature;

            if (data.voltage < _minVoltage) _minVoltage = data.voltage;
            if (data.stack_temperature > _maxTemperature) _maxTemperature = data.stack_temperature;
        }

        _lastProcessedData.avg_efficiency = _avgEfficiencySum /
                                           (_efficiencySampleCount > 0 ? _efficiencySampleCount : 1);
        _lastProcessedData.min_voltage = _minVoltage;
        _lastProcessedData.max_temperature = _maxTemperature;
    }

    // 10. 发射信号
    emit processedDataUpdated(data);

    // 11. 检查警报条件
    if (data.stack_temperature > 80) {
        emit temperatureAlert(data.stack_temperature);
    }
    if (status.fault_flags != 0) {
        emit faultDetected(data.fault_flags);
    }
}

// QML可访问的方法实现
QString FuelCellManager::getLastEfficiency() const
{
    return QString::number(_lastProcessedData.efficiency, 'f', 2);
}

QString FuelCellManager::getLastRemainingTime() const
{
    return QString::number(_lastProcessedData.remaining_time_hours, 'f', 2);
}

QString FuelCellManager::getLastStatus() const
{
    return _lastProcessedData.status_description;
}

QString FuelCellManager::getLastVoltage() const
{
    return QString::number(_lastProcessedData.voltage, 'f', 2);
}

QString FuelCellManager::getLastCurrent() const
{
    return QString::number(_lastProcessedData.current, 'f', 2);
}

QString FuelCellManager::getLastPressure() const
{
    return QString::number(_lastProcessedData.hydrogen_pressure, 'f', 2);
}

QString FuelCellManager::getLastTemperature() const
{
    return QString::number(_lastProcessedData.stack_temperature, 'f', 2);
}

QString FuelCellManager::getAveragePower() const
{
    return QString::number(_avgPower * 1000, 'f', 2); // 转换回瓦特显示
}

QString FuelCellManager::getRemainingEnergy() const
{
    // 压强转换为百分比 (2-35 bar 对应 0%-100%)
    double min_pressure = 2.0;  // 最小有效压力
    double max_pressure = 35.0; // 最大压力
    double pressure_range = max_pressure - min_pressure; // 压力范围: 33.0 bar

    // 将实际压力映射到0-100%范围内
    double percentage = qBound(0.0,
        ((_lastProcessedData.hydrogen_pressure - min_pressure) / pressure_range) * 100.0,
        100.0);

    double remaining_energy = (_maxEnergy * percentage) / 100.0;
    return QString::number(remaining_energy, 'f', 2);
}
