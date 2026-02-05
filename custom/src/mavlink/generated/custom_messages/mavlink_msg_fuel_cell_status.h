#pragma once
// MESSAGE FUEL_CELL_STATUS PACKING

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS 12921


typedef struct __mavlink_fuel_cell_status_t {
 uint16_t system_status; /*<  System Status*/
 uint16_t load_voltage; /*<  Load Voltage*/
 uint16_t error_code; /*<  Error Code*/
 uint16_t highest_temperature_id; /*<  Stack Temperature Highest ID*/
 uint16_t highest_temperature; /*<  Stack Temperature Highest Temperature*/
 uint16_t highest_fan_speed; /*<  Stack Temperature Highest Fan Speed*/
 uint16_t lowest_voltage_id; /*<  Stack Voltage Lowest ID*/
 uint16_t lowest_voltage; /*<  Stack Voltage Lowest Voltage*/
 uint16_t fault_id; /*<  Fault ID*/
 uint16_t fault_dc_flag; /*<  Fault DC Flag*/
 uint16_t fault_fc_flag; /*<  Fault FC Flag*/
 uint16_t dc_output_current; /*<  DC Output Total Current*/
 uint16_t dc_input_power; /*<  DC Input Total Power*/
 uint16_t dc_output_power; /*<  DC Output Total Power*/
 uint16_t pressure_lowest_id; /*<  Hydrogen Bottle Pressure Lowest ID*/
 uint16_t pressure_lowest; /*<  Hydrogen Bottle Pressure Lowest Pressure*/
 uint16_t pressure_total; /*<  Hydrogen Bottle Pressure Total*/
} mavlink_fuel_cell_status_t;

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN 34
#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN 34
#define MAVLINK_MSG_ID_12921_LEN 34
#define MAVLINK_MSG_ID_12921_MIN_LEN 34

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC 201
#define MAVLINK_MSG_ID_12921_CRC 201



#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_STATUS { \
    12921, \
    "FUEL_CELL_STATUS", \
    17, \
    {  { "system_status", NULL, MAVLINK_TYPE_UINT16_T, 0, 0, offsetof(mavlink_fuel_cell_status_t, system_status) }, \
         { "load_voltage", NULL, MAVLINK_TYPE_UINT16_T, 0, 2, offsetof(mavlink_fuel_cell_status_t, load_voltage) }, \
         { "error_code", NULL, MAVLINK_TYPE_UINT16_T, 0, 4, offsetof(mavlink_fuel_cell_status_t, error_code) }, \
         { "highest_temperature_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 6, offsetof(mavlink_fuel_cell_status_t, highest_temperature_id) }, \
         { "highest_temperature", NULL, MAVLINK_TYPE_UINT16_T, 0, 8, offsetof(mavlink_fuel_cell_status_t, highest_temperature) }, \
         { "highest_fan_speed", NULL, MAVLINK_TYPE_UINT16_T, 0, 10, offsetof(mavlink_fuel_cell_status_t, highest_fan_speed) }, \
         { "lowest_voltage_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 12, offsetof(mavlink_fuel_cell_status_t, lowest_voltage_id) }, \
         { "lowest_voltage", NULL, MAVLINK_TYPE_UINT16_T, 0, 14, offsetof(mavlink_fuel_cell_status_t, lowest_voltage) }, \
         { "fault_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 16, offsetof(mavlink_fuel_cell_status_t, fault_id) }, \
         { "fault_dc_flag", NULL, MAVLINK_TYPE_UINT16_T, 0, 18, offsetof(mavlink_fuel_cell_status_t, fault_dc_flag) }, \
         { "fault_fc_flag", NULL, MAVLINK_TYPE_UINT16_T, 0, 20, offsetof(mavlink_fuel_cell_status_t, fault_fc_flag) }, \
         { "dc_output_current", NULL, MAVLINK_TYPE_UINT16_T, 0, 22, offsetof(mavlink_fuel_cell_status_t, dc_output_current) }, \
         { "dc_input_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 24, offsetof(mavlink_fuel_cell_status_t, dc_input_power) }, \
         { "dc_output_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 26, offsetof(mavlink_fuel_cell_status_t, dc_output_power) }, \
         { "pressure_lowest_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 28, offsetof(mavlink_fuel_cell_status_t, pressure_lowest_id) }, \
         { "pressure_lowest", NULL, MAVLINK_TYPE_UINT16_T, 0, 30, offsetof(mavlink_fuel_cell_status_t, pressure_lowest) }, \
         { "pressure_total", NULL, MAVLINK_TYPE_UINT16_T, 0, 32, offsetof(mavlink_fuel_cell_status_t, pressure_total) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_STATUS { \
    "FUEL_CELL_STATUS", \
    17, \
    {  { "system_status", NULL, MAVLINK_TYPE_UINT16_T, 0, 0, offsetof(mavlink_fuel_cell_status_t, system_status) }, \
         { "load_voltage", NULL, MAVLINK_TYPE_UINT16_T, 0, 2, offsetof(mavlink_fuel_cell_status_t, load_voltage) }, \
         { "error_code", NULL, MAVLINK_TYPE_UINT16_T, 0, 4, offsetof(mavlink_fuel_cell_status_t, error_code) }, \
         { "highest_temperature_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 6, offsetof(mavlink_fuel_cell_status_t, highest_temperature_id) }, \
         { "highest_temperature", NULL, MAVLINK_TYPE_UINT16_T, 0, 8, offsetof(mavlink_fuel_cell_status_t, highest_temperature) }, \
         { "highest_fan_speed", NULL, MAVLINK_TYPE_UINT16_T, 0, 10, offsetof(mavlink_fuel_cell_status_t, highest_fan_speed) }, \
         { "lowest_voltage_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 12, offsetof(mavlink_fuel_cell_status_t, lowest_voltage_id) }, \
         { "lowest_voltage", NULL, MAVLINK_TYPE_UINT16_T, 0, 14, offsetof(mavlink_fuel_cell_status_t, lowest_voltage) }, \
         { "fault_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 16, offsetof(mavlink_fuel_cell_status_t, fault_id) }, \
         { "fault_dc_flag", NULL, MAVLINK_TYPE_UINT16_T, 0, 18, offsetof(mavlink_fuel_cell_status_t, fault_dc_flag) }, \
         { "fault_fc_flag", NULL, MAVLINK_TYPE_UINT16_T, 0, 20, offsetof(mavlink_fuel_cell_status_t, fault_fc_flag) }, \
         { "dc_output_current", NULL, MAVLINK_TYPE_UINT16_T, 0, 22, offsetof(mavlink_fuel_cell_status_t, dc_output_current) }, \
         { "dc_input_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 24, offsetof(mavlink_fuel_cell_status_t, dc_input_power) }, \
         { "dc_output_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 26, offsetof(mavlink_fuel_cell_status_t, dc_output_power) }, \
         { "pressure_lowest_id", NULL, MAVLINK_TYPE_UINT16_T, 0, 28, offsetof(mavlink_fuel_cell_status_t, pressure_lowest_id) }, \
         { "pressure_lowest", NULL, MAVLINK_TYPE_UINT16_T, 0, 30, offsetof(mavlink_fuel_cell_status_t, pressure_lowest) }, \
         { "pressure_total", NULL, MAVLINK_TYPE_UINT16_T, 0, 32, offsetof(mavlink_fuel_cell_status_t, pressure_total) }, \
         } \
}
#endif

/**
 * @brief Pack a fuel_cell_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param system_status  System Status
 * @param load_voltage  Load Voltage
 * @param error_code  Error Code
 * @param highest_temperature_id  Stack Temperature Highest ID
 * @param highest_temperature  Stack Temperature Highest Temperature
 * @param highest_fan_speed  Stack Temperature Highest Fan Speed
 * @param lowest_voltage_id  Stack Voltage Lowest ID
 * @param lowest_voltage  Stack Voltage Lowest Voltage
 * @param fault_id  Fault ID
 * @param fault_dc_flag  Fault DC Flag
 * @param fault_fc_flag  Fault FC Flag
 * @param dc_output_current  DC Output Total Current
 * @param dc_input_power  DC Input Total Power
 * @param dc_output_power  DC Output Total Power
 * @param pressure_lowest_id  Hydrogen Bottle Pressure Lowest ID
 * @param pressure_lowest  Hydrogen Bottle Pressure Lowest Pressure
 * @param pressure_total  Hydrogen Bottle Pressure Total
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint16_t system_status, uint16_t load_voltage, uint16_t error_code, uint16_t highest_temperature_id, uint16_t highest_temperature, uint16_t highest_fan_speed, uint16_t lowest_voltage_id, uint16_t lowest_voltage, uint16_t fault_id, uint16_t fault_dc_flag, uint16_t fault_fc_flag, uint16_t dc_output_current, uint16_t dc_input_power, uint16_t dc_output_power, uint16_t pressure_lowest_id, uint16_t pressure_lowest, uint16_t pressure_total)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint16_t(buf, 0, system_status);
    _mav_put_uint16_t(buf, 2, load_voltage);
    _mav_put_uint16_t(buf, 4, error_code);
    _mav_put_uint16_t(buf, 6, highest_temperature_id);
    _mav_put_uint16_t(buf, 8, highest_temperature);
    _mav_put_uint16_t(buf, 10, highest_fan_speed);
    _mav_put_uint16_t(buf, 12, lowest_voltage_id);
    _mav_put_uint16_t(buf, 14, lowest_voltage);
    _mav_put_uint16_t(buf, 16, fault_id);
    _mav_put_uint16_t(buf, 18, fault_dc_flag);
    _mav_put_uint16_t(buf, 20, fault_fc_flag);
    _mav_put_uint16_t(buf, 22, dc_output_current);
    _mav_put_uint16_t(buf, 24, dc_input_power);
    _mav_put_uint16_t(buf, 26, dc_output_power);
    _mav_put_uint16_t(buf, 28, pressure_lowest_id);
    _mav_put_uint16_t(buf, 30, pressure_lowest);
    _mav_put_uint16_t(buf, 32, pressure_total);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.system_status = system_status;
    packet.load_voltage = load_voltage;
    packet.error_code = error_code;
    packet.highest_temperature_id = highest_temperature_id;
    packet.highest_temperature = highest_temperature;
    packet.highest_fan_speed = highest_fan_speed;
    packet.lowest_voltage_id = lowest_voltage_id;
    packet.lowest_voltage = lowest_voltage;
    packet.fault_id = fault_id;
    packet.fault_dc_flag = fault_dc_flag;
    packet.fault_fc_flag = fault_fc_flag;
    packet.dc_output_current = dc_output_current;
    packet.dc_input_power = dc_input_power;
    packet.dc_output_power = dc_output_power;
    packet.pressure_lowest_id = pressure_lowest_id;
    packet.pressure_lowest = pressure_lowest;
    packet.pressure_total = pressure_total;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_STATUS;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
}

/**
 * @brief Pack a fuel_cell_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param system_status  System Status
 * @param load_voltage  Load Voltage
 * @param error_code  Error Code
 * @param highest_temperature_id  Stack Temperature Highest ID
 * @param highest_temperature  Stack Temperature Highest Temperature
 * @param highest_fan_speed  Stack Temperature Highest Fan Speed
 * @param lowest_voltage_id  Stack Voltage Lowest ID
 * @param lowest_voltage  Stack Voltage Lowest Voltage
 * @param fault_id  Fault ID
 * @param fault_dc_flag  Fault DC Flag
 * @param fault_fc_flag  Fault FC Flag
 * @param dc_output_current  DC Output Total Current
 * @param dc_input_power  DC Input Total Power
 * @param dc_output_power  DC Output Total Power
 * @param pressure_lowest_id  Hydrogen Bottle Pressure Lowest ID
 * @param pressure_lowest  Hydrogen Bottle Pressure Lowest Pressure
 * @param pressure_total  Hydrogen Bottle Pressure Total
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint16_t system_status, uint16_t load_voltage, uint16_t error_code, uint16_t highest_temperature_id, uint16_t highest_temperature, uint16_t highest_fan_speed, uint16_t lowest_voltage_id, uint16_t lowest_voltage, uint16_t fault_id, uint16_t fault_dc_flag, uint16_t fault_fc_flag, uint16_t dc_output_current, uint16_t dc_input_power, uint16_t dc_output_power, uint16_t pressure_lowest_id, uint16_t pressure_lowest, uint16_t pressure_total)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint16_t(buf, 0, system_status);
    _mav_put_uint16_t(buf, 2, load_voltage);
    _mav_put_uint16_t(buf, 4, error_code);
    _mav_put_uint16_t(buf, 6, highest_temperature_id);
    _mav_put_uint16_t(buf, 8, highest_temperature);
    _mav_put_uint16_t(buf, 10, highest_fan_speed);
    _mav_put_uint16_t(buf, 12, lowest_voltage_id);
    _mav_put_uint16_t(buf, 14, lowest_voltage);
    _mav_put_uint16_t(buf, 16, fault_id);
    _mav_put_uint16_t(buf, 18, fault_dc_flag);
    _mav_put_uint16_t(buf, 20, fault_fc_flag);
    _mav_put_uint16_t(buf, 22, dc_output_current);
    _mav_put_uint16_t(buf, 24, dc_input_power);
    _mav_put_uint16_t(buf, 26, dc_output_power);
    _mav_put_uint16_t(buf, 28, pressure_lowest_id);
    _mav_put_uint16_t(buf, 30, pressure_lowest);
    _mav_put_uint16_t(buf, 32, pressure_total);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.system_status = system_status;
    packet.load_voltage = load_voltage;
    packet.error_code = error_code;
    packet.highest_temperature_id = highest_temperature_id;
    packet.highest_temperature = highest_temperature;
    packet.highest_fan_speed = highest_fan_speed;
    packet.lowest_voltage_id = lowest_voltage_id;
    packet.lowest_voltage = lowest_voltage;
    packet.fault_id = fault_id;
    packet.fault_dc_flag = fault_dc_flag;
    packet.fault_fc_flag = fault_fc_flag;
    packet.dc_output_current = dc_output_current;
    packet.dc_input_power = dc_input_power;
    packet.dc_output_power = dc_output_power;
    packet.pressure_lowest_id = pressure_lowest_id;
    packet.pressure_lowest = pressure_lowest;
    packet.pressure_total = pressure_total;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_STATUS;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#endif
}

/**
 * @brief Pack a fuel_cell_status message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param system_status  System Status
 * @param load_voltage  Load Voltage
 * @param error_code  Error Code
 * @param highest_temperature_id  Stack Temperature Highest ID
 * @param highest_temperature  Stack Temperature Highest Temperature
 * @param highest_fan_speed  Stack Temperature Highest Fan Speed
 * @param lowest_voltage_id  Stack Voltage Lowest ID
 * @param lowest_voltage  Stack Voltage Lowest Voltage
 * @param fault_id  Fault ID
 * @param fault_dc_flag  Fault DC Flag
 * @param fault_fc_flag  Fault FC Flag
 * @param dc_output_current  DC Output Total Current
 * @param dc_input_power  DC Input Total Power
 * @param dc_output_power  DC Output Total Power
 * @param pressure_lowest_id  Hydrogen Bottle Pressure Lowest ID
 * @param pressure_lowest  Hydrogen Bottle Pressure Lowest Pressure
 * @param pressure_total  Hydrogen Bottle Pressure Total
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint16_t system_status,uint16_t load_voltage,uint16_t error_code,uint16_t highest_temperature_id,uint16_t highest_temperature,uint16_t highest_fan_speed,uint16_t lowest_voltage_id,uint16_t lowest_voltage,uint16_t fault_id,uint16_t fault_dc_flag,uint16_t fault_fc_flag,uint16_t dc_output_current,uint16_t dc_input_power,uint16_t dc_output_power,uint16_t pressure_lowest_id,uint16_t pressure_lowest,uint16_t pressure_total)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint16_t(buf, 0, system_status);
    _mav_put_uint16_t(buf, 2, load_voltage);
    _mav_put_uint16_t(buf, 4, error_code);
    _mav_put_uint16_t(buf, 6, highest_temperature_id);
    _mav_put_uint16_t(buf, 8, highest_temperature);
    _mav_put_uint16_t(buf, 10, highest_fan_speed);
    _mav_put_uint16_t(buf, 12, lowest_voltage_id);
    _mav_put_uint16_t(buf, 14, lowest_voltage);
    _mav_put_uint16_t(buf, 16, fault_id);
    _mav_put_uint16_t(buf, 18, fault_dc_flag);
    _mav_put_uint16_t(buf, 20, fault_fc_flag);
    _mav_put_uint16_t(buf, 22, dc_output_current);
    _mav_put_uint16_t(buf, 24, dc_input_power);
    _mav_put_uint16_t(buf, 26, dc_output_power);
    _mav_put_uint16_t(buf, 28, pressure_lowest_id);
    _mav_put_uint16_t(buf, 30, pressure_lowest);
    _mav_put_uint16_t(buf, 32, pressure_total);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.system_status = system_status;
    packet.load_voltage = load_voltage;
    packet.error_code = error_code;
    packet.highest_temperature_id = highest_temperature_id;
    packet.highest_temperature = highest_temperature;
    packet.highest_fan_speed = highest_fan_speed;
    packet.lowest_voltage_id = lowest_voltage_id;
    packet.lowest_voltage = lowest_voltage;
    packet.fault_id = fault_id;
    packet.fault_dc_flag = fault_dc_flag;
    packet.fault_fc_flag = fault_fc_flag;
    packet.dc_output_current = dc_output_current;
    packet.dc_input_power = dc_input_power;
    packet.dc_output_power = dc_output_power;
    packet.pressure_lowest_id = pressure_lowest_id;
    packet.pressure_lowest = pressure_lowest;
    packet.pressure_total = pressure_total;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_STATUS;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
}

/**
 * @brief Encode a fuel_cell_status struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_status_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_fuel_cell_status_t* fuel_cell_status)
{
    return mavlink_msg_fuel_cell_status_pack(system_id, component_id, msg, fuel_cell_status->system_status, fuel_cell_status->load_voltage, fuel_cell_status->error_code, fuel_cell_status->highest_temperature_id, fuel_cell_status->highest_temperature, fuel_cell_status->highest_fan_speed, fuel_cell_status->lowest_voltage_id, fuel_cell_status->lowest_voltage, fuel_cell_status->fault_id, fuel_cell_status->fault_dc_flag, fuel_cell_status->fault_fc_flag, fuel_cell_status->dc_output_current, fuel_cell_status->dc_input_power, fuel_cell_status->dc_output_power, fuel_cell_status->pressure_lowest_id, fuel_cell_status->pressure_lowest, fuel_cell_status->pressure_total);
}

/**
 * @brief Encode a fuel_cell_status struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_status_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_fuel_cell_status_t* fuel_cell_status)
{
    return mavlink_msg_fuel_cell_status_pack_chan(system_id, component_id, chan, msg, fuel_cell_status->system_status, fuel_cell_status->load_voltage, fuel_cell_status->error_code, fuel_cell_status->highest_temperature_id, fuel_cell_status->highest_temperature, fuel_cell_status->highest_fan_speed, fuel_cell_status->lowest_voltage_id, fuel_cell_status->lowest_voltage, fuel_cell_status->fault_id, fuel_cell_status->fault_dc_flag, fuel_cell_status->fault_fc_flag, fuel_cell_status->dc_output_current, fuel_cell_status->dc_input_power, fuel_cell_status->dc_output_power, fuel_cell_status->pressure_lowest_id, fuel_cell_status->pressure_lowest, fuel_cell_status->pressure_total);
}

/**
 * @brief Encode a fuel_cell_status struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_status_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_fuel_cell_status_t* fuel_cell_status)
{
    return mavlink_msg_fuel_cell_status_pack_status(system_id, component_id, _status, msg,  fuel_cell_status->system_status, fuel_cell_status->load_voltage, fuel_cell_status->error_code, fuel_cell_status->highest_temperature_id, fuel_cell_status->highest_temperature, fuel_cell_status->highest_fan_speed, fuel_cell_status->lowest_voltage_id, fuel_cell_status->lowest_voltage, fuel_cell_status->fault_id, fuel_cell_status->fault_dc_flag, fuel_cell_status->fault_fc_flag, fuel_cell_status->dc_output_current, fuel_cell_status->dc_input_power, fuel_cell_status->dc_output_power, fuel_cell_status->pressure_lowest_id, fuel_cell_status->pressure_lowest, fuel_cell_status->pressure_total);
}

/**
 * @brief Send a fuel_cell_status message
 * @param chan MAVLink channel to send the message
 *
 * @param system_status  System Status
 * @param load_voltage  Load Voltage
 * @param error_code  Error Code
 * @param highest_temperature_id  Stack Temperature Highest ID
 * @param highest_temperature  Stack Temperature Highest Temperature
 * @param highest_fan_speed  Stack Temperature Highest Fan Speed
 * @param lowest_voltage_id  Stack Voltage Lowest ID
 * @param lowest_voltage  Stack Voltage Lowest Voltage
 * @param fault_id  Fault ID
 * @param fault_dc_flag  Fault DC Flag
 * @param fault_fc_flag  Fault FC Flag
 * @param dc_output_current  DC Output Total Current
 * @param dc_input_power  DC Input Total Power
 * @param dc_output_power  DC Output Total Power
 * @param pressure_lowest_id  Hydrogen Bottle Pressure Lowest ID
 * @param pressure_lowest  Hydrogen Bottle Pressure Lowest Pressure
 * @param pressure_total  Hydrogen Bottle Pressure Total
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_fuel_cell_status_send(mavlink_channel_t chan, uint16_t system_status, uint16_t load_voltage, uint16_t error_code, uint16_t highest_temperature_id, uint16_t highest_temperature, uint16_t highest_fan_speed, uint16_t lowest_voltage_id, uint16_t lowest_voltage, uint16_t fault_id, uint16_t fault_dc_flag, uint16_t fault_fc_flag, uint16_t dc_output_current, uint16_t dc_input_power, uint16_t dc_output_power, uint16_t pressure_lowest_id, uint16_t pressure_lowest, uint16_t pressure_total)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint16_t(buf, 0, system_status);
    _mav_put_uint16_t(buf, 2, load_voltage);
    _mav_put_uint16_t(buf, 4, error_code);
    _mav_put_uint16_t(buf, 6, highest_temperature_id);
    _mav_put_uint16_t(buf, 8, highest_temperature);
    _mav_put_uint16_t(buf, 10, highest_fan_speed);
    _mav_put_uint16_t(buf, 12, lowest_voltage_id);
    _mav_put_uint16_t(buf, 14, lowest_voltage);
    _mav_put_uint16_t(buf, 16, fault_id);
    _mav_put_uint16_t(buf, 18, fault_dc_flag);
    _mav_put_uint16_t(buf, 20, fault_fc_flag);
    _mav_put_uint16_t(buf, 22, dc_output_current);
    _mav_put_uint16_t(buf, 24, dc_input_power);
    _mav_put_uint16_t(buf, 26, dc_output_power);
    _mav_put_uint16_t(buf, 28, pressure_lowest_id);
    _mav_put_uint16_t(buf, 30, pressure_lowest);
    _mav_put_uint16_t(buf, 32, pressure_total);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#else
    mavlink_fuel_cell_status_t packet;
    packet.system_status = system_status;
    packet.load_voltage = load_voltage;
    packet.error_code = error_code;
    packet.highest_temperature_id = highest_temperature_id;
    packet.highest_temperature = highest_temperature;
    packet.highest_fan_speed = highest_fan_speed;
    packet.lowest_voltage_id = lowest_voltage_id;
    packet.lowest_voltage = lowest_voltage;
    packet.fault_id = fault_id;
    packet.fault_dc_flag = fault_dc_flag;
    packet.fault_fc_flag = fault_fc_flag;
    packet.dc_output_current = dc_output_current;
    packet.dc_input_power = dc_input_power;
    packet.dc_output_power = dc_output_power;
    packet.pressure_lowest_id = pressure_lowest_id;
    packet.pressure_lowest = pressure_lowest;
    packet.pressure_total = pressure_total;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, (const char *)&packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#endif
}

/**
 * @brief Send a fuel_cell_status message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_fuel_cell_status_send_struct(mavlink_channel_t chan, const mavlink_fuel_cell_status_t* fuel_cell_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_fuel_cell_status_send(chan, fuel_cell_status->system_status, fuel_cell_status->load_voltage, fuel_cell_status->error_code, fuel_cell_status->highest_temperature_id, fuel_cell_status->highest_temperature, fuel_cell_status->highest_fan_speed, fuel_cell_status->lowest_voltage_id, fuel_cell_status->lowest_voltage, fuel_cell_status->fault_id, fuel_cell_status->fault_dc_flag, fuel_cell_status->fault_fc_flag, fuel_cell_status->dc_output_current, fuel_cell_status->dc_input_power, fuel_cell_status->dc_output_power, fuel_cell_status->pressure_lowest_id, fuel_cell_status->pressure_lowest, fuel_cell_status->pressure_total);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, (const char *)fuel_cell_status, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#endif
}

#if MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by reusing
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_fuel_cell_status_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint16_t system_status, uint16_t load_voltage, uint16_t error_code, uint16_t highest_temperature_id, uint16_t highest_temperature, uint16_t highest_fan_speed, uint16_t lowest_voltage_id, uint16_t lowest_voltage, uint16_t fault_id, uint16_t fault_dc_flag, uint16_t fault_fc_flag, uint16_t dc_output_current, uint16_t dc_input_power, uint16_t dc_output_power, uint16_t pressure_lowest_id, uint16_t pressure_lowest, uint16_t pressure_total)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint16_t(buf, 0, system_status);
    _mav_put_uint16_t(buf, 2, load_voltage);
    _mav_put_uint16_t(buf, 4, error_code);
    _mav_put_uint16_t(buf, 6, highest_temperature_id);
    _mav_put_uint16_t(buf, 8, highest_temperature);
    _mav_put_uint16_t(buf, 10, highest_fan_speed);
    _mav_put_uint16_t(buf, 12, lowest_voltage_id);
    _mav_put_uint16_t(buf, 14, lowest_voltage);
    _mav_put_uint16_t(buf, 16, fault_id);
    _mav_put_uint16_t(buf, 18, fault_dc_flag);
    _mav_put_uint16_t(buf, 20, fault_fc_flag);
    _mav_put_uint16_t(buf, 22, dc_output_current);
    _mav_put_uint16_t(buf, 24, dc_input_power);
    _mav_put_uint16_t(buf, 26, dc_output_power);
    _mav_put_uint16_t(buf, 28, pressure_lowest_id);
    _mav_put_uint16_t(buf, 30, pressure_lowest);
    _mav_put_uint16_t(buf, 32, pressure_total);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#else
    mavlink_fuel_cell_status_t *packet = (mavlink_fuel_cell_status_t *)msgbuf;
    packet->system_status = system_status;
    packet->load_voltage = load_voltage;
    packet->error_code = error_code;
    packet->highest_temperature_id = highest_temperature_id;
    packet->highest_temperature = highest_temperature;
    packet->highest_fan_speed = highest_fan_speed;
    packet->lowest_voltage_id = lowest_voltage_id;
    packet->lowest_voltage = lowest_voltage;
    packet->fault_id = fault_id;
    packet->fault_dc_flag = fault_dc_flag;
    packet->fault_fc_flag = fault_fc_flag;
    packet->dc_output_current = dc_output_current;
    packet->dc_input_power = dc_input_power;
    packet->dc_output_power = dc_output_power;
    packet->pressure_lowest_id = pressure_lowest_id;
    packet->pressure_lowest = pressure_lowest;
    packet->pressure_total = pressure_total;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, (const char *)packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#endif
}
#endif

#endif

// MESSAGE FUEL_CELL_STATUS UNPACKING


/**
 * @brief Get field system_status from fuel_cell_status message
 *
 * @return  System Status
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_system_status(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  0);
}

/**
 * @brief Get field load_voltage from fuel_cell_status message
 *
 * @return  Load Voltage
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_load_voltage(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  2);
}

/**
 * @brief Get field error_code from fuel_cell_status message
 *
 * @return  Error Code
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_error_code(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  4);
}

/**
 * @brief Get field highest_temperature_id from fuel_cell_status message
 *
 * @return  Stack Temperature Highest ID
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_highest_temperature_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  6);
}

/**
 * @brief Get field highest_temperature from fuel_cell_status message
 *
 * @return  Stack Temperature Highest Temperature
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_highest_temperature(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  8);
}

/**
 * @brief Get field highest_fan_speed from fuel_cell_status message
 *
 * @return  Stack Temperature Highest Fan Speed
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_highest_fan_speed(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  10);
}

/**
 * @brief Get field lowest_voltage_id from fuel_cell_status message
 *
 * @return  Stack Voltage Lowest ID
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_lowest_voltage_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  12);
}

/**
 * @brief Get field lowest_voltage from fuel_cell_status message
 *
 * @return  Stack Voltage Lowest Voltage
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_lowest_voltage(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  14);
}

/**
 * @brief Get field fault_id from fuel_cell_status message
 *
 * @return  Fault ID
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_fault_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  16);
}

/**
 * @brief Get field fault_dc_flag from fuel_cell_status message
 *
 * @return  Fault DC Flag
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_fault_dc_flag(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  18);
}

/**
 * @brief Get field fault_fc_flag from fuel_cell_status message
 *
 * @return  Fault FC Flag
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_fault_fc_flag(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  20);
}

/**
 * @brief Get field dc_output_current from fuel_cell_status message
 *
 * @return  DC Output Total Current
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_dc_output_current(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  22);
}

/**
 * @brief Get field dc_input_power from fuel_cell_status message
 *
 * @return  DC Input Total Power
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_dc_input_power(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  24);
}

/**
 * @brief Get field dc_output_power from fuel_cell_status message
 *
 * @return  DC Output Total Power
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_dc_output_power(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  26);
}

/**
 * @brief Get field pressure_lowest_id from fuel_cell_status message
 *
 * @return  Hydrogen Bottle Pressure Lowest ID
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_pressure_lowest_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  28);
}

/**
 * @brief Get field pressure_lowest from fuel_cell_status message
 *
 * @return  Hydrogen Bottle Pressure Lowest Pressure
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_pressure_lowest(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  30);
}

/**
 * @brief Get field pressure_total from fuel_cell_status message
 *
 * @return  Hydrogen Bottle Pressure Total
 */
static inline uint16_t mavlink_msg_fuel_cell_status_get_pressure_total(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  32);
}

/**
 * @brief Decode a fuel_cell_status message into a struct
 *
 * @param msg The message to decode
 * @param fuel_cell_status C-struct to decode the message contents into
 */
static inline void mavlink_msg_fuel_cell_status_decode(const mavlink_message_t* msg, mavlink_fuel_cell_status_t* fuel_cell_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    fuel_cell_status->system_status = mavlink_msg_fuel_cell_status_get_system_status(msg);
    fuel_cell_status->load_voltage = mavlink_msg_fuel_cell_status_get_load_voltage(msg);
    fuel_cell_status->error_code = mavlink_msg_fuel_cell_status_get_error_code(msg);
    fuel_cell_status->highest_temperature_id = mavlink_msg_fuel_cell_status_get_highest_temperature_id(msg);
    fuel_cell_status->highest_temperature = mavlink_msg_fuel_cell_status_get_highest_temperature(msg);
    fuel_cell_status->highest_fan_speed = mavlink_msg_fuel_cell_status_get_highest_fan_speed(msg);
    fuel_cell_status->lowest_voltage_id = mavlink_msg_fuel_cell_status_get_lowest_voltage_id(msg);
    fuel_cell_status->lowest_voltage = mavlink_msg_fuel_cell_status_get_lowest_voltage(msg);
    fuel_cell_status->fault_id = mavlink_msg_fuel_cell_status_get_fault_id(msg);
    fuel_cell_status->fault_dc_flag = mavlink_msg_fuel_cell_status_get_fault_dc_flag(msg);
    fuel_cell_status->fault_fc_flag = mavlink_msg_fuel_cell_status_get_fault_fc_flag(msg);
    fuel_cell_status->dc_output_current = mavlink_msg_fuel_cell_status_get_dc_output_current(msg);
    fuel_cell_status->dc_input_power = mavlink_msg_fuel_cell_status_get_dc_input_power(msg);
    fuel_cell_status->dc_output_power = mavlink_msg_fuel_cell_status_get_dc_output_power(msg);
    fuel_cell_status->pressure_lowest_id = mavlink_msg_fuel_cell_status_get_pressure_lowest_id(msg);
    fuel_cell_status->pressure_lowest = mavlink_msg_fuel_cell_status_get_pressure_lowest(msg);
    fuel_cell_status->pressure_total = mavlink_msg_fuel_cell_status_get_pressure_total(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN? msg->len : MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN;
        memset(fuel_cell_status, 0, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
    memcpy(fuel_cell_status, _MAV_PAYLOAD(msg), len);
#endif
}
