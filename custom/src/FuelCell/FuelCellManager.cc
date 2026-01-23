#include "FuelCellManager.h"
#include <QtMath>
#include <QDebug>

FuelCellManager::FuelCellManager(QObject *parent)
    : QObject(parent)
    , _avgEfficiencySum(0.0)
    , _efficiencySampleCount(0)
    , _minVoltage(999.0)
    , _maxTemperature(-999.0)
{
    connect(&_efficiencyCalcTimer, &QTimer::timeout, this, &FuelCellManager::_calculateEfficiency);
    _efficiencyCalcTimer.start(1000); // 每秒计算一次效率
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

    // 计算功率输出
    data.power_output = status.voltage_v * status.current_a;

    // 计算效率
    if (status.current_a > 0 && status.voltage_v > 0) {
        // 使用氢气压力变化来估算氢气消耗量
        double hydrogen_consumption_rate = status.hydrogen_pressure_bar * 0.001; // 简化计算
        data.efficiency = (data.power_output) / (hydrogen_consumption_rate * 33.3); // 33.3 kWh/kg为氢气能量密度
    } else {
        data.efficiency = 0.0;
    }

    // 估算剩余运行时间（小时）
    if (status.current_a > 0.1) { // 避免除零
        double remaining_capacity = (status.hydrogen_pressure_bar / 350.0) * 100.0; // 350bar为满压
        data.remaining_time_hours = remaining_capacity / status.current_a;
    } else {
        data.remaining_time_hours = 0.0;
    }

    // 生成状态描述
    if (status.fault_flags != 0) {
        data.status_description = "FAULT";
    } else if (status.stack_temperature_c > 80) {
        data.status_description = "HIGH_TEMP";
    } else if (status.voltage_v < 20.0) {
        data.status_description = "LOW_VOLTAGE";
    } else {
        data.status_description = "NORMAL";
    }

    // 保存数据
    _lastProcessedData = data;

    // 添加到历史队列（保留最近100个数据点）
    _dataHistory.enqueue(data);
    if (_dataHistory.size() > 100) {
        _dataHistory.dequeue();
    }

    // 更新统计信息
    _updateStatistics();

    // 发射信号
    emit processedDataUpdated(data);

    // 检查警报条件
    if (data.efficiency < 0.3) { // 效率低于30%
        emit efficiencyAlert(data.efficiency);
    }
    if (data.stack_temperature > 80) {
        emit temperatureAlert(data.stack_temperature);
    }
    if (data.hydrogen_pressure < 50) { // 压力过低
        emit pressureAlert(data.hydrogen_pressure);
    }
    if (data.fault_flags != 0) {
        emit faultDetected(data.fault_flags);
    }
}

void FuelCellManager::_updateStatistics()
{
    if (_dataHistory.isEmpty()) return;

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

void FuelCellManager::_calculateEfficiency()
{
    // 这里可以根据历史数据计算更精确的效率值
    if (_dataHistory.size() >= 2) {
        auto recent = _dataHistory.last();
        auto prev = _dataHistory[_dataHistory.size() - 2];

        if (recent.current > 0 && recent.voltage > 0) {
            double instantaneous_efficiency = (recent.voltage * recent.current) /
                                            (recent.hydrogen_pressure * 0.1); // 简化计算

            _avgEfficiencySum += instantaneous_efficiency;
            _efficiencySampleCount++;

            _lastProcessedData.efficiency = instantaneous_efficiency;
        }
    }
}
