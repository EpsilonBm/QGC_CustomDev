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
        17235,17339,17443,17547,17651,17755,17859,17963,18067,18171,18275,18379,18483,18587,18691,18795,18899
    };
    mavlink_fuel_cell_status_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.system_status = packet_in.system_status;
        packet1.load_voltage = packet_in.load_voltage;
        packet1.error_code = packet_in.error_code;
        packet1.highest_temperature_id = packet_in.highest_temperature_id;
        packet1.highest_temperature = packet_in.highest_temperature;
        packet1.highest_fan_speed = packet_in.highest_fan_speed;
        packet1.lowest_voltage_id = packet_in.lowest_voltage_id;
        packet1.lowest_voltage = packet_in.lowest_voltage;
        packet1.fault_id = packet_in.fault_id;
        packet1.fault_dc_flag = packet_in.fault_dc_flag;
        packet1.fault_fc_flag = packet_in.fault_fc_flag;
        packet1.dc_output_current = packet_in.dc_output_current;
        packet1.dc_input_power = packet_in.dc_input_power;
        packet1.dc_output_power = packet_in.dc_output_power;
        packet1.pressure_lowest_id = packet_in.pressure_lowest_id;
        packet1.pressure_lowest = packet_in.pressure_lowest;
        packet1.pressure_total = packet_in.pressure_total;
        
        
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
    mavlink_msg_fuel_cell_status_pack(system_id, component_id, &msg , packet1.system_status , packet1.load_voltage , packet1.error_code , packet1.highest_temperature_id , packet1.highest_temperature , packet1.highest_fan_speed , packet1.lowest_voltage_id , packet1.lowest_voltage , packet1.fault_id , packet1.fault_dc_flag , packet1.fault_fc_flag , packet1.dc_output_current , packet1.dc_input_power , packet1.dc_output_power , packet1.pressure_lowest_id , packet1.pressure_lowest , packet1.pressure_total );
    mavlink_msg_fuel_cell_status_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_status_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.system_status , packet1.load_voltage , packet1.error_code , packet1.highest_temperature_id , packet1.highest_temperature , packet1.highest_fan_speed , packet1.lowest_voltage_id , packet1.lowest_voltage , packet1.fault_id , packet1.fault_dc_flag , packet1.fault_fc_flag , packet1.dc_output_current , packet1.dc_input_power , packet1.dc_output_power , packet1.pressure_lowest_id , packet1.pressure_lowest , packet1.pressure_total );
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
    mavlink_msg_fuel_cell_status_send(MAVLINK_COMM_1 , packet1.system_status , packet1.load_voltage , packet1.error_code , packet1.highest_temperature_id , packet1.highest_temperature , packet1.highest_fan_speed , packet1.lowest_voltage_id , packet1.lowest_voltage , packet1.fault_id , packet1.fault_dc_flag , packet1.fault_fc_flag , packet1.dc_output_current , packet1.dc_input_power , packet1.dc_output_power , packet1.pressure_lowest_id , packet1.pressure_lowest , packet1.pressure_total );
    mavlink_msg_fuel_cell_status_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("FUEL_CELL_STATUS") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_FUEL_CELL_STATUS) != NULL);
#endif
}

static void mavlink_test_fuel_cell_command(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
    mavlink_status_t *status = mavlink_get_channel_status(MAVLINK_COMM_0);
        if ((status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) && MAVLINK_MSG_ID_FUEL_CELL_COMMAND >= 256) {
            return;
        }
#endif
    mavlink_message_t msg;
        uint8_t buffer[MAVLINK_MAX_PACKET_LEN];
        uint16_t i;
    mavlink_fuel_cell_command_t packet_in = {
        17235,17339,17443
    };
    mavlink_fuel_cell_command_t packet1, packet2;
        memset(&packet1, 0, sizeof(packet1));
        packet1.runtime_command = packet_in.runtime_command;
        packet1.requested_power = packet_in.requested_power;
        packet1.startup_mode = packet_in.startup_mode;
        
        
#ifdef MAVLINK_STATUS_FLAG_OUT_MAVLINK1
        if (status->flags & MAVLINK_STATUS_FLAG_OUT_MAVLINK1) {
           // cope with extensions
           memset(MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN + (char *)&packet1, 0, sizeof(packet1)-MAVLINK_MSG_ID_FUEL_CELL_COMMAND_MIN_LEN);
        }
#endif
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_command_encode(system_id, component_id, &msg, &packet1);
    mavlink_msg_fuel_cell_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_command_pack(system_id, component_id, &msg , packet1.runtime_command , packet1.requested_power , packet1.startup_mode );
    mavlink_msg_fuel_cell_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_command_pack_chan(system_id, component_id, MAVLINK_COMM_0, &msg , packet1.runtime_command , packet1.requested_power , packet1.startup_mode );
    mavlink_msg_fuel_cell_command_decode(&msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

        memset(&packet2, 0, sizeof(packet2));
        mavlink_msg_to_send_buffer(buffer, &msg);
        for (i=0; i<mavlink_msg_get_send_buffer_length(&msg); i++) {
            comm_send_ch(MAVLINK_COMM_0, buffer[i]);
        }
    mavlink_msg_fuel_cell_command_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);
        
        memset(&packet2, 0, sizeof(packet2));
    mavlink_msg_fuel_cell_command_send(MAVLINK_COMM_1 , packet1.runtime_command , packet1.requested_power , packet1.startup_mode );
    mavlink_msg_fuel_cell_command_decode(last_msg, &packet2);
        MAVLINK_ASSERT(memcmp(&packet1, &packet2, sizeof(packet1)) == 0);

#ifdef MAVLINK_HAVE_GET_MESSAGE_INFO
    MAVLINK_ASSERT(mavlink_get_message_info_by_name("FUEL_CELL_COMMAND") != NULL);
    MAVLINK_ASSERT(mavlink_get_message_info_by_id(MAVLINK_MSG_ID_FUEL_CELL_COMMAND) != NULL);
#endif
}

static void mavlink_test_custom_messages(uint8_t system_id, uint8_t component_id, mavlink_message_t *last_msg)
{
    mavlink_test_fuel_cell_status(system_id, component_id, last_msg);
    mavlink_test_fuel_cell_command(system_id, component_id, last_msg);
}

#ifdef __cplusplus
}
#endif // __cplusplus
#endif // CUSTOM_MESSAGES_TESTSUITE_H
