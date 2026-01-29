/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
#pragma once

#include "SettingsGroup.h"

/**
 * @brief 云台控制器设置类
 *
 * 此类管理云台控制器的各种设置，包括屏幕控制、控制类型、相机参数、
 * 方位指示器显示选项和摇杆按钮速度等。
 */
class GimbalControllerSettings : public SettingsGroup
{
    Q_OBJECT

public:
    explicit GimbalControllerSettings(QObject* parent = nullptr);

    // 定义设置组名称
    DEFINE_SETTING_NAME_GROUP()

    // 云台屏幕控制相关设置
    DEFINE_SETTINGFACT(EnableOnScreenControl)              ///< 是否启用屏幕控制
    DEFINE_SETTINGFACT(ControlType)                        ///< 控制类型设置

    // 相机参数设置
    DEFINE_SETTINGFACT(CameraVFov)                         ///< 相机垂直视场角
    DEFINE_SETTINGFACT(CameraHFov)                         ///< 相机水平视场角
    DEFINE_SETTINGFACT(CameraSlideSpeed)                   ///< 相机滑动速度

    // 指示器显示设置
    DEFINE_SETTINGFACT(showAzimuthIndicatorOnMap)          ///< 是否在地图上显示方位指示器
    DEFINE_SETTINGFACT(toolbarIndicatorShowAzimuth)        ///< 工具栏指示器是否显示方位信息
    DEFINE_SETTINGFACT(toolbarIndicatorShowAcquireReleaseControl) ///< 工具栏指示器是否显示获取/释放控制按钮

    // 操作设置
    DEFINE_SETTINGFACT(joystickButtonsSpeed);              ///< 摇杆按钮速度设置
};