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
        double power_output;
        QString status_description;
        uint32_t fault_flags;

        // 统计数据
        double avg_efficiency;
        double min_voltage;
        double max_temperature;
    };

    Q_INVOKABLE ProcessedFuelCellData getLastProcessedData() const { return _lastProcessedData; }

signals:
    void processedDataUpdated(const ProcessedFuelCellData& data);
    void efficiencyAlert(double efficiency);
    void temperatureAlert(double temperature);
    void pressureAlert(double pressure);
    void faultDetected(uint32_t fault_flags);

public slots:
    void handleFuelCellStatus(const mavlink_fuel_cell_status_t& status);

private slots:
    void _calculateEfficiency();
    void _updateStatistics();

private:
    ProcessedFuelCellData _lastProcessedData;
    QQueue<ProcessedFuelCellData> _dataHistory;
    QTimer _efficiencyCalcTimer;

    // 统计数据
    double _avgEfficiencySum;
    int _efficiencySampleCount;
    double _minVoltage;
    double _maxTemperature;
};
