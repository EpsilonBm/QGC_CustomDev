#pragma once

#include <QObject>
#include <QTimer>
#include <QQueue>
#include <QDateTime>
#include "FactSystem/FactGroup.h"
#include "FactSystem/Fact.h"
#include "FactSystem/FactMetaData.h"
#include "mavlink_types.h"
#include "all/mavlink.h"
#include "custom_messages/mavlink_msg_fuel_cell_status.h"

class FuelCellManager : public FactGroup
{
    Q_OBJECT

public:
    explicit FuelCellManager(QObject *parent = nullptr);

    // 设置氢气瓶容量和最大电量
    void setBottleCapacity(double capacity, double maxEnergy);

    // Fact 访问器 (C++侧使用，QML侧直接通过属性名访问)
    Fact* voltage() { return _voltageFact; }
    Fact* current() { return _currentFact; }
    Fact* pressure() { return _pressureFact; }
    Fact* temperature() { return _temperatureFact; }
    Fact* power() { return _powerFact; }
    Fact* remainingEnergy() { return _remainingEnergyFact; }
    Fact* remainingTime() { return _remainingTimeFact; }
    Fact* percentRemaining() { return _percentRemainingFact; }
    Fact* status() { return _statusFact; }
    Fact* bottleCapacity() { return _bottleCapacityFact; }

signals:
    // FactGroup 会自动处理 Fact 值的变化信号
    // 我们保留特定的报警信号
    void efficiencyAlert(double efficiency);
    void temperatureAlert(double temperature);
    void pressureAlert(double pressure);
    void faultDetected(uint32_t fault_flags);

public slots:
    void handleFuelCellStatus(const mavlink_fuel_cell_status_t& status);

private:
    void _initFacts();

    // Facts
    Fact* _voltageFact;
    Fact* _currentFact;
    Fact* _pressureFact;
    Fact* _temperatureFact;
    Fact* _powerFact;
    Fact* _remainingEnergyFact;
    Fact* _remainingTimeFact;
    Fact* _percentRemainingFact;
    Fact* _statusFact;
    Fact* _bottleCapacityFact;

    // 燃料电池参数
    double _bottleCapacity;      // 氢气瓶容量 (L)
    double _maxEnergy;           // 最大电量 (kWh)
    double _avgPower;            // 平均功率 (kW)
    QQueue<double> _powerHistory; // 功率历史数据队列
};
