/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
// 导入Qt Quick模块，提供基本的QML功能
import QtQuick

// 导入QGroundControl相关模块，包括控件、控制器、屏幕工具和调色板
import QGroundControl
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.ScreenTools
import QGroundControl.Palette

// 主容器项，用于实现机载云台控制器
Item {
    id:             rootItem
    anchors.fill:   parent

    // 屏幕坐标属性，用于存储当前触摸/点击位置
    property var screenX
    property var screenY
    // 存储初始速率控制坐标值，用于计算相对移动
    property var screenXrateInitCoocked
    property var screenYrateInitCoocked

    // 获取当前激活的飞行器对象
    property var  activeVehicle:                QGroundControl.multiVehicleManager.activeVehicle
    // 获取飞行器的云台控制器
    property var  gimbalController:             activeVehicle ? activeVehicle.gimbalController : undefined
    // 获取活动的云台设备
    property var  activeGimbal:                 gimbalController ? gimbalController.activeGimbal : undefined
    // 判断云台是否可用
    property bool gimbalAvailable:              activeGimbal != undefined
    // 获取云台控制器设置
    property var  gimbalControllerSettings:     QGroundControl.settingsManager.gimbalControllerSettings
    property bool cameraTrackingEnabled:        false // Used to ignore clicks when camera tracking operation is active, otherwise it would collide with these gimbal controls
    property bool shouldProcessClicks:          gimbalControllerSettings.EnableOnScreenControl.value && activeGimbal && !cameraTrackingEnabled ? true : false

    // 处理点击控制逻辑
    function clickControl() {
        if (!shouldProcessClicks) {
            return
        }
        // If click and slide control, return, it uses press and release
        if (!gimbalControllerSettings.ControlType.rawValue == 0) {
            return
        }
        // 执行点击定位控制
        clickAndPoint(x, y)
    }

    // Sends a +-(0-1) xy value to vehicle.gimbalController.gimbalOnScreenControl
    function clickAndPoint() {
        if (rootItem.gimbalAvailable) {
            // 将屏幕坐标转换为标准化的-1到1之间的值
            var xCoocked =  ( (screenX / parent.width)  * 2) - 1
            var yCoocked = -( (screenY / parent.height) * 2) + 1
            // 控制台输出调试信息
            // console.log("X global: " + x + " Y global: " + y)
            // console.log("X coocked: " + xCoocked + " Y coocked: " + yCoocked)
            // 发送控制命令到云台
            gimbalController.gimbalOnScreenControl(xCoocked, yCoocked, true, false, false)
        } else {
            // We should never be here
            console.log("gimbal not available")
        }
    }

    // 处理按下控制逻辑，用于速率控制模式
    function pressControl() {
        if (!shouldProcessClicks) {
            return
        }
        // If click and point control return, that is handled exclusively on clickAndPoint()
        if (!gimbalControllerSettings.ControlType.rawValue == 1) {
            return
        }
        // 启动定时器，开始发送速率控制命令
        sendRateTimer.start()
        // 计算并保存初始坐标值，用于后续计算相对偏移
        screenXrateInitCoocked =  ( ( screenX / parent.width)  * 2) - 1
        screenYrateInitCoocked = -( ( screenY / parent.height) * 2) + 1
    }

    // 处理释放控制逻辑，停止速率控制
    function releaseControl() {
        if (!shouldProcessClicks) {
            return
        }
        // If click and point control return, that is handled exclusively on clickAndPoint()
        if (!gimbalControllerSettings.ControlType.rawValue == 1) {
            return
        }
        // 停止定时器，结束速率控制
        sendRateTimer.stop()
        // 清空初始坐标值
        screenXrateInitCoocked = null
        screenYrateInitCoocked = null
    }

    // 定时器，用于定期发送速率控制命令
    Timer {
        id:             sendRateTimer
        interval:       100      // 每100毫秒触发一次
        repeat:         true     // 重复执行
        onTriggered: {
            if (rootItem.gimbalAvailable) {
                // 将当前屏幕坐标转换为标准化值
                var xCoocked =  ( ( screenX / parent.width)  * 2) - 1
                var yCoocked = -( ( screenY / parent.height) * 2) + 1
                // 计算相对于初始按压位置的偏移量
                xCoocked -= screenXrateInitCoocked
                yCoocked -= screenYrateInitCoocked
                // 发送速率控制命令到云台
                gimbalController.gimbalOnScreenControl(xCoocked, yCoocked, false, true, true)
            } else {
                console.log("gimbal not available")
            }
        }
    }
}