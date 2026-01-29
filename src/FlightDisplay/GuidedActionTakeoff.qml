/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QGroundControl.FlightDisplay

// 定义引导模式工具栏的起飞动作按钮
// 包含按钮文本、图标、可见性、启用状态和动作ID
GuidedToolStripAction {
    text:       _guidedController.takeoffTitle      // 按钮显示的文本标题
    iconSource: "/res/takeoff.svg"                  // 按钮图标路径
    visible:    _guidedController.showTakeoff || !_guidedController.showLand  // 控制按钮是否可见
    enabled:    _guidedController.showTakeoff       // 控制按钮是否可点击
    actionID:   _guidedController.actionTakeoff     // 对应的动作ID
}
