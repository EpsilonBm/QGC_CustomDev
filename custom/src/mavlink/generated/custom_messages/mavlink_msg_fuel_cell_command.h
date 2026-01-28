#pragma once
// MESSAGE FUEL_CELL_COMMAND PACKING

#define MAVLINK_MSG_ID_FUEL_CELL_COMMAND 12922


typedef struct __mavlink_fuel_cell_command_t {
 uint16_t runtime_command; /*<  Runtime Command*/
 uint16_t requested_power; /*<  Requested Power*/
 uint16_t startup_mode; /*<  Startup Mode*/
} mavlink_fuel_cell_command_t;

#define MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN 6
#define MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN 6
#define MAVLINK_MSG_ID_12922_LEN 6
#define MAVLINK_MSG_ID_12922_MIN_LEN 6

#define MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC 122
#define MAVLINK_MSG_ID_12922_CRC 122



#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_COMMAND { \
    12922, \
    "FUEL_CELL_COMMAND", \
    3, \
    {  { "runtime_command", NULL, MAVLINK_TYPE_UINT16_T, 0, 0, offsetof(mavlink_fuel_cell_command_t, runtime_command) }, \
         { "requested_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 2, offsetof(mavlink_fuel_cell_command_t, requested_power) }, \
         { "startup_mode", NULL, MAVLINK_TYPE_UINT16_T, 0, 4, offsetof(mavlink_fuel_cell_command_t, startup_mode) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_FUEL_CELL_COMMAND { \
    "FUEL_CELL_COMMAND", \
    3, \
    {  { "runtime_command", NULL, MAVLINK_TYPE_UINT16_T, 0, 0, offsetof(mavlink_fuel_cell_command_t, runtime_command) }, \
         { "requested_power", NULL, MAVLINK_TYPE_UINT16_T, 0, 2, offsetof(mavlink_fuel_cell_command_t, requested_power) }, \
         { "startup_mode", NULL, MAVLINK_TYPE_UINT16_T, 0, 4, offsetof(mavlink_fuel_cell_command_t, startup_mode) }, \
         } \
}
#endif

/**
 * @brief Pack a fuel_cell_command message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param runtime_command  Runtime Command
 * @param requested_power  Requested Power
 * @param startup_mode  Startup Mode
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_command_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint16_t runtime_command, uint16_t requested_power, uint16_t startup_mode)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN];
    _mav_put_uint16_t(buf, 0, runtime_command);
    _mav_put_uint16_t(buf, 2, requested_power);
    _mav_put_uint16_t(buf, 4, startup_mode);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#else
    mavlink_fuel_cell_command_t packet;
    packet.runtime_command = runtime_command;
    packet.requested_power = requested_power;
    packet.startup_mode = startup_mode;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_COMMAND;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
}

/**
 * @brief Pack a fuel_cell_command message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param runtime_command  Runtime Command
 * @param requested_power  Requested Power
 * @param startup_mode  Startup Mode
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_command_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint16_t runtime_command, uint16_t requested_power, uint16_t startup_mode)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN];
    _mav_put_uint16_t(buf, 0, runtime_command);
    _mav_put_uint16_t(buf, 2, requested_power);
    _mav_put_uint16_t(buf, 4, startup_mode);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#else
    mavlink_fuel_cell_command_t packet;
    packet.runtime_command = runtime_command;
    packet.requested_power = requested_power;
    packet.startup_mode = startup_mode;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_COMMAND;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#endif
}

/**
 * @brief Pack a fuel_cell_command message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param runtime_command  Runtime Command
 * @param requested_power  Requested Power
 * @param startup_mode  Startup Mode
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_fuel_cell_command_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint16_t runtime_command,uint16_t requested_power,uint16_t startup_mode)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN];
    _mav_put_uint16_t(buf, 0, runtime_command);
    _mav_put_uint16_t(buf, 2, requested_power);
    _mav_put_uint16_t(buf, 4, startup_mode);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#else
    mavlink_fuel_cell_command_t packet;
    packet.runtime_command = runtime_command;
    packet.requested_power = requested_power;
    packet.startup_mode = startup_mode;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_FUEL_CELL_COMMAND;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
}

/**
 * @brief Encode a fuel_cell_command struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_command_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_fuel_cell_command_t* fuel_cell_command)
{
    return mavlink_msg_fuel_cell_command_pack(system_id, component_id, msg, fuel_cell_command->runtime_command, fuel_cell_command->requested_power, fuel_cell_command->startup_mode);
}

/**
 * @brief Encode a fuel_cell_command struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_command_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_fuel_cell_command_t* fuel_cell_command)
{
    return mavlink_msg_fuel_cell_command_pack_chan(system_id, component_id, chan, msg, fuel_cell_command->runtime_command, fuel_cell_command->requested_power, fuel_cell_command->startup_mode);
}

/**
 * @brief Encode a fuel_cell_command struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param fuel_cell_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_fuel_cell_command_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_fuel_cell_command_t* fuel_cell_command)
{
    return mavlink_msg_fuel_cell_command_pack_status(system_id, component_id, _status, msg,  fuel_cell_command->runtime_command, fuel_cell_command->requested_power, fuel_cell_command->startup_mode);
}

/**
 * @brief Send a fuel_cell_command message
 * @param chan MAVLink channel to send the message
 *
 * @param runtime_command  Runtime Command
 * @param requested_power  Requested Power
 * @param startup_mode  Startup Mode
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_fuel_cell_command_send(mavlink_channel_t chan, uint16_t runtime_command, uint16_t requested_power, uint16_t startup_mode)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN];
    _mav_put_uint16_t(buf, 0, runtime_command);
    _mav_put_uint16_t(buf, 2, requested_power);
    _mav_put_uint16_t(buf, 4, startup_mode);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND, buf, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#else
    mavlink_fuel_cell_command_t packet;
    packet.runtime_command = runtime_command;
    packet.requested_power = requested_power;
    packet.startup_mode = startup_mode;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND, (const char *)&packet, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#endif
}

/**
 * @brief Send a fuel_cell_command message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_fuel_cell_command_send_struct(mavlink_channel_t chan, const mavlink_fuel_cell_command_t* fuel_cell_command)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_fuel_cell_command_send(chan, fuel_cell_command->runtime_command, fuel_cell_command->requested_power, fuel_cell_command->startup_mode);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND, (const char *)fuel_cell_command, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#endif
}

#if MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by reusing
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_fuel_cell_command_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint16_t runtime_command, uint16_t requested_power, uint16_t startup_mode)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_uint16_t(buf, 0, runtime_command);
    _mav_put_uint16_t(buf, 2, requested_power);
    _mav_put_uint16_t(buf, 4, startup_mode);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND, buf, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#else
    mavlink_fuel_cell_command_t *packet = (mavlink_fuel_cell_command_t *)msgbuf;
    packet->runtime_command = runtime_command;
    packet->requested_power = requested_power;
    packet->startup_mode = startup_mode;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_FUEL_CELL_COMMAND, (const char *)packet, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_CRC);
#endif
}
#endif

#endif

// MESSAGE FUEL_CELL_COMMAND UNPACKING


/**
 * @brief Get field runtime_command from fuel_cell_command message
 *
 * @return  Runtime Command
 */
static inline uint16_t mavlink_msg_fuel_cell_command_get_runtime_command(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  0);
}

/**
 * @brief Get field requested_power from fuel_cell_command message
 *
 * @return  Requested Power
 */
static inline uint16_t mavlink_msg_fuel_cell_command_get_requested_power(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  2);
}

/**
 * @brief Get field startup_mode from fuel_cell_command message
 *
 * @return  Startup Mode
 */
static inline uint16_t mavlink_msg_fuel_cell_command_get_startup_mode(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint16_t(msg,  4);
}

/**
 * @brief Decode a fuel_cell_command message into a struct
 *
 * @param msg The message to decode
 * @param fuel_cell_command C-struct to decode the message contents into
 */
static inline void mavlink_msg_fuel_cell_command_decode(const mavlink_message_t* msg, mavlink_fuel_cell_command_t* fuel_cell_command)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    fuel_cell_command->runtime_command = mavlink_msg_fuel_cell_command_get_runtime_command(msg);
    fuel_cell_command->requested_power = mavlink_msg_fuel_cell_command_get_requested_power(msg);
    fuel_cell_command->startup_mode = mavlink_msg_fuel_cell_command_get_startup_mode(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN? msg->len : MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN;
        memset(fuel_cell_command, 0, MAVLINK_MSG_ID_FUEL_CELL_COMMAND_LEN);
    memcpy(fuel_cell_command, _MAV_PAYLOAD(msg), len);
#endif
}
