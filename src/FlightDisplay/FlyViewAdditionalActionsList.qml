/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml

QtObject {
    property var guidedController

    // 检查是否有任何动作可用 - 如果任何一个操作显示为true，则表示有可用的操作
    property bool anyActionAvailable: guidedController.showStartMission || 
                                      guidedController.showContinueMission || 
                                      guidedController.showChangeAlt || 
                                      guidedController.showChangeLoiterRadius ||  
                                      guidedController.showLandAbort || 
                                      guidedController.showChangeSpeed ||
                                      guidedController.showGripper

    // 定义动作列表的数据模型，每个对象代表一个可执行的动作
    property var model: [
        // 开始任务动作
        {
            title:      guidedController.startMissionTitle,
            text:       guidedController.startMissionMessage,
            action:     guidedController.actionStartMission,
            visible:    guidedController.showStartMission
        },
        // 继续任务动作
        {
            title:      guidedController.continueMissionTitle,
            text:       guidedController.continueMissionMessage,
            action:     guidedController.actionContinueMission,
            visible:    guidedController.showContinueMission
        },
        // 改变高度动作
        {
            title:      guidedController.changeAltTitle,
            text:       guidedController.changeAltMessage,
            action:     guidedController.actionChangeAlt,
            visible:    guidedController.showChangeAlt
        },
        // 改变盘旋半径动作
        {
            title:      guidedController.changeLoiterRadiusTitle,
            text:       guidedController.changeLoiterRadiusMessage,
            action:     guidedController.actionChangeLoiterRadius,
            visible:    guidedController.showChangeLoiterRadius
        },
        // 着陆中止动作
        {
            title:      guidedController.landAbortTitle,
            text:       guidedController.landAbortMessage,
            action:     guidedController.actionLandAbort,
            visible:    guidedController.showLandAbort
        },
        // 改变速度动作
        {
            title:      guidedController.changeSpeedTitle,
            text:       guidedController.changeSpeedMessage,
            action:     guidedController.actionChangeSpeed,
            visible:    guidedController.showChangeSpeed
        },
        // 机械臂控制动作
        {
            title:      guidedController.gripperTitle,
            text:       guidedController.gripperMessage,
            action:     guidedController.actionGripper,
            visible:    guidedController.showGripper
        }
    ]
}
