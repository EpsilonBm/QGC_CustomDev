/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QGroundControl.FlightDisplay

// 着陆动作按钮 - 在工具栏上显示一个着陆操作按钮
// 该按钮仅在允许着陆且不允许起飞时可见
// 按钮的启用状态取决于是否允许着陆
GuidedToolStripAction {
    text:       _guidedController.landTitle        // 按钮显示文本
    message:    _guidedController.landMessage      // 悬停时显示的消息
    iconSource: "/res/land.svg"                   // 按钮图标
    visible:    _guidedController.showLand && !_guidedController.showTakeoff // 仅当显示着陆且不显示起飞时可见
    enabled:    _guidedController.showLand         // 启用状态取决于是否显示着陆
    actionID:   _guidedController.actionLand       // 关联的动作ID
}
