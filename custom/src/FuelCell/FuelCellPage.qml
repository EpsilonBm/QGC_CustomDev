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

import Custom.ToolStrip

ToolIndicatorPage {
    id: _root
    property var _fuelCell
    property var showPercentage
    property var showVoltage
    property var showRemainingTime

    showExpand:         true
    waitForParameters:  control.waitForParameters
    contentComponent:   _fuelCellContentComponent
    expandedComponent:  _fuelCellExpandedComponent

    Connections {
        target: _fuelCell ? _fuelCell.bottleCapacity : null
        onValueChanged: {
            // TODO: Add Max energy changing logic
        }
    }

    Component {
        id: _fuelCellContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            // Define these properties at the ColumnLayout level so they are accessible to children
            property var _highestTemperatureId : _fuelCell ? _fuelCell.highestTemperatureId : null
            property var _lowestVoltageId      : _fuelCell ? _fuelCell.lowestVoltageId      : null
            property var _pressureLowestId     : _fuelCell ? _fuelCell.pressureLowestId     : null

            property var fuelCellStatusCodeList: [
                { label: qsTr("系统状态码"),     fact: "systemStatus"},
                { label: qsTr("ECU故障码"),     fact: "errorCode"},
                { label: qsTr("故障ID"),        fact: "faultId"},
                { label: qsTr("故障DC标志"),     fact: "faultDcFlag"},
                { label: qsTr("故障FC标志"),     fact: "faultFcFlag"},
            ]

            property var fuelCellDataList: [
                { label: qsTr("电堆电压"),          fact: "loadVoltage" },
                { label: qsTr("DC输出电流"),        fact: "dcOutputCurrent" },
                { label: qsTr("DC输入功率"),        fact: "dcInputPower" },
                { label: qsTr("DC输出功率"),        fact: "dcOutputPower" },
                { label: qsTr("氢瓶总压"),          fact: "pressureTotal" },
                { label: qsTr("最低氢瓶压力"),       fact: "pressureLowest" },
                { label: qsTr("最高电堆温度"),       fact: "highestTemperature" },
                { label: qsTr("最低电堆电压"),       fact: "lowestVoltage" },
                { label: qsTr("最高风扇速度"),       fact: "highestFanSpeed" },
                { label: qsTr("计算瞬时功率"),       fact: "instantPower" },
                { label: qsTr("计算平均功率"),       fact: "avgPower" },
                { label: qsTr("计算剩余电量"),       fact: "remainingEnergy" },
                { label: qsTr("预估剩余时间"),       fact: "remainingTime" }
            ]
            /*
            property var fuelCellDataList: [
                "loadVoltage",
                "dcOutputCurrent",
                "pressureTotal",
                "highestTemperature",
                "instantPower",
                "remainingEnergy",
                "remainingTime"
           ]
             */
            // NOTE: the "shortDescription" keys is written in Chinese, but it fails to load just now.
            // if it can't work, we can use the "label" keys instead.
            SettingsGroupLayout {
                heading:        qsTr("燃料电池状态码")
                contentSpacing: 0
                showDividers:   false

                Repeater {
                    model: fuelCellStatusCodeList
                    LabelledLabel {
                        property var factObj: _fuelCell ? _fuelCell[modelData.fact] : null
                        label:      modelData.label
                        labelText:  factObj ? factObj.valueString : "N/A"
                        visible:    factObj !== null
                    }
                }
            }
            SettingsGroupLayout {
                heading:        qsTr("燃料电池参数")
                contentSpacing: 0
                showDividers:   false

                Repeater {
                    model: fuelCellDataList
                    LabelledLabel {
                        property var factObj: _fuelCell ? _fuelCell[modelData.fact] : null
                        label:      modelData.label
                        labelText:  factObj ? (
                                    modelData.fact === "highestTemperature" ? (factObj.valueString + " " + factObj.units + "(" + (_highestTemperatureId ? _highestTemperatureId.valueString : "") + ")") :
                                    modelData.fact === "pressureLowest"     ? (factObj.valueString + " " + factObj.units + "(" + (_pressureLowestId ? _pressureLowestId.valueString : "") + ")") :
                                    modelData.fact === "lowestVoltage"      ? (factObj.valueString + " " + factObj.units + "(" + (_lowestVoltageId ? _lowestVoltageId.valueString : "") + ")") :
                                    factObj.valueString + " " + factObj.units) : "N/A"
                        visible:    factObj !== null
                    }
                    /*
                    LabelledLabel {
                        property var factObj: _fuelCell ? _fuelCell[modelData] : null
                        //label:      factObj ? (factObj.shortDescription ? factObj.shortDescription : factObj.name) : ""
                        label:      factObbj.shortDescription
                        labelText:  factObj ? (factObj.valueString + " " + factObj.units) : "N/A"
                        visible:    factObj !== null
                    }
                     */
                }

            }

        }
    }
    Component {
        id: _fuelCellExpandedComponent

        ColumnLayout{
            spacing:  ScreenTools.defaultFontPixelHeight
            SettingsGroupLayout {
                heading: qsTr("氢瓶配置")

                property real sliderWidth: ScreenTools.defaultFontPixelWidth * 40
                FactSlider {
                    Layout.fillWidth:       true
                    Layout.preferredWidth:  sliderWidth
                    label:                  qsTr("氢瓶容量")
                    fact:                   _fuelCell.bottleCapacity
                    majorTickStepSize:      0.1
                    visible:                _fuelCell && _fuelCell.bottleCapacity
                }
                LabelledLabel {
                    label:      qsTr("最大电量")
                    labelText:  (_fuelCell && _fuelCell.maxEnergy) ? (_fuelCell.maxEnergy.valueString + " " + _fuelCell.maxEnergy.units) : ""
                    visible:    _fuelCell && _fuelCell.maxEnergy
                }
            }
            SettingsGroupLayout {
                heading: qsTr("显示选项")

                FactCheckBoxSlider { // Use QGCSwitch if you only need a toggle
                    text:           qsTr("显示电量百分比")
                    fact:           showPercentage
                    visible:        showPercentage ? showPercentage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("显示电压")
                    fact:           showVoltage
                    visible:        showVoltage ? showVoltage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("显示预估剩余时间")
                    fact:           showRemainingTime
                    visible:        showRemainingTime ? showRemainingTime.visible : false
                }
            }
            SettingsGroupLayout{
                heading: qsTr("开发者工具")
                LabelledButton{
                    label:      qsTr("发送燃料电池命令")
                    buttonText: qsTr("命令配置")
                    onClicked: {
                        _fuelCellCommandPage.createObject(mainWindow).open()
                    }
                }
            }
        }
    }
    Component {
        id: _fuelCellCommandPage
        FuelCellCommandPage {}
    }
}
