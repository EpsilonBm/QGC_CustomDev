#include "FuelCellFactGroup.h"
#include "Vehicle.h"

const char* FuelCellFactGroup::_systemStatusFactName = "systemStatus";
const char* FuelCellFactGroup::_loadVoltageFactName = "loadVoltage";
const char* FuelCellFactGroup::_errorCodeFactName = "errorCode";
const char* FuelCellFactGroup::_highestTemperatureIdFactName = "highestTemperatureId";
const char* FuelCellFactGroup::_highestTemperatureFactName = "highestTemperature";
const char* FuelCellFactGroup::_highestFanSpeedFactName = "highestFanSpeed";
const char* FuelCellFactGroup::_lowestVoltageIdFactName = "lowestVoltageId";
const char* FuelCellFactGroup::_lowestVoltageFactName = "lowestVoltage";
const char* FuelCellFactGroup::_faultIdFactName = "faultId";
const char* FuelCellFactGroup::_faultDcFlagFactName = "faultDcFlag";
const char* FuelCellFactGroup::_faultFcFlagFactName = "faultFcFlag";
const char* FuelCellFactGroup::_dcOutputCurrentFactName = "dcOutputCurrent";
const char* FuelCellFactGroup::_dcInputPowerFactName = "dcInputPower";
const char* FuelCellFactGroup::_dcOutputPowerFactName = "dcOutputPower";
const char* FuelCellFactGroup::_pressureLowestIdFactName = "pressureLowestId";
const char* FuelCellFactGroup::_pressureLowestFactName = "pressureLowest";
const char* FuelCellFactGroup::_pressureTotalFactName = "pressureTotal";

FuelCellFactGroup::FuelCellFactGroup(QObject* parent)
    : VehicleFactGroup(parent)
{
    _factNames << _systemStatusFactName << _loadVoltageFactName << _errorCodeFactName << _highestTemperatureIdFactName
               << _highestTemperatureFactName << _highestFanSpeedFactName << _lowestVoltageIdFactName << _lowestVoltageFactName
               << _faultIdFactName << _faultDcFlagFactName << _faultFcFlagFactName << _dcOutputCurrentFactName
               << _dcInputPowerFactName << _dcOutputPowerFactName << _pressureLowestIdFactName << _pressureLowestFactName
               << _pressureTotalFactName;

    _initFacts(1, ":/json/Vehicle/FuelCellFact.json");

    _systemStatusFact         = _createFact(0, _systemStatusFactName);
    _loadVoltageFact          = _createFact(0, _loadVoltageFactName);
    _errorCodeFact            = _createFact(0, _errorCodeFactName);
    _highestTemperatureIdFact = _createFact(0, _highestTemperatureIdFactName);
    _highestTemperatureFact   = _createFact(0, _highestTemperatureFactName);
    _highestFanSpeedFact      = _createFact(0, _highestFanSpeedFactName);
    _lowestVoltageIdFact      = _createFact(0, _lowestVoltageIdFactName);
    _lowestVoltageFact        = _createFact(0, _lowestVoltageFactName);
    _faultIdFact              = _createFact(0, _faultIdFactName);
    _faultDcFlagFact          = _createFact(0, _faultDcFlagFactName);
    _faultFcFlagFact          = _createFact(0, _faultFcFlagFactName);
    _dcOutputCurrentFact      = _createFact(0, _dcOutputCurrentFactName);
    _dcInputPowerFact         = _createFact(0, _dcInputPowerFactName);
    _dcOutputPowerFact        = _createFact(0, _dcOutputPowerFactName);
    _pressureLowestIdFact     = _createFact(0, _pressureLowestIdFactName);
    _pressureLowestFact       = _createFact(0, _pressureLowestFactName);
    _pressureTotalFact        = _createFact(0, _pressureTotalFactName);
}

void FuelCellFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    if (message.msgid != MAVLINK_MSG_ID_FUEL_CELL_STATUS) {
        return;
    }

    mavlink_fuel_cell_status_t status;
    mavlink_msg_fuel_cell_status_decode(&message, &status);

    // Note: The scaling factor (e.g., / 100.0) should match the actual data format from your device.
    // I'm assuming a scaling of 100 for values that are likely not integers.

    _systemStatusFact->setRawValue(status.system_status);
    _loadVoltageFact->setRawValue(status.load_voltage / 100.0);
    _errorCodeFact->setRawValue(status.error_code);
    _highestTemperatureIdFact->setRawValue(status.highest_temperature_id);
    _highestTemperatureFact->setRawValue(status.highest_temperature / 100.0);
    _highestFanSpeedFact->setRawValue(status.highest_fan_speed);
    _lowestVoltageIdFact->setRawValue(status.lowest_voltage_id);
    _lowestVoltageFact->setRawValue(status.lowest_voltage / 100.0);
    _faultIdFact->setRawValue(status.fault_id);
    _faultDcFlagFact->setRawValue(status.fault_dc_flag);
    _faultFcFlagFact->setRawValue(status.fault_fc_flag);
    _dcOutputCurrentFact->setRawValue(status.dc_output_current / 100.0);
    _dcInputPowerFact->setRawValue(status.dc_input_power / 100.0);
    _dcOutputPowerFact->setRawValue(status.dc_output_power / 100.0);
    _pressureLowestIdFact->setRawValue(status.pressure_lowest_id);
    _pressureLowestFact->setRawValue(status.pressure_lowest / 100.0);
    _pressureTotalFact->setRawValue(status.pressure_total / 100.0);
}