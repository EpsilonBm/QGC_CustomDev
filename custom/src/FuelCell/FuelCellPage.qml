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

// TODO: choose appropriate value to restructure the popup page.
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

    Component {
        id: _fuelCellContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            property var fuelCellDataList: [
                { label: qsTr("Voltage"),             fact: "loadVoltage" },
                { label: qsTr("Current"),             fact: "dcOutputCurrent" },
                { label: qsTr("Pressure"),            fact: "pressureTotal" },
                { label: qsTr("Highest temperature"), fact: "highestTemperature" },
                { label: qsTr("Instant power"),       fact: "instantPower" },
                { label: qsTr("Remaining Energy"),    fact: "remainingEnergy" },
                { label: qsTr("Remaining Time"),      fact: "remainingTime" }
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
                heading:        qsTr("Fuel Cell Status")
                contentSpacing: 0
                showDividers:   false

                Repeater {
                    model: fuelCellDataList

                    LabelledLabel {
                        property var factObj: _fuelCell ? _fuelCell[modelData.fact] : null
                        label:      modelData.label
                        labelText:  factObj ? (factObj.valueString + " " + factObj.units) : "N/A"
                        visible:    factObj !== null
                    }
                }
            }
        }
    }
    Component {
        id: _fuelCellExpandedComponent

        // The expanded view now directly shows specific fuel cell status details.
        // The complex settings UI has been removed as requested.
        SettingsGroupLayout {
            heading: qsTr("详情")

            // Display the bottle capacity
            // TODO: Add the bottle capacity choosing logic
            LabelledLabel {
                label:      qsTr("氢瓶容量")
                labelText:  (_fuelCell && _fuelCell.bottleCapacity) ? (_fuelCell.bottleCapacity.valueString + " " + _fuelCell.bottleCapacity.units) : ""
                visible:    _fuelCell && _fuelCell.bottleCapacity
            }

            SettingsGroupLayout {
                heading: qsTr("Display Options")

                FactCheckBoxSlider { // Use QGCSwitch if you only need a toggle
                    text:           qsTr("Show Percentage")
                    fact:           showPercentage
                    visible:        showPercentage ? showPercentage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("Show Voltage")
                    fact:           showVoltage
                    visible:        showVoltage ? showVoltage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("Show Remaining Time")
                    fact:           showRemainingTime
                    visible:        showRemainingTime ? showRemainingTime.visible : false
                }
            }
        }
    }
}

