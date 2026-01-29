/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay
import QGroundControl.Controllers

/*
 * 这个组件实现了飞行视图中的附加动作按钮
 * 它显示一个汉堡菜单图标，点击后会展开包含各种可执行动作的面板
 * 包括附加动作、MAVLink 动作和自定义动作
 */
ToolStripAction {
    id:         action
    text:       qsTr("自定义动作")          // 按钮文本
    iconSource: "qrc:/qmlimages/HamburgerThin.svg"  // 使用汉堡菜单图标
    // 当任意一种动作类型可用时显示按钮
    visible:    _additionalActions.anyActionAvailable || _mavlinkActions.anyActionAvailable || _customActions.anyActionAvailable
    enabled:    true

    // 引用飞控视图的引导控制器
    property var _guidedController: globals.guidedControllerFlyView

    // 附加动作列表 - 包含特定于飞行视图的动作
    property var _additionalActions: FlyViewAdditionalActionsList { 
        guidedController: _guidedController
    }

    // MAVLink 动作管理器 - 管理从配置文件加载的 MAVLink 动作
    property var _mavlinkActions: MavlinkActionManager {
        // 从设置中获取动作文件名
        actionFileNameFact: QGroundControl.settingsManager.mavlinkActionsSettings.flyViewActionsFile

        // 判断是否有可用的 MAVLink 动作（需要有激活的飞行器且至少有一个动作）
        property bool anyActionAvailable: QGroundControl.multiVehicleManager.activeVehicle && actions.count > 0
    }

    // 自定义动作列表 - 包含用户自定义的飞行视图动作
    property var _customActions: FlyViewAdditionalCustomActionsList {
        guidedController: _guidedController
    }

    // 下拉面板组件 - 定义展开时显示的面板内容
    dropPanelComponent: Component {
        FlyViewAdditionalActionsPanel { 
            additionalActions:  _additionalActions    // 传递附加动作列表
            mavlinkActions:     _mavlinkActions.actions   // 传递 MAVLink 动作列表
            customActions:      _customActions        // 传递自定义动作列表
        }
    }
}
