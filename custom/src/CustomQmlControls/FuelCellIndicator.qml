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
//-- FuelCell Indicator from Battery Indicator
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          fuelCellIndicatorRow.width

    property bool       showIndicator:      true
    property bool       waitForParameters:  false   // UI won't show until parameters are ready
    property Component  expandedPageComponent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _batterySettings:   QGroundControl.settingsManager.batteryIndicatorSettings
    // TODO: Add fuelcell indicator setting and replace these all
    // property Fact   _indicatorDisplay:  _batterySettings.valueDisplay
    // property bool   _showPercentage:    _indicatorDisplay.rawValue === 0
    // property bool   _showVoltage:       _indicatorDisplay.rawValue === 1
    // property bool   _showBoth:          _indicatorDisplay.rawValue === 2
    // fuelCell object
    property var fuelCell: _activeVehicle ? _activeVehicle.fuelCell : null

    // Properties to hold the thresholds
    // property int threshold1: _batterySettings.threshold1.rawValue
    // property int threshold2: _batterySettings.threshold2.rawValue

    // 燃料电池指示器行 - 显示燃料电池的基本状态信息
    Row {
        id:             fuelCellIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        // Since there is only one FuelCellManager, we don't need a Repeater.
        // We use a Loader and make it visible if the fuelCellManager exists.
        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceComponent:    fuelCellVisual
            visible:            control.fuelCell !== null
        }
    }
    
    // 鼠标区域 - 处理点击事件以显示燃料池弹出窗口
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            // 显示带有弹出组件的燃料池信息抽屉
            mainWindow.showIndicatorDrawer(fuelCellPopup, control)
        }
    }

    /* fuelCellPopup
    *  called from: MouseArea
    *  call       : fuelCellContentComponent fuelCellExpandedComponent
    *  function   : show the information in two pages.
    */
    Component {
        id: fuelCellPopup

        ToolIndicatorPage {
            showExpand:         expandedComponent ? true : false
            waitForParameters:  control.waitForParameters
            contentComponent:   fuelCellContentComponent
            expandedComponent:  fuelCellExpandedComponent
        }
    }

    // fuelCellVisual
    /* fuelCell visual indicator
    *  called from: fuelCellIndicatorRow
    *  function   : show the battery icon and some important information
    */
    Component {
        id: fuelCellVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom

            function getBatteryColor() {
                if (fuelCell && fuelCell.percentRemaining) {
                    var p = fuelCell.percentRemaining.value
                    if (p > 90) return qgcPal.colorGreen
                    if (p > 70) return qgcPal.colorYellowGreen
                    if (p > 50) return qgcPal.colorYellow
                    if (p > 30) return qgcPal.colorOrange
                    return qgcPal.colorRed // Critical (30-10) & Emergency (10-0)
                }
                return qgcPal.text
            }    

            function getBatterySvgSource() {
                if (fuelCell && fuelCell.percentRemaining) {
                    var p = fuelCell.percentRemaining.value
                    if (p > 90) return "qrc:/custom/img/BatteryGreen.svg"
                    if (p > 70) return "qrc:/custom/img/BatteryYellowGreen.svg"
                    if (p > 50) return "qrc:/custom/img/BatteryYellow.svg"
                    if (p > 30) return "qrc:/custom/img/BatteryOrange.svg"
                    if (p > 10) return "qrc:/custom/img/BatteryCritical.svg"
                    return "qrc:/custom/img/BatteryEMERGENCY.svg"
                }
                return "qrc:/custom/img/Battery.svg"
            }

            function getBatteryPercentageText() {
                if (fuelCell && fuelCell.percentRemaining) {
                    // 直接显示百分比数值
                    return fuelCell.percentRemaining.valueString + "%"
                }
                return qsTr("n/a")
            }

            function getBatteryVoltageText() {
                if (fuelCell && fuelCell.loadVoltage) {
                    // Use loadVoltage from the new FactGroup
                    return fuelCell.loadVoltage.valueString + " " + fuelCell.loadVoltage.units
                }
                return qsTr("n/a")
            }

            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             getBatterySvgSource()
                fillMode:           Image.PreserveAspectFit
                color:              getBatteryColor()
            }

           ColumnLayout {
                id:                     batteryInfoColumn
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                spacing:                0

                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryPercentageText()
                    // TODO: add switching logic after setting is added
                    //font.pointSize:         _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    //visible:                _showBoth || _showPercentage
                    font.pointSize:         ScreenTools.defaultFontPointSize
                    visible:                true
                }

                // TODO: add switching logic after setting is added
                // QGCLabel {
                //     Layout.alignment:       Qt.AlignHCenter
                //     font.pointSize:         _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                //     color:                  qgcPal.text
                //     text:                   getBatteryVoltageText()
                //     visible:                _showBoth || _showVoltage
                // }
            }
        }
    }

    /* fuelCellContentComponent
    *  called from: fuelCellPopup
    *  function   : show temperature current mah timeRemaining percentRemaining
    */
    Component {
        id: fuelCellContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            Component {
                id: fuelCellValuesAvailableComponent

                QtObject {
                    property bool voltageAvailable:          control.fuelCell && control.fuelCell.loadVoltage
                    property bool currentAvailable:          control.fuelCell && control.fuelCell.dcOutputCurrent
                    property bool pressureAvailable:         control.fuelCell && control.fuelCell.pressureLowest
                    property bool temperatureAvailable:      control.fuelCell && control.fuelCell.highestTemperature
                    property bool powerAvailable:            control.fuelCell && control.fuelCell.instantPower // This is the calculated power
                    property bool remainingEnergyAvailable:  control.fuelCell && control.fuelCell.remainingEnergy
                    property bool remainingTimeAvailable:    control.fuelCell && control.fuelCell.remainingTime
                }
            }

            // 燃料电池主要状态数据显示区域
            // 这部分代码创建了一个设置组布局，用于显示燃料电池的关键运行参数
            // 包括电压、电流、压力、温度、功率、剩余能量和剩余时间等信息
            // 所有数据显示都是基于实际的燃料电池传感器数据，并且只有在数据有效时才显示对应项
            Repeater {
                model: 1

                SettingsGroupLayout {
                    heading:        qsTr("燃料电池状态")  // 设置组标题，显示"Fuel Cell Status"
                    contentSpacing: 0                        // 设置组内部内容之间无额外间距
                    showDividers:   false                    // 不显示各项目之间的分隔线

                    // 获取燃料值可用性检查组件的实例，用于判断各项数据是否可用
                    property var fuelCellValuesAvailable: fuelCellValuesAvailableLoader.item

                    // 加载燃料值可用性检查组件，用于动态检查各个传感器数据是否可用
                    Loader {
                        id:                 fuelCellValuesAvailableLoader
                        sourceComponent:    fuelCellValuesAvailableComponent

                        // 将父级的fuelCell对象传递给加载的组件，确保子组件可以访问相同的fuelCell数据
                        property var fuelCell: parent.fuelCell
                    }

                    // 电压显示项：显示燃料电池的负载电压
                    // 通过fuelCell.loadVoltage获取电压值和单位，并在电压数据可用时显示
                    LabelledLabel {
                        label:      qsTr("电压")                                  // 显示标签"Voltage"
                        labelText:  fuelCell.loadVoltage.valueString + " " + fuelCell.loadVoltage.units
                        visible:    fuelCellValuesAvailable.voltageAvailable         // 仅当电压数据可用时可见
                    }

                    // 电流显示项：显示燃料电池的直流输出电流
                    // 通过fuelCell.dcOutputCurrent获取电流值和单位，并在电流数据可用时显示
                    LabelledLabel {
                        label:      qsTr("电流")                                  // 显示标签"Current"
                        labelText:  fuelCell.dcOutputCurrent.valueString + " " + fuelCell.dcOutputCurrent.units
                        visible:    fuelCellValuesAvailable.currentAvailable         // 仅当电流数据可用时可见
                    }

                    // 压力显示项：显示燃料电池系统的最低压力值
                    // 通过fuelCell.pressureLowest获取压力值和单位，并在压力数据可用时显示
                    LabelledLabel {
                        label:      qsTr("压力值")                                 // 显示标签"Pressure"
                        labelText:  fuelCell.pressureLowest.valueString + " " + fuelCell.pressureLowest.units
                        visible:    fuelCellValuesAvailable.pressureAvailable        // 仅当压力数据可用时可见
                    }

                    // 最高温度显示项：显示燃料电池系统的最高温度值
                    // 通过fuelCell.highestTemperature获取温度值和单位，并在温度数据可用时显示
                    LabelledLabel {
                        label:      qsTr("最高温度")                      // 显示标签"Highest temperature"
                        labelText:  fuelCell.highestTemperature.valueString + " " + fuelCell.highestTemperature.units
                        visible:    fuelCellValuesAvailable.temperatureAvailable     // 仅当温度数据可用时可见
                    }

                    // 瞬时功率显示项：显示燃料电池的瞬时功率输出
                    // 通过fuelCell.instantPower获取功率值和单位，并在功率数据可用时显示
                    LabelledLabel {
                        label:      qsTr("瞬时功率")                            // 显示标签"Instant power"
                        labelText:  fuelCell.instantPower.valueString + " " + fuelCell.instantPower.units
                        visible:    fuelCellValuesAvailable.powerAvailable           // 仅当功率数据可用时可见
                    }

                    // 剩余能量显示项：显示燃料电池系统当前剩余的能量
                    // 通过fuelCell.remainingEnergy获取能量值和单位，并在剩余能量数据可用时显示
                    LabelledLabel {
                        label:      qsTr("剩余电量")                         // 显示标签"Remaining Energy"
                        labelText:  fuelCell.remainingEnergy.valueString + " " + fuelCell.remainingEnergy.units
                        visible:    fuelCellValuesAvailable.remainingEnergyAvailable // 仅当剩余能量数据可用时可见
                    }

                    // 剩余时间显示项：显示燃料电池系统预估的剩余运行时间
                    // 通过fuelCell.remainingTime获取时间值和单位，并在剩余时间数据可用时显示
                    LabelledLabel {
                        label:      qsTr("预计剩余时间")                           // 显示标签"Remaining Time"
                        labelText:  fuelCell.remainingTime.valueString + " " + fuelCell.remainingTime.units
                        visible:    fuelCellValuesAvailable.remainingTimeAvailable   // 仅当剩余时间数据可用时可见
                    }
                }
            }
        }
    }

    // TODO: choose appropriate value to restructure the popup page.
    /* fuelCellExpandedComponent
    *  called from: fuelCellPopup
    *  function   :
    */
    Component {
        id: fuelCellExpandedComponent

        // The expanded view now directly shows specific fuel cell status details.
        // The complex settings UI has been removed as requested.
        SettingsGroupLayout {
            heading: qsTr("详情")

            property var fuelCell: _activeVehicle ? _activeVehicle.fuelCell : null
            property var expandedValuesAvailable: expandedValuesAvailableLoader.item

            // Loader for the availability check component
            Loader {
                id:                 expandedValuesAvailableLoader
                sourceComponent:    expandedValuesAvailableComponent
                property var fuelCell: parent.fuelCell
            }

            // Component to check if facts are available
            Component {
                id: expandedValuesAvailableComponent
                QtObject {
                    property bool statusAvailable:           control.fuelCell && control.fuelCell.status
                    property bool bottleCapacityAvailable:   control.fuelCell && control.fuelCell.bottleCapacity
                }
            }

            // Display the current status
            // TODO: Get the statue code define from the SEEEX
            // LabelledLabel {
            //     label:      qsTr("Status")
            //     labelText:  control.fuelCell.status.valueString
            //     labelText:  control.fuelCell.status
            //     visible:    expandedValuesAvailable.statusAvailable
            // }
            //
            // // Display alert information based on status
            // LabelledLabel {
            //     label:      qsTr("Alerts")
            //     labelText:  control.fuelCell.status.valueString === "NORMAL" ? qsTr("No Alerts") : qsTr("Check Status!")
            //     visible:    expandedValuesAvailable.statusAvailable
            // }

            // Display the bottle capacity
            LabelledLabel {
                label:      qsTr("氢瓶容量")
                labelText:  control.fuelCell.bottleCapacity.valueString + " " + control.fuelCell.bottleCapacity.units
                visible:    expandedValuesAvailable.bottleCapacityAvailable
            }
        }
    }
}
