/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.AutoPilotPlugin
import MAVLink

//-------------------------------------------------------------------------
//-- 电池指示器 - 在QGroundControl中显示电池信息的主要组件
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          batteryIndicatorRow.width

    // 控制指示器可见性的属性
    property bool       showIndicator:      true
    // 如果为真，则参数准备就绪之前不会显示UI
    property bool       waitForParameters:  false   
    // 展开指示器时显示的组件
    property Component  expandedPageComponent

    // 当前活动飞行器的引用
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    // 电池指示器设置的引用
    property var    _batterySettings:   QGroundControl.settingsManager.batteryIndicatorSettings
    // 当前显示模式设置（百分比、电压或两者）
    property Fact   _indicatorDisplay:  _batterySettings.valueDisplay
    // 在指示器中仅显示百分比
    property bool   _showPercentage:    _indicatorDisplay.rawValue === 0
    // 在指示器中仅显示电压
    property bool   _showVoltage:       _indicatorDisplay.rawValue === 1
    // 在指示器中同时显示百分比和电压
    property bool   _showBoth:          _indicatorDisplay.rawValue === 2

    // 存储电池等级颜色阈值的属性
    property int threshold1: _batterySettings.threshold1.rawValue  // 较高阈值（绿色到黄绿色过渡）
    property int threshold2: _batterySettings.threshold2.rawValue  // 较低阈值（黄绿色到黄色过渡）   

    // 包含所有电池指示器的行（支持多电池）
    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        // 为活动飞行器中的每个电池创建视觉指示器
        Repeater {
            model: _activeVehicle ? _activeVehicle.batteries : 0

            Loader {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                sourceComponent:    batteryVisual

                // 将电池对象传递给视觉组件
                property var battery: object
            }
        }
    }
    
    // 处理电池指示器上的点击事件的鼠标区域
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            // 点击时显示详细的电池信息面板
            mainWindow.showIndicatorDrawer(batteryPopup, control)
        }
    }

    // 弹出组件，用于显示详细的电池信息
    Component {
        id: batteryPopup

        ToolIndicatorPage {
            // 如果有扩展组件可用则显示展开按钮
            showExpand:         expandedComponent ? true : false
            // 在显示内容前等待参数
            waitForParameters:  control.waitForParameters
            // 主内容区域的组件
            contentComponent:   batteryContentComponent
            // 扩展视图的组件
            expandedComponent:  batteryExpandedComponent
        }
    }

    // 定义每个电池如何进行视觉表示的组件
    Component {
        id: batteryVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom

            // 根据充电状态和百分比确定电池图标颜色的函数
            function getBatteryColor() {
                switch (battery.chargeState.rawValue) {
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
                        // 如果可用，基于百分比阈值着色
                        if (!isNaN(battery.percentRemaining.rawValue)) {
                            if (battery.percentRemaining.rawValue > threshold1) {
                                return qgcPal.colorGreen 
                            } else if (battery.percentRemaining.rawValue > threshold2) {
                                return qgcPal.colorYellowGreen 
                            } else {
                                return qgcPal.colorYellow 
                            }
                        } else {
                            // 百分比不可用时的默认颜色
                            return qgcPal.text
                        }
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
                        return qgcPal.colorOrange
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
                        return qgcPal.colorRed
                    default:
                        return qgcPal.text
                }
            }    

            // 基于电池状态选择适当SVG图像的函数
            function getBatterySvgSource() {
                switch (battery.chargeState.rawValue) {
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
                        // 根据百分比阈值选择不同的图像
                        if (!isNaN(battery.percentRemaining.rawValue)) {
                            if (battery.percentRemaining.rawValue > threshold1) {
                                return "/qmlimages/BatteryGreen.svg"
                            } else if (battery.percentRemaining.rawValue > threshold2) {
                                return "/qmlimages/BatteryYellowGreen.svg"
                            } else {
                                return "/qmlimages/BatteryYellow.svg"    
                            } 
                        }
                        // 如果没有百分比则继续执行默认情况
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
                        return "/qmlimages/BatteryOrange.svg" // 低电量橙色svg
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
                        return "/qmlimages/BatteryCritical.svg" // 危险红色svg
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
                    case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
                        return "/qmlimages/BatteryEMERGENCY.svg" // 危险状态感叹号
                    default:
                        return "/qmlimages/Battery.svg" // 百分比不可用时的备用
                }
            }

            // 获取用于显示电池百分比文本的函数
            function getBatteryPercentageText() {
                if (!isNaN(battery.percentRemaining.rawValue)) {
                    // 将高百分比四舍五入到100%
                    if (battery.percentRemaining.rawValue > 98.9) {
                        return qsTr("100%")
                    } else {
                        // 显示实际百分比带单位
                        return battery.percentRemaining.valueString + battery.percentRemaining.units
                    }
                } else if (!isNaN(battery.voltage.rawValue)) {
                    // 百分比不可用时回退到电压
                    return battery.voltage.valueString + battery.voltage.units
                } else if (battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED) {
                    // 如果可用显示充电状态
                    return battery.chargeState.enumStringValue
                }
                // 如果都没有则返回n/a
                return qsTr("n/a")
            }

            // 获取用于显示电池电压文本的函数
            function getBatteryVoltageText() {
                if (!isNaN(battery.voltage.rawValue)) {
                    // 显示电压带单位
                    return battery.voltage.valueString + battery.voltage.units
                } else if (battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED) {
                    // 电压不可用时显示充电状态
                    return battery.chargeState.enumStringValue
                }
                // 如果都没有则返回n/a
                return qsTr("n/a")
            }

            // 具有动态源和颜色的电池图标图像
            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             getBatterySvgSource()
                fillMode:           Image.PreserveAspectFit
                color:              getBatteryColor()
            }

            // 电池信息列布局（百分比和/或电压）
           ColumnLayout {
                id:                     batteryInfoColumn
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                spacing:                0

                // 百分比显示标签
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryPercentageText()
                    font.pointSize:         _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    visible:                _showBoth || _showPercentage
                }

                // 电压显示标签
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    font.pointSize:         _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    color:                  qgcPal.text
                    text:                   getBatteryVoltageText()
                    visible:                _showBoth || _showVoltage
                }
            }
        }
    }

    // 定义详细电池信息内容的组件
    Component {
        id: batteryContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            // 检查哪些电池属性可用的帮助组件
            Component {
                id: batteryValuesAvailableComponent

                QtObject {
                    // 检查电池功能是否已知
                    property bool functionAvailable:         battery.function.rawValue !== MAVLink.MAV_BATTERY_FUNCTION_UNKNOWN
                    // 如果定义了功能且不为"全部"则显示
                    property bool showFunction:              functionAvailable && battery.function.rawValue != MAVLink.MAV_BATTERY_FUNCTION_ALL
                    // 检查温度是否有效
                    property bool temperatureAvailable:      !isNaN(battery.temperature.rawValue)
                    // 检查电流是否有效
                    property bool currentAvailable:          !isNaN(battery.current.rawValue)
                    // 检查已消耗毫安时是否有效
                    property bool mahConsumedAvailable:      !isNaN(battery.mahConsumed.rawValue)
                    // 检查剩余时间是否有效
                    property bool timeRemainingAvailable:    !isNaN(battery.timeRemaining.rawValue)
                    // 检查剩余百分比是否有效
                    property bool percentRemainingAvailable: !isNaN(battery.percentRemaining.rawValue)
                    // 检查充电状态是否已定义
                    property bool chargeStateAvailable:      battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED
                }
            }

            // 对活动飞行器中的每个电池重复
            Repeater {
                model: _activeVehicle ? _activeVehicle.batteries : 0

                SettingsGroupLayout {
                    // 根据电池数量设置标题
                    heading:        qsTr("电池 %1").arg(_activeVehicle.batteries.length === 1 ? qsTr("Status") : object.id.rawValue)
                    contentSpacing: 0
                    showDividers:   false

                    // 访问此电池的可用性检查
                    property var batteryValuesAvailable: batteryValuesAvailableLoader.item

                    // 为此电池加载可用性检查器
                    Loader {
                        id:                 batteryValuesAvailableLoader
                        sourceComponent:    batteryValuesAvailableComponent

                        // 将电池对象传递给可用性检查器
                        property var battery: object
                    }

                    // 如果可用则显示电池状态
                    LabelledLabel {
                        label:  qsTr("电池状态")
                        labelText:  object.chargeState.enumStringValue
                        visible:    batteryValuesAvailable.chargeStateAvailable
                    }

                    // 如果可用则显示剩余时间
                    LabelledLabel {
                        label:      qsTr("剩余时间")
                        labelText:  object.timeRemainingStr.value
                        visible:    batteryValuesAvailable.timeRemainingAvailable
                    }

                    // 如果可用则显示剩余百分比
                    LabelledLabel {
                        label:      qsTr("剩余电量")
                        labelText:  object.percentRemaining.valueString + " " + object.percentRemaining.units
                        visible:    batteryValuesAvailable.percentRemainingAvailable
                    }

                    // 始终显示电压（如果不可用则显示n/a）
                    LabelledLabel {
                        label:      qsTr("电压")
                        labelText:  object.voltage.valueString + " " + object.voltage.units
                    }

                    // 如果可用则显示已消耗毫安时
                    LabelledLabel {
                        label:      qsTr("已消耗毫安时")
                        labelText:  object.mahConsumed.valueString + " " + object.mahConsumed.units
                        visible:    batteryValuesAvailable.mahConsumedAvailable
                    }

                    // 如果可用则显示温度
                    LabelledLabel {
                        label:      qsTr("温度")
                        labelText:  object.temperature.valueString + " " + object.temperature.units
                        visible:    batteryValuesAvailable.temperatureAvailable
                    }

                    // 如果可用且相关则显示电池功能
                    LabelledLabel {
                        label:      qsTr("电池功能")
                        labelText:  object.function.enumStringValue
                        visible:    batteryValuesAvailable.showFunction
                    }
                }
            }
        }
    }

    // 定义扩展电池设置视图的组件
    Component {
        id: batteryExpandedComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            FactPanelController { id: controller }

            SettingsGroupLayout {
                heading:            qsTr("电池显示")
                Layout.fillWidth:   true

                // 选择要显示的值的下拉菜单
                LabelledFactComboBox {
                    id:             editModeCheckBox
                    label:          qsTr("显示值")
                    fact:           _fact
                    visible:        _fact.visible

                    property Fact _fact: QGroundControl.settingsManager.batteryIndicatorSettings.valueDisplay
                }

                // 颜色配置选项的布局
                ColumnLayout {
                    QGCLabel { text: qsTr("电池颜色") }

                    RowLayout {
                        spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 元素之间减少间距

                        // 100%电池电量的视觉表示
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 图标和标签的紧密间距
                            QGCColoredImage {
                                source: "/qmlimages/BatteryGreen.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorGreen
                            }
                            QGCLabel { text: qsTr("100%") }
                        }

                        // 第一个阈值的配置
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 图标和字段的紧密间距
                            QGCColoredImage {
                                source: "/qmlimages/BatteryYellowGreen.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorYellowGreen
                            }
                            FactTextField {
                                id: threshold1Field
                                fact: _batterySettings.threshold1
                                implicitWidth: ScreenTools.defaultFontPixelWidth * 6
                                height: ScreenTools.defaultFontPixelHeight * 1.5
                                enabled: fact.visible
                                onEditingFinished: {
                                    // 验证并设置新的阈值
                                    _batterySettings.setThreshold1(parseInt(text));
                                }
                            }
                        }

                        // 第二个阈值的配置
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 图标和字段的紧密间距
                            QGCColoredImage {
                                source: "/qmlimages/BatteryYellow.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorYellow
                            }
                            FactTextField {
                                fact: _batterySettings.threshold2
                                implicitWidth: ScreenTools.defaultFontPixelWidth * 6
                                height: ScreenTools.defaultFontPixelHeight * 1.5
                                enabled: fact.visible
                                onEditingFinished: {
                                    // 验证并设置新的阈值
                                    _batterySettings.setThreshold2(parseInt(text));                                
                                }
                            }
                        }

                        // 低电量状态的视觉表示
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 图标和标签的紧密间距
                            QGCColoredImage {
                                source: "/qmlimages/BatteryOrange.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorOrange
                            }
                            QGCLabel { text: qsTr("50%") }
                        }

                        // 危险电量状态的视觉表示
                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth * 0.05  // 图标和标签的紧密间距
                            QGCColoredImage {
                                source: "/qmlimages/BatteryCritical.svg"
                                width: ScreenTools.defaultFontPixelWidth * 6
                                height: width
                                fillMode: Image.PreserveAspectFit
                                color: qgcPal.colorRed
                            }
                            QGCLabel { text: qsTr("30%") }
                        }
                    }
                }
            }

            // 附加扩展页面内容的加载器
            Loader {
                Layout.fillWidth: true
                sourceComponent: expandedPageComponent
            }

            // 飞行器电源配置部分（仅在特定条件下可见）
            SettingsGroupLayout {
                visible: _activeVehicle.autopilotPlugin.knownVehicleComponentAvailable(AutoPilotPlugin.KnownPowerVehicleComponent) &&
                            QGroundControl.corePlugin.showAdvancedUI

                LabelledButton {
                    label:      qsTr("Vehicle Power")
                    buttonText: qsTr("Configure")

                    onClicked: {
                        // 导航到飞行器电源配置页面
                        mainWindow.showKnownVehicleComponentConfigPage(AutoPilotPlugin.KnownPowerVehicleComponent)
                        // 导航后关闭指示器抽屉
                        mainWindow.closeIndicatorDrawer()
                    }
                }                
            }
        }
    }
}
