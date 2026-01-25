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
    width:          batteryIndicatorRow.width

    property bool       showIndicator:      true
    property bool       waitForParameters:  false   // UI won't show until parameters are ready
    property Component  expandedPageComponent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _batterySettings:   QGroundControl.settingsManager.batteryIndicatorSettings
    property Fact   _indicatorDisplay:  _batterySettings.valueDisplay
    property bool   _showPercentage:    _indicatorDisplay.rawValue === 0
    property bool   _showVoltage:       _indicatorDisplay.rawValue === 1
    property bool   _showBoth:          _indicatorDisplay.rawValue === 2

    // Properties to hold the thresholds
    property int threshold1: _batterySettings.threshold1.rawValue
    property int threshold2: _batterySettings.threshold2.rawValue   

    // batteryIndicatorRow
    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        // Since there is only one FuelCellManager, we don't need a Repeater.
        // We use a Loader and make it visible if the fuelCellManager exists.
        Loader {
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            sourceComponent:    batteryVisual
            visible:            fuelCell !== null
            property var fuelCell: _activeVehicle ? _activeVehicle.fuelCellManager : null
        }
    }
    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorDrawer(batteryPopup, control)
        }
    }

    /* batteryPopup
    *  called from: MouseArea
    *  call       : batteryContentComponent batteryExpandedComponent
    *  function   : show the information in two pages.
    */
    Component {
        id: batteryPopup

        ToolIndicatorPage {
            showExpand:         expandedComponent ? true : false
            waitForParameters:  control.waitForParameters
            contentComponent:   batteryContentComponent
            expandedComponent:  batteryExpandedComponent
        }
    }

    // batteryVisual
    /* battery visual indicator
    *  called from: batteryIndicatorRow
    *  function   : show the battery icon and some important information
    */
    Component {
        id: batteryVisual

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
                if (fuelCell && fuelCell.voltage) {
                    // 显示 FactGroup 中的 voltage
                    return fuelCell.voltage.valueString + " " + fuelCell.voltage.units
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
                    font.pointSize:         _showBoth ? ScreenTools.defaultFontPointSize : ScreenTools.mediumFontPointSize
                    visible:                _showBoth || _showPercentage
                }

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

    /* batteryContentComponent
    *  called from: batteryPopup
    *  function   : show temperature current mah timeRemaining percentRemaining
    */
    Component {
        id: batteryContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            Component {
                id: batteryValuesAvailableComponent

                QtObject {
                    property bool voltageAvailable:          fuelCell && fuelCell.voltage
                    property bool currentAvailable:          fuelCell && fuelCell.current
                    property bool pressureAvailable:         fuelCell && fuelCell.pressure
                    property bool temperatureAvailable:      fuelCell && fuelCell.temperature
                    property bool powerAvailable:            fuelCell && fuelCell.power
                    property bool remainingEnergyAvailable:  fuelCell && fuelCell.remainingEnergy
                    property bool remainingTimeAvailable:    fuelCell && fuelCell.remainingTime
                }
            }

            Repeater {
                model: 1

                SettingsGroupLayout {
                    heading:        qsTr("Fuel Cell Status")
                    contentSpacing: 0
                    showDividers:   false

                    property var fuelCell: _activeVehicle ? _activeVehicle.fuelCellManager : null
                    property var batteryValuesAvailable: batteryValuesAvailableLoader.item

                    Loader {
                        id:                 batteryValuesAvailableLoader
                        sourceComponent:    batteryValuesAvailableComponent

                        property var fuelCell: parent.fuelCell
                    }

                    LabelledLabel {
                        label:      qsTr("Voltage")
                        labelText:  fuelCell.voltage.valueString + " " + fuelCell.voltage.units
                        visible:    batteryValuesAvailable.voltageAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Current")
                        labelText:  fuelCell.current.valueString + " " + fuelCell.current.units
                        visible:    batteryValuesAvailable.currentAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Pressure")
                        labelText:  fuelCell.pressure.valueString + " " + fuelCell.pressure.units
                        visible:    batteryValuesAvailable.pressureAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Temperature")
                        labelText:  fuelCell.temperature.valueString + " " + fuelCell.temperature.units
                        visible:    batteryValuesAvailable.temperatureAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Power")
                        labelText:  fuelCell.power.valueString + " " + fuelCell.power.units
                        visible:    batteryValuesAvailable.powerAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining Energy")
                        labelText:  fuelCell.remainingEnergy.valueString + " " + fuelCell.remainingEnergy.units
                        visible:    batteryValuesAvailable.remainingEnergyAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining Time")
                        labelText:  fuelCell.remainingTime.valueString + " " + fuelCell.remainingTime.units
                        visible:    batteryValuesAvailable.remainingTimeAvailable
                    }
                }
            }
        }
    }

    /* batteryExpandedComponent
    *  called from: batteryPopup
    *  function   :
    */
    Component {
        id: batteryExpandedComponent

        // The expanded view now directly shows specific fuel cell status details.
        // The complex settings UI has been removed as requested.
        SettingsGroupLayout {
            heading: qsTr("Details & Alerts")

            property var fuelCell: _activeVehicle ? _activeVehicle.fuelCellManager : null
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
                    property bool statusAvailable:           fuelCell && fuelCell.status
                    property bool bottleCapacityAvailable:   fuelCell && fuelCell.bottleCapacity
                }
            }

            // Display the current status
            LabelledLabel {
                label:      qsTr("Status")
                labelText:  fuelCell.status.valueString
                visible:    expandedValuesAvailable.statusAvailable
            }

            // Display alert information based on status
            LabelledLabel {
                label:      qsTr("Alerts")
                labelText:  fuelCell.status.valueString === "NORMAL" ? qsTr("No Alerts") : qsTr("Check Status!")
                //textColor:  fuelCell.status.valueString === "NORMAL" ? qgcPal.text : qgcPal.colorRed
                visible:    expandedValuesAvailable.statusAvailable
            }

            // Display the bottle capacity
            LabelledLabel {
                label:      qsTr("Bottle Capacity")
                labelText:  fuelCell.bottleCapacity.valueString + " " + fuelCell.bottleCapacity.units
                visible:    expandedValuesAvailable.bottleCapacityAvailable
            }
        }
    }
}
