/** @file
 *    @brief MAVLink comm protocol testsuite generated from custom_messages.xml
 *    @see https://mavlink.io/en/
 */
#pragma once
#ifndef CUSTOM_MESSAGES_TESTSUITE_H
#define CUSTOM_MESSAGES_TESTSUITE_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAVLINK_TEST_ALL
#define MAVLINK_TEST_ALL
static void mavlink_test_all(uint8_t, uint8_t, mavlink_message_t *last_msg);
static void mavlink_test_custom_messages(uint8_t, uint8_t, mavlink_message_t *last_msg);

static void mavlink_test_all(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
    mavlink_test_all(system_id, component_id, last_msg);
    mavlink_test_custom_messages(system_id, component_id, last_msg);
}
#endif

#include "../all/testsuite.h"


static void mavlink_test_fuel_cell_status(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
    mavlink_status_t *status = mavlink_get_channel_status(MAVLINK_COMM_0);
        if ((status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) && MAVLINK_MSG_ID_FUEL_CELL_STATUS >= 256) {
            return;
        }
#endif
    mavlink_message_t msg;
        uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
        uint16_t i;
    mavlink_fuel_cell_status_t packet_in = {
        963497464,45.0,73.0,101.0,129.0,963498504
    };
    mavlink_fuel_cell_status_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.time_boot_ms = packet_in.time_boot_ms;
        packet1.voltage_v = packet_in.voltage_v;
        packet1.current_a = packet_in.current_a;
        packet1.hydrogen_pressure_bar = packet_in.hydrogen_pressure_bar;
        packet1.stack_temperature_c = packet_in.stack_temperature_c;
        packet1.fault_flags = packet_in.fault_flags;
        
        
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
        if (status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) {
           // cope with extensions
           memset(MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN + (char *)&packet1, 0, sizeof(packet1)-MAVLINK_MSG_ID_FUEL_CELL_STATUS_MIN_LEN);
        }
#endif
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_status_encode(system_id, component_id, &msg, &packet1);
    mavlink_msg_fuel_cell_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_status_pack(system_id, component_id, &msg , packet1.time_boot_ms , packet1.voltage_v , packet1.current_a , packet1.hydrogen_pressure_bar , packet1.stack_temperature_c , packet1.fault_flags );
    mavlink_msg_fuel_cell_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_status_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.time_boot_ms , packet1.voltage_v , packet1.current_a , packet1.hydrogen_pressure_bar , packet1.stack_temperature_c , packet1.fault_flags );
    mavlink_msg_fuel_cell_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
        mavlink_msg_to_send_buffer(buffer, &msg);
        for (i=0; i<mavlink_msg_get_send_buffer_length(&msg); i++) {
            comm_send_ch(MAVLINK_COMM_0, buffer[i]);
        }
    mavlink_msg_fuel_cell_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);
        
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_status_send(MAVLINK_COMM_1 , packet1.time_boot_ms , packet1.voltage_v , packet1.current_a , packet1.hydrogen_pressure_bar , packet1.stack_temperature_c , packet1.fault_flags );
    mavlink_msg_fuel_cell_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("FUEL_CELL_STATUS") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_FUEL_CELL_STATUS) != NULL);
#endif
}

static void mavlink_test_payload_command(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
    mavlink_status_t *status = mavlink_get_channel_status(MAVLINK_COMM_0);
        if ((status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) && MAVLINK_MSG_ID_PAYLOAD_COMMAND >= 256) {
            return;
        }
#endif
    mavlink_message_t msg;
        uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
        uint16_t i;
    mavlink_payload_command_t packet_in = {
        17.0,17,84
    };
    mavlink_payload_command_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.param = packet_in.param;
        packet1.payload_id = packet_in.payload_id;
        packet1.command = packet_in.command;
        
        
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
        if (status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) {
           // cope with extensions
           memset(MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN + (char *)&packet1, 0, sizeof(packet1)-MAVLINK_MSG_ID_PAYLOAD_COMMAND_MIN_LEN);
        }
#endif
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_command_encode(system_id, component_id, &msg, &packet1);
    mavlink_msg_payload_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_command_pack(system_id, component_id, &msg , packet1.payload_id , packet1.command , packet1.param );
    mavlink_msg_payload_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_command_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.payload_id , packet1.command , packet1.param );
    mavlink_msg_payload_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
        mavlink_msg_to_send_buffer(buffer, &msg);
        for (i=0; i<mavlink_msg_get_send_buffer_length(&msg); i++) {
            comm_send_ch(MAVLINK_COMM_0, buffer[i]);
        }
    mavlink_msg_payload_command_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);
        
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_command_send(MAVLINK_COMM_1 , packet1.payload_id , packet1.command , packet1.param );
    mavlink_msg_payload_command_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("PAYLOAD_COMMAND") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_PAYLOAD_COMMAND) != NULL);
#endif
}

static void mavlink_test_payload_status(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
    mavlink_status_t *status = mavlink_get_channel_status(MAVLINK_COMM_0);
        if ((status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) && MAVLINK_MSG_ID_PAYLOAD_STATUS >= 256) {
            return;
        }
#endif
    mavlink_message_t msg;
        uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
        uint16_t i;
    mavlink_payload_status_t packet_in = {
        17.0,963497672,29,96
    };
    mavlink_payload_status_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.value = packet_in.value;
        packet1.error_flags = packet_in.error_flags;
        packet1.payload_id = packet_in.payload_id;
        packet1.state = packet_in.state;
        
        
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
        if (status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) {
           // cope with extensions
           memset(MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN + (char *)&packet1, 0, sizeof(packet1)-MAVLINK_MSG_ID_PAYLOAD_STATUS_MIN_LEN);
        }
#endif
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_status_encode(system_id, component_id, &msg, &packet1);
    mavlink_msg_payload_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_status_pack(system_id, component_id, &msg , packet1.payload_id , packet1.state , packet1.value , packet1.error_flags );
    mavlink_msg_payload_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_status_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.payload_id , packet1.state , packet1.value , packet1.error_flags );
    mavlink_msg_payload_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
        mavlink_msg_to_send_buffer(buffer, &msg);
        for (i=0; i<mavlink_msg_get_send_buffer_length(&msg); i++) {
            comm_send_ch(MAVLINK_COMM_0, buffer[i]);
        }
    mavlink_msg_payload_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);
        
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_payload_status_send(MAVLINK_COMM_1 , packet1.payload_id , packet1.state , packet1.value , packet1.error_flags );
    mavlink_msg_payload_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("PAYLOAD_STATUS") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_PAYLOAD_STATUS) != NULL);
#endif
}

static void mavlink_test_custom_messages(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
    mavlink_test_fuel_cell_status(system_id, component_id, last_msg);
    mavlink_test_payload_command(system_id, component_id, last_msg);
    mavlink_test_payload_status(system_id, component_id, last_msg);
}

#ifdef __cplusplus
}
#endif // __cplusplus
#endif // CUSTOM_MESSAGES_TESTSUITE_H
