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
{
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
}

void FuelCellFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_FUEL_CELL_STATUS) {
        return;
    }

    mavlink_fuel_cell_status_t status;
    mavlink_msg_fuel_cell_status_decode(&message, &status);

    _systemStatusFact.setRawValue(status.system_status);
    _loadVoltageFact.setRawValue(status.load_voltage / 100.0);
    _errorCodeFact.setRawValue(status.error_code);
    _highestTemperatureIdFact.setRawValue(status.highest_temperature_id);
    _highestTemperatureFact.setRawValue(status.highest_temperature / 100.0);
    _highestFanSpeedFact.setRawValue(status.highest_fan_speed);
    _lowestVoltageIdFact.setRawValue(status.lowest_voltage_id);
    _lowestVoltageFact.setRawValue(status.lowest_voltage / 100.0);
    _faultIdFact.setRawValue(status.fault_id);
    _faultDcFlagFact.setRawValue(status.fault_dc_flag);
    _faultFcFlagFact.setRawValue(status.fault_fc_flag);
    _dcOutputCurrentFact.setRawValue(status.dc_output_current / 100.0);
    _dcInputPowerFact.setRawValue(status.dc_input_power / 100.0);
    _dcOutputPowerFact.setRawValue(status.dc_output_power / 100.0);
    _pressureLowestIdFact.setRawValue(status.pressure_lowest_id);
    _pressureLowestFact.setRawValue(status.pressure_lowest / 100.0);
    _pressureTotalFact.setRawValue(status.pressure_total / 100.0);
}