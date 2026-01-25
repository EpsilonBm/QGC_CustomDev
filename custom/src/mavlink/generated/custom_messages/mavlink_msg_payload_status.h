#pragma once
// MESSAGE PAYLOAD_STATUS PACKING

#define MAVLINK_MSG_ID_PAYLOAD_STATUS 1134


typedef struct __mavlink_payload_status_t {
 float value; /*<  Payload status value*/
 uint32_t error_flags; /*<  Payload error bitmask*/
 uint8_t payload_id; /*<  Payload identifier*/
 uint8_t state; /*<  Payload state*/
} mavlink_payload_status_t;

#define MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN 10
#define MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN 10
#define MAVLINK_MSG_ID_1134_LEN 10
#define MAVLINK_MSG_ID_1134_MIN_LEN 10

#define MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC 227
#define MAVLINK_MSG_ID_1134_CRC 227



#if MAVLINK_COMMAND_24BIT
#define MAVLINK_MESSAGE_INFO_PAYLOAD_STATUS { \
    1134, \
    "PAYLOAD_STATUS", \
    4, \
    {  { "payload_id", NULL, MAVLINK_TYPE_UINT8_T, 0, 8, offsetof(mavlink_payload_status_t, payload_id) }, \
         { "state", NULL, MAVLINK_TYPE_UINT8_T, 0, 9, offsetof(mavlink_payload_status_t, state) }, \
         { "value", NULL, MAVLINK_TYPE_FLOAT, 0, 0, offsetof(mavlink_payload_status_t, value) }, \
         { "error_flags", NULL, MAVLINK_TYPE_UINT32_T, 0, 4, offsetof(mavlink_payload_status_t, error_flags) }, \
         } \
}
#else
#define MAVLINK_MESSAGE_INFO_PAYLOAD_STATUS { \
    "PAYLOAD_STATUS", \
    4, \
    {  { "payload_id", NULL, MAVLINK_TYPE_UINT8_T, 0, 8, offsetof(mavlink_payload_status_t, payload_id) }, \
         { "state", NULL, MAVLINK_TYPE_UINT8_T, 0, 9, offsetof(mavlink_payload_status_t, state) }, \
         { "value", NULL, MAVLINK_TYPE_FLOAT, 0, 0, offsetof(mavlink_payload_status_t, value) }, \
         { "error_flags", NULL, MAVLINK_TYPE_UINT32_T, 0, 4, offsetof(mavlink_payload_status_t, error_flags) }, \
         } \
}
#endif

/**
 * @brief Pack a payload_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 *
 * @param payload_id  Payload identifier
 * @param state  Payload state
 * @param value  Payload status value
 * @param error_flags  Payload error bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_status_pack(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg,
                               uint8_t payload_id, uint8_t state, float value, uint32_t error_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN];
    _mav_put_float(buf, 0, value);
    _mav_put_uint32_t(buf, 4, error_flags);
    _mav_put_uint8_t(buf, 8, payload_id);
    _mav_put_uint8_t(buf, 9, state);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#else
    mavlink_payload_status_t packet;
    packet.value = value;
    packet.error_flags = error_flags;
    packet.payload_id = payload_id;
    packet.state = state;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_STATUS;
    return mavlink_finalize_message(msg, system_id, component_id, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
}

/**
 * @brief Pack a payload_status message
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 *
 * @param payload_id  Payload identifier
 * @param state  Payload state
 * @param value  Payload status value
 * @param error_flags  Payload error bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_status_pack_status(uint8_t system_id, uint8_t component_id, mavlink_status_t *_status, mavlink_message_t* msg,
                               uint8_t payload_id, uint8_t state, float value, uint32_t error_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN];
    _mav_put_float(buf, 0, value);
    _mav_put_uint32_t(buf, 4, error_flags);
    _mav_put_uint8_t(buf, 8, payload_id);
    _mav_put_uint8_t(buf, 9, state);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#else
    mavlink_payload_status_t packet;
    packet.value = value;
    packet.error_flags = error_flags;
    packet.payload_id = payload_id;
    packet.state = state;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_STATUS;
#if MAVLINK_CRC_EXTRA
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#else
    return mavlink_finalize_message_buffer(msg, system_id, component_id, _status, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#endif
}

/**
 * @brief Pack a payload_status message on a channel
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param payload_id  Payload identifier
 * @param state  Payload state
 * @param value  Payload status value
 * @param error_flags  Payload error bitmask
 * @return length of the message in bytes (excluding serial stream start sign)
 */
static inline uint16_t mavlink_msg_payload_status_pack_chan(uint8_t system_id, uint8_t component_id, uint8_t chan,
                               mavlink_message_t* msg,
                                   uint8_t payload_id,uint8_t state,float value,uint32_t error_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN];
    _mav_put_float(buf, 0, value);
    _mav_put_uint32_t(buf, 4, error_flags);
    _mav_put_uint8_t(buf, 8, payload_id);
    _mav_put_uint8_t(buf, 9, state);

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), buf, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#else
    mavlink_payload_status_t packet;
    packet.value = value;
    packet.error_flags = error_flags;
    packet.payload_id = payload_id;
    packet.state = state;

        memcpy(_MAV_PAYLOAD_NON_CONST(msg), &packet, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
#endif

    msg->msgid = MAVLINK_MSG_ID_PAYLOAD_STATUS;
    return mavlink_finalize_message_chan(msg, system_id, component_id, chan, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
}

/**
 * @brief Encode a payload_status struct
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param msg The MAVLink message to compress the data into
 * @param payload_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_status_encode(uint8_t system_id, uint8_t component_id, mavlink_message_t* msg, const mavlink_payload_status_t* payload_status)
{
    return mavlink_msg_payload_status_pack(system_id, component_id, msg, payload_status->payload_id, payload_status->state, payload_status->value, payload_status->error_flags);
}

/**
 * @brief Encode a payload_status struct on a channel
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param chan The MAVLink channel this message will be sent over
 * @param msg The MAVLink message to compress the data into
 * @param payload_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_status_encode_chan(uint8_t system_id, uint8_t component_id, uint8_t chan, mavlink_message_t* msg, const mavlink_payload_status_t* payload_status)
{
    return mavlink_msg_payload_status_pack_chan(system_id, component_id, chan, msg, payload_status->payload_id, payload_status->state, payload_status->value, payload_status->error_flags);
}

/**
 * @brief Encode a payload_status struct with provided status structure
 *
 * @param system_id ID of this system
 * @param component_id ID of this component (e.g. 200 for IMU)
 * @param status MAVLink status structure
 * @param msg The MAVLink message to compress the data into
 * @param payload_status C-struct to read the message contents from
 */
static inline uint16_t mavlink_msg_payload_status_encode_status(uint8_t system_id, uint8_t component_id, mavlink_status_t* _status, mavlink_message_t* msg, const mavlink_payload_status_t* payload_status)
{
    return mavlink_msg_payload_status_pack_status(system_id, component_id, _status, msg,  payload_status->payload_id, payload_status->state, payload_status->value, payload_status->error_flags);
}

/**
 * @brief Send a payload_status message
 * @param chan MAVLink channel to send the message
 *
 * @param payload_id  Payload identifier
 * @param state  Payload state
 * @param value  Payload status value
 * @param error_flags  Payload error bitmask
 */
#ifdef MAVLINK_USE_CONVENIENCE_FUNCTIONS

static inline void mavlink_msg_payload_status_send(mavlink_channel_t chan, uint8_t payload_id, uint8_t state, float value, uint32_t error_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char buf[MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN];
    _mav_put_float(buf, 0, value);
    _mav_put_uint32_t(buf, 4, error_flags);
    _mav_put_uint8_t(buf, 8, payload_id);
    _mav_put_uint8_t(buf, 9, state);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_STATUS, buf, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#else
    mavlink_payload_status_t packet;
    packet.value = value;
    packet.error_flags = error_flags;
    packet.payload_id = payload_id;
    packet.state = state;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_STATUS, (const char *)&packet, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#endif
}

/**
 * @brief Send a payload_status message
 * @param chan MAVLink channel to send the message
 * @param struct The MAVLink struct to serialize
 */
static inline void mavlink_msg_payload_status_send_struct(mavlink_channel_t chan, const mavlink_payload_status_t* payload_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    mavlink_msg_payload_status_send(chan, payload_status->payload_id, payload_status->state, payload_status->value, payload_status->error_flags);
#else
    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_STATUS, (const char *)payload_status, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#endif
}

#if MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN <= MAVLINK_MAX_PAYLOAD_LEN
/*
  This variant of _send() can be used to save stack space by reusing
  memory from the receive buffer.  The caller provides a
  mavlink_message_t which is the size of a full mavlink message. This
  is usually the receive buffer for the channel, and allows a reply to an
  incoming message with minimum stack space usage.
 */
static inline void mavlink_msg_payload_status_send_buf(mavlink_message_t *msgbuf, mavlink_channel_t chan,  uint8_t payload_id, uint8_t state, float value, uint32_t error_flags)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    char *buf = (char *)msgbuf;
    _mav_put_float(buf, 0, value);
    _mav_put_uint32_t(buf, 4, error_flags);
    _mav_put_uint8_t(buf, 8, payload_id);
    _mav_put_uint8_t(buf, 9, state);

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_STATUS, buf, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#else
    mavlink_payload_status_t *packet = (mavlink_payload_status_t *)msgbuf;
    packet->value = value;
    packet->error_flags = error_flags;
    packet->payload_id = payload_id;
    packet->state = state;

    _mav_finalize_message_chan_send(chan, MAVLINK_MSG_ID_PAYLOAD_STATUS, (const char *)packet, MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN, MAVLINK_MSG_ID_PAYLOAD_STATUS_CRC);
#endif
}
#endif

#endif

// MESSAGE PAYLOAD_STATUS UNPACKING


/**
 * @brief Get field payload_id from payload_status message
 *
 * @return  Payload identifier
 */
static inline uint8_t mavlink_msg_payload_status_get_payload_id(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  8);
}

/**
 * @brief Get field state from payload_status message
 *
 * @return  Payload state
 */
static inline uint8_t mavlink_msg_payload_status_get_state(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint8_t(msg,  9);
}

/**
 * @brief Get field value from payload_status message
 *
 * @return  Payload status value
 */
static inline float mavlink_msg_payload_status_get_value(const mavlink_message_t* msg)
{
    return _MAV_RETURN_float(msg,  0);
}

/**
 * @brief Get field error_flags from payload_status message
 *
 * @return  Payload error bitmask
 */
static inline uint32_t mavlink_msg_payload_status_get_error_flags(const mavlink_message_t* msg)
{
    return _MAV_RETURN_uint32_t(msg,  4);
}

/**
 * @brief Decode a payload_status message into a struct
 *
 * @param msg The message to decode
 * @param payload_status C-struct to decode the message contents into
 */
static inline void mavlink_msg_payload_status_decode(const mavlink_message_t* msg, mavlink_payload_status_t* payload_status)
{
#if MAVLINK_NEED_BYTE_SWAP || !MAVLINK_ALIGNED_FIELDS
    payload_status->value = mavlink_msg_payload_status_get_value(msg);
    payload_status->error_flags = mavlink_msg_payload_status_get_error_flags(msg);
    payload_status->payload_id = mavlink_msg_payload_status_get_payload_id(msg);
    payload_status->state = mavlink_msg_payload_status_get_state(msg);
#else
        uint8_t len = msg->len < MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN? msg->len : MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN;
        memset(payload_status, 0, MAVLINK_MSG_ID_PAYLOAD_STATUS_LEN);
    memcpy(payload_status, _MAV_PAYLOAD(msg), len);
#endif
}
