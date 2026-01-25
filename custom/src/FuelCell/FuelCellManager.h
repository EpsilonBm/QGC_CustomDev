#pragma once

#include <QObject>
#include <QTimer>
#include <QQueue>
#include <QDateTime>
#include "mavlink_types.h"
#include "all/mavlink.h"
#include "custom_messages/mavlink_msg_fuel_cell_status.h"

class FuelCellManager : public QObject
{
    Q_OBJECT

public:
    explicit FuelCellManager(QObject *parent = nullptr);

    struct ProcessedFuelCellData {
        QDateTime timestamp;
        double voltage;
        double current;
        double hydrogen_pressure;
        double stack_temperature;
        double efficiency;
        double remaining_time_hours;
        double power_output;  // 瞬时功率
        QString status_description;
        uint32_t fault_flags;

        // 统计数据
        double avg_efficiency;
        double min_voltage;
        double max_temperature;
    };

    Q_INVOKABLE ProcessedFuelCellData getLastProcessedData() const { return _lastProcessedData; }

    // 设置氢气瓶容量和最大电量
    void setBottleCapacity(double capacity, double maxEnergy);

    // QML可访问的方法
    Q_INVOKABLE QString getLastEfficiency() const;
    Q_INVOKABLE QString getLastRemainingTime() const;
    Q_INVOKABLE QString getLastStatus() const;
    Q_INVOKABLE QString getLastVoltage() const;
    Q_INVOKABLE QString getLastCurrent() const;
    Q_INVOKABLE QString getLastPressure() const;
    Q_INVOKABLE QString getLastTemperature() const;
    Q_INVOKABLE QString getAveragePower() const;
    Q_INVOKABLE QString getRemainingEnergy() const;

signals:
    void processedDataUpdated(const ProcessedFuelCellData& data);
    void efficiencyAlert(double efficiency);
    void temperatureAlert(double temperature);
    void pressureAlert(double pressure);
    void faultDetected(uint32_t fault_flags);

public slots:
    void handleFuelCellStatus(const mavlink_fuel_cell_status_t& status);

private:
    ProcessedFuelCellData _lastProcessedData;
    QQueue<ProcessedFuelCellData> _dataHistory;

    // 统计数据
    double _avgEfficiencySum;
    int _efficiencySampleCount;
    double _minVoltage;
    double _maxTemperature;

    // 燃料电池参数
    double _bottleCapacity;      // 氢气瓶容量 (L)
    double _maxEnergy;           // 最大电量 (kWh)
    double _avgPower;            // 平均功率 (kW)
    QQueue<double> _powerHistory; // 功率历史数据队列
};
