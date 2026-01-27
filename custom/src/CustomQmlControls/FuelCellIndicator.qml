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

    // fuelCellIndicatorRow
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
    MouseArea {
        anchors.fill:   parent
        onClicked: {
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

            Repeater {
                model: 1

                SettingsGroupLayout {
                    heading:        qsTr("Fuel Cell Status")
                    contentSpacing: 0
                    showDividers:   false

                    property var fuelCellValuesAvailable: fuelCellValuesAvailableLoader.item

                    Loader {
                        id:                 fuelCellValuesAvailableLoader
                        sourceComponent:    fuelCellValuesAvailableComponent

                        property var fuelCell: parent.fuelCell
                    }

                    LabelledLabel {
                        label:      qsTr("Voltage")
                        labelText:  fuelCell.loadVoltage.valueString + " " + fuelCell.loadVoltage.units
                        visible:    fuelCellValuesAvailable.voltageAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Current")
                        labelText:  fuelCell.dcOutputCurrent.valueString + " " + fuelCell.dcOutputCurrent.units
                        visible:    fuelCellValuesAvailable.currentAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Pressure")
                        labelText:  fuelCell.pressureLowest.valueString + " " + fuelCell.pressureLowest.units
                        visible:    fuelCellValuesAvailable.pressureAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Highest temperature")
                        labelText:  fuelCell.highestTemperature.valueString + " " + fuelCell.highestTemperature.units
                        visible:    fuelCellValuesAvailable.temperatureAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Instant power")
                        labelText:  fuelCell.instantPower.valueString + " " + fuelCell.instantPower.units
                        visible:    fuelCellValuesAvailable.powerAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining Energy")
                        labelText:  fuelCell.remainingEnergy.valueString + " " + fuelCell.remainingEnergy.units
                        visible:    fuelCellValuesAvailable.remainingEnergyAvailable
                    }

                    LabelledLabel {
                        label:      qsTr("Remaining Time")
                        labelText:  fuelCell.remainingTime.valueString + " " + fuelCell.remainingTime.units
                        visible:    fuelCellValuesAvailable.remainingTimeAvailable
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
            heading: qsTr("Details & Alerts")

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
                label:      qsTr("Bottle Capacity")
                labelText:  control.fuelCell.bottleCapacity.valueString + " " + control.fuelCell.bottleCapacity.units
                visible:    expandedValuesAvailable.bottleCapacityAvailable
            }
        }
    }
}
