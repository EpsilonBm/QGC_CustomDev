#pragma once
// MESSAGE FUEL_CELL_STATUS PACKING

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS 42000


typedef struct __mavlink_fuel_cell_status_t {
 uint32_t time_boot_ms; /*<  Time since system boot*/
 float voltage_v; /*<  Fuel cell output voltage*/
 float current_a; /*<  Fuel cell output current*/
 float hydrogen_pressure_bar; /*<  Hydrogen tank pressure*/
 float stack_temperature_c; /*<  Fuel cell stack temperature*/
 uint32_t fault_flags; /*<  Fuel cell fault bitmask*/
} mavlink_fuel_cell_status_t;

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN 24
#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN 24
#define MAVLINK_MSG_ID_42000_LEN 24
#define MAVLINK_MSG_ID_42000_MIN_LEN 24

#define MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC 63
#define MAVLINK_MSG_ID_42000_CRC 63



#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_STATUS { \
    42000, \
    "FUEL_CELL_STATUS", \
    6, \
    {  { "time_boot_ms", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_fuel_cell_status_t, time_boot_ms) }, \
         { "voltage_v", NULL, MAVLINK_TYPE_FLOAT, 0, 4, offsetof(mavlink_fuel_cell_status_t, voltage_v) }, \
         { "current_a", NULL, MAVLINK_TYPE_FLOAT, 0, 8, offsetof(mavlink_fuel_cell_status_t, current_a) }, \
         { "hydrogen_pressure_bar", NULL, MAVLINK_TYPE_FLOAT, 0, 12, offsetof(mavlink_fuel_cell_status_t, hydrogen_pressure_bar) }, \
         { "stack_temperature_c", NULL, MAVLINK_TYPE_FLOAT, 0, 16, offsetof(mavlink_fuel_cell_status_t, stack_temperature_c) }, \
         { "fault_flags", NULL, MAVLINK_TYPE_UINT32_T, 0, 20, offsetof(mavlink_fuel_cell_status_t, fault_flags) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_STATUS { \
    "FUEL_CELL_STATUS", \
    6, \
    {  { "time_boot_ms", NULL, MAVLINK_TYPE_UINT32_T, 0, 0, offsetof(mavlink_fuel_cell_status_t, time_boot_ms) }, \
         { "voltage_v", NULL, MAVLINK_TYPE_FLOAT, 0, 4, offsetof(mavlink_fuel_cell_status_t, voltage_v) }, \
         { "current_a", NULL, MAVLINK_TYPE_FLOAT, 0, 8, offsetof(mavlink_fuel_cell_status_t, current_a) }, \
         { "hydrogen_pressure_bar", NULL, MAVLINK_TYPE_FLOAT, 0, 12, offsetof(mavlink_fuel_cell_status_t, hydrogen_pressure_bar) }, \
         { "stack_temperature_c", NULL, MAVLINK_TYPE_FLOAT, 0, 16, offsetof(mavlink_fuel_cell_status_t, stack_temperature_c) }, \
         { "fault_flags", NULL, MAVLINK_TYPE_UINT32_T, 0, 20, offsetof(mavlink_fuel_cell_status_t, fault_flags) }, \
         } \
}
#endif

/**
 * @brief Pack a fuel_cell_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param time_boot_ms  Time since system boot
 * @param voltage_v  Fuel cell output voltage
 * @param current_a  Fuel cell output current
 * @param hydrogen_pressure_bar  Hydrogen tank pressure
 * @param stack_temperature_c  Fuel cell stack temperature
 * @param fault_flags  Fuel cell fault bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint32_t time_boot_ms, float voltage_v, float current_a, float hydrogen_pressure_bar, float stack_temperature_c, uint32_t fault_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, voltage_v);
    _mav_put_float(buf, 8, current_a);
    _mav_put_float(buf, 12, hydrogen_pressure_bar);
    _mav_put_float(buf, 16, stack_temperature_c);
    _mav_put_uint32_t(buf, 20, fault_flags);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.voltage_v = voltage_v;
    packet.current_a = current_a;
    packet.hydrogen_pressure_bar = hydrogen_pressure_bar;
    packet.stack_temperature_c = stack_temperature_c;
    packet.fault_flags = fault_flags;

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
 * @param time_boot_ms  Time since system boot
 * @param voltage_v  Fuel cell output voltage
 * @param current_a  Fuel cell output current
 * @param hydrogen_pressure_bar  Hydrogen tank pressure
 * @param stack_temperature_c  Fuel cell stack temperature
 * @param fault_flags  Fuel cell fault bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint32_t time_boot_ms, float voltage_v, float current_a, float hydrogen_pressure_bar, float stack_temperature_c, uint32_t fault_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, voltage_v);
    _mav_put_float(buf, 8, current_a);
    _mav_put_float(buf, 12, hydrogen_pressure_bar);
    _mav_put_float(buf, 16, stack_temperature_c);
    _mav_put_uint32_t(buf, 20, fault_flags);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.voltage_v = voltage_v;
    packet.current_a = current_a;
    packet.hydrogen_pressure_bar = hydrogen_pressure_bar;
    packet.stack_temperature_c = stack_temperature_c;
    packet.fault_flags = fault_flags;

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
 * @param time_boot_ms  Time since system boot
 * @param voltage_v  Fuel cell output voltage
 * @param current_a  Fuel cell output current
 * @param hydrogen_pressure_bar  Hydrogen tank pressure
 * @param stack_temperature_c  Fuel cell stack temperature
 * @param fault_flags  Fuel cell fault bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_status_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint32_t time_boot_ms,float voltage_v,float current_a,float hydrogen_pressure_bar,float stack_temperature_c,uint32_t fault_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, voltage_v);
    _mav_put_float(buf, 8, current_a);
    _mav_put_float(buf, 12, hydrogen_pressure_bar);
    _mav_put_float(buf, 16, stack_temperature_c);
    _mav_put_uint32_t(buf, 20, fault_flags);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
#else
    mavlink_fuel_cell_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.voltage_v = voltage_v;
    packet.current_a = current_a;
    packet.hydrogen_pressure_bar = hydrogen_pressure_bar;
    packet.stack_temperature_c = stack_temperature_c;
    packet.fault_flags = fault_flags;

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
    return mavlink_msg_fuel_cell_status_pack(system_id, component_id, msg, fuel_cell_status->time_boot_ms, fuel_cell_status->voltage_v, fuel_cell_status->current_a, fuel_cell_status->hydrogen_pressure_bar, fuel_cell_status->stack_temperature_c, fuel_cell_status->fault_flags);
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
    return mavlink_msg_fuel_cell_status_pack_chan(system_id, component_id, chan, msg, fuel_cell_status->time_boot_ms, fuel_cell_status->voltage_v, fuel_cell_status->current_a, fuel_cell_status->hydrogen_pressure_bar, fuel_cell_status->stack_temperature_c, fuel_cell_status->fault_flags);
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
    return mavlink_msg_fuel_cell_status_pack_status(system_id, component_id, _status, msg,  fuel_cell_status->time_boot_ms, fuel_cell_status->voltage_v, fuel_cell_status->current_a, fuel_cell_status->hydrogen_pressure_bar, fuel_cell_status->stack_temperature_c, fuel_cell_status->fault_flags);
}

/**
 * @brief Send a fuel_cell_status message
 * @param chan MAVLink channel to send the message
 *
 * @param time_boot_ms  Time since system boot
 * @param voltage_v  Fuel cell output voltage
 * @param current_a  Fuel cell output current
 * @param hydrogen_pressure_bar  Hydrogen tank pressure
 * @param stack_temperature_c  Fuel cell stack temperature
 * @param fault_flags  Fuel cell fault bitmask
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_fuel_cell_status_send(mavlink_channel_t chan, uint32_t time_boot_ms, float voltage_v, float current_a, float hydrogen_pressure_bar, float stack_temperature_c, uint32_t fault_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN];
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, voltage_v);
    _mav_put_float(buf, 8, current_a);
    _mav_put_float(buf, 12, hydrogen_pressure_bar);
    _mav_put_float(buf, 16, stack_temperature_c);
    _mav_put_uint32_t(buf, 20, fault_flags);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#else
    mavlink_fuel_cell_status_t packet;
    packet.time_boot_ms = time_boot_ms;
    packet.voltage_v = voltage_v;
    packet.current_a = current_a;
    packet.hydrogen_pressure_bar = hydrogen_pressure_bar;
    packet.stack_temperature_c = stack_temperature_c;
    packet.fault_flags = fault_flags;

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
    mavlink_msg_fuel_cell_status_send(chan, fuel_cell_status->time_boot_ms, fuel_cell_status->voltage_v, fuel_cell_status->current_a, fuel_cell_status->hydrogen_pressure_bar, fuel_cell_status->stack_temperature_c, fuel_cell_status->fault_flags);
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
static inline void mavlink_msg_fuel_cell_status_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint32_t time_boot_ms, float voltage_v, float current_a, float hydrogen_pressure_bar, float stack_temperature_c, uint32_t fault_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint32_t(buf, 0, time_boot_ms);
    _mav_put_float(buf, 4, voltage_v);
    _mav_put_float(buf, 8, current_a);
    _mav_put_float(buf, 12, hydrogen_pressure_bar);
    _mav_put_float(buf, 16, stack_temperature_c);
    _mav_put_uint32_t(buf, 20, fault_flags);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, buf, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#else
    mavlink_fuel_cell_status_t *packet = (mavlink_fuel_cell_status_t *)msgbuf;
    packet->time_boot_ms = time_boot_ms;
    packet->voltage_v = voltage_v;
    packet->current_a = current_a;
    packet->hydrogen_pressure_bar = hydrogen_pressure_bar;
    packet->stack_temperature_c = stack_temperature_c;
    packet->fault_flags = fault_flags;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_STATUS, (const char *)packet, MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN, MAVLINK_MSG_ID_FUEL_CELL_STATUS_CRC);
#endif
}
#endif

#endif

// MESSAGE FUEL_CELL_STATUS UNPACKING


/**
 * @brief Get field time_boot_ms from fuel_cell_status message
 *
 * @return  Time since system boot
 */
static inline uint32_t mavlink_msg_fuel_cell_status_get_time_boot_ms(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  0);
}

/**
 * @brief Get field voltage_v from fuel_cell_status message
 *
 * @return  Fuel cell output voltage
 */
static inline float mavlink_msg_fuel_cell_status_get_voltage_v(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  4);
}

/**
 * @brief Get field current_a from fuel_cell_status message
 *
 * @return  Fuel cell output current
 */
static inline float mavlink_msg_fuel_cell_status_get_current_a(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  8);
}

/**
 * @brief Get field hydrogen_pressure_bar from fuel_cell_status message
 *
 * @return  Hydrogen tank pressure
 */
static inline float mavlink_msg_fuel_cell_status_get_hydrogen_pressure_bar(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  12);
}

/**
 * @brief Get field stack_temperature_c from fuel_cell_status message
 *
 * @return  Fuel cell stack temperature
 */
static inline float mavlink_msg_fuel_cell_status_get_stack_temperature_c(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  16);
}

/**
 * @brief Get field fault_flags from fuel_cell_status message
 *
 * @return  Fuel cell fault bitmask
 */
static inline uint32_t mavlink_msg_fuel_cell_status_get_fault_flags(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  20);
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
    fuel_cell_status->time_boot_ms = mavlink_msg_fuel_cell_status_get_time_boot_ms(msg);
    fuel_cell_status->voltage_v = mavlink_msg_fuel_cell_status_get_voltage_v(msg);
    fuel_cell_status->current_a = mavlink_msg_fuel_cell_status_get_current_a(msg);
    fuel_cell_status->hydrogen_pressure_bar = mavlink_msg_fuel_cell_status_get_hydrogen_pressure_bar(msg);
    fuel_cell_status->stack_temperature_c = mavlink_msg_fuel_cell_status_get_stack_temperature_c(msg);
    fuel_cell_status->fault_flags = mavlink_msg_fuel_cell_status_get_fault_flags(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN? msg->len : MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN;
        memset(fuel_cell_status, 0, MAVLINK_MSG_ID_FUEL_CELL_STATUS_LEN);
    memcpy(fuel_cell_status, _MAV_PAYLOAD(msg), len);
#endif
}
