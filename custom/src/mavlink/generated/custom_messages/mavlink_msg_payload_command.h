#pragma once
// MESSAGE PAYLOAD_COMMAND PACKING

#define MAVLINK_MSG_ID_PAYLOAD_COMMAND 1133


typedef struct __mavlink_payload_command_t {
 float param; /*<  Command parameter*/
 uint8_t payload_id; /*<  Payload identifier*/
 uint8_t command; /*<  Payload command*/
} mavlink_payload_command_t;

#define MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN 6
#define MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN 6
#define MAVLINK_MSG_ID_1133_LEN 6
#define MAVLINK_MSG_ID_1133_MIN_LEN 6

#define MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC 254
#define MAVLINK_MSG_ID_1133_CRC 254



#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_PAYLOAD_COMMAND { \
    1133, \
    "PAYLOAD_COMMAND", \
    3, \
    {  { "payload_id", NULL, MAVLINK_TYPE_UINT8_T, 0, 4, offsetof(mavlink_payload_command_t, payload_id) }, \
         { "command", NULL, MAVLINK_TYPE_UINT8_T, 0, 5, offsetof(mavlink_payload_command_t, command) }, \
         { "param", NULL, MAVLINK_TYPE_FLOAT, 0, 0, offsetof(mavlink_payload_command_t, param) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_PAYLOAD_COMMAND { \
    "PAYLOAD_COMMAND", \
    3, \
    {  { "payload_id", NULL, MAVLINK_TYPE_UINT8_T, 0, 4, offsetof(mavlink_payload_command_t, payload_id) }, \
         { "command", NULL, MAVLINK_TYPE_UINT8_T, 0, 5, offsetof(mavlink_payload_command_t, command) }, \
         { "param", NULL, MAVLINK_TYPE_FLOAT, 0, 0, offsetof(mavlink_payload_command_t, param) }, \
         } \
}
#endif

/**
 * @brief Pack a payload_command message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param payload_id  Payload identifier
 * @param command  Payload command
 * @param param  Command parameter
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_command_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint8_t payload_id, uint8_t command, float param)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN];
    _mav_put_float(buf, 0, param);
    _mav_put_uint8_t(buf, 4, payload_id);
    _mav_put_uint8_t(buf, 5, command);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#else
    mavlink_payload_command_t packet;
    packet.param = param;
    packet.payload_id = payload_id;
    packet.command = command;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_COMMAND;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
}

/**
 * @brief Pack a payload_command message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param payload_id  Payload identifier
 * @param command  Payload command
 * @param param  Command parameter
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_command_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint8_t payload_id, uint8_t command, float param)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN];
    _mav_put_float(buf, 0, param);
    _mav_put_uint8_t(buf, 4, payload_id);
    _mav_put_uint8_t(buf, 5, command);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#else
    mavlink_payload_command_t packet;
    packet.param = param;
    packet.payload_id = payload_id;
    packet.command = command;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_COMMAND;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#endif
}

/**
 * @brief Pack a payload_command message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param payload_id  Payload identifier
 * @param command  Payload command
 * @param param  Command parameter
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_command_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint8_t payload_id,uint8_t command,float param)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN];
    _mav_put_float(buf, 0, param);
    _mav_put_uint8_t(buf, 4, payload_id);
    _mav_put_uint8_t(buf, 5, command);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#else
    mavlink_payload_command_t packet;
    packet.param = param;
    packet.payload_id = payload_id;
    packet.command = command;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_COMMAND;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
}

/**
 * @brief Encode a payload_command struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param payload_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_command_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_payload_command_t* payload_command)
{
    return mavlink_msg_payload_command_pack(system_id, component_id, msg, payload_command->payload_id, payload_command->command, payload_command->param);
}

/**
 * @brief Encode a payload_command struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param payload_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_command_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_payload_command_t* payload_command)
{
    return mavlink_msg_payload_command_pack_chan(system_id, component_id, chan, msg, payload_command->payload_id, payload_command->command, payload_command->param);
}

/**
 * @brief Encode a payload_command struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param payload_command C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_command_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_payload_command_t* payload_command)
{
    return mavlink_msg_payload_command_pack_status(system_id, component_id, _status, msg,  payload_command->payload_id, payload_command->command, payload_command->param);
}

/**
 * @brief Send a payload_command message
 * @param chan MAVLink channel to send the message
 *
 * @param payload_id  Payload identifier
 * @param command  Payload command
 * @param param  Command parameter
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_payload_command_send(mavlink_channel_t chan, uint8_t payload_id, uint8_t command, float param)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN];
    _mav_put_float(buf, 0, param);
    _mav_put_uint8_t(buf, 4, payload_id);
    _mav_put_uint8_t(buf, 5, command);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND, buf, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#else
    mavlink_payload_command_t packet;
    packet.param = param;
    packet.payload_id = payload_id;
    packet.command = command;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND, (const char *)&packet, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#endif
}

/**
 * @brief Send a payload_command message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_payload_command_send_struct(mavlink_channel_t chan, const mavlink_payload_command_t* payload_command)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_payload_command_send(chan, payload_command->payload_id, payload_command->command, payload_command->param);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND, (const char *)payload_command, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#endif
}

#if MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by reusing
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_payload_command_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint8_t payload_id, uint8_t command, float param)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_float(buf, 0, param);
    _mav_put_uint8_t(buf, 4, payload_id);
    _mav_put_uint8_t(buf, 5, command);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND, buf, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#else
    mavlink_payload_command_t *packet = (mavlink_payload_command_t *)msgbuf;
    packet->param = param;
    packet->payload_id = payload_id;
    packet->command = command;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_COMMAND, (const char *)packet, MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN, MAVLINK_MSG_ID_PAYLOAD_COMMAND_CRC);
#endif
}
#endif

#endif

// MESSAGE PAYLOAD_COMMAND UNPACKING


/**
 * @brief Get field payload_id from payload_command message
 *
 * @return  Payload identifier
 */
static inline uint8_t mavlink_msg_payload_command_get_payload_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  4);
}

/**
 * @brief Get field command from payload_command message
 *
 * @return  Payload command
 */
static inline uint8_t mavlink_msg_payload_command_get_command(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  5);
}

/**
 * @brief Get field param from payload_command message
 *
 * @return  Command parameter
 */
static inline float mavlink_msg_payload_command_get_param(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  0);
}

/**
 * @brief Decode a payload_command message into a struct
 *
 * @param msg The message to decode
 * @param payload_command C-struct to decode the message contents into
 */
static inline void mavlink_msg_payload_command_decode(const mavlink_message_t* msg, mavlink_payload_command_t* payload_command)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    payload_command->param = mavlink_msg_payload_command_get_param(msg);
    payload_command->payload_id = mavlink_msg_payload_command_get_payload_id(msg);
    payload_command->command = mavlink_msg_payload_command_get_command(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN? msg->len : MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN;
        memset(payload_command, 0, MAVLINK_MSG_ID_PAYLOAD_COMMAND_LEN);
    memcpy(payload_command, _MAV_PAYLOAD(msg), len);
#endif
}
