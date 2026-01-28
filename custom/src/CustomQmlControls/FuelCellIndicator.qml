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

    property var    _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var    _fuelCellSettings:   QGroundControl.settingsManager.fuelCellIndicatorSettings
    property Fact   _showPercentage:     _fuelCellSettings.PercentageDisplay
    property Fact   _showVoltage:        _fuelCellSettings.VoltageDisplay
    property Fact   _showRemainingTime:  _fuelCellSettings.RemainingTimeDisplay

    // fuelCell object
    property var fuelCell: _activeVehicle ? _activeVehicle.fuelCell : null

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
                    return fuelCell.percentRemaining.valueString + "%"
                }
                return qsTr("n/a")
            }

            function getBatteryVoltageText() {
                if (fuelCell && fuelCell.loadVoltage) {
                    return fuelCell.loadVoltage.valueString + " " + fuelCell.loadVoltage.units
                }
                return qsTr("n/a")
            }

            function getRemainingTimeText() {
                if (fuelCell && fuelCell.remainingTime) {
                    return fuelCell.remainingTime.valueString + " " + fuelCell.remainingTime.units
                }
                return qsTr("n/a")
            }

            function getVisibleCount(){
                var count = 0
                if(control._showPercentage && control._showPercentage.rawValue){
                    count += 1
                }
                if(control._showVoltage && control._showVoltage.rawValue){
                    count += 1
                }
                if(control._showRemainingTime && control._showRemainingTime.rawValue){
                    count += 1
                }
                if(count === 1){
                    return ScreenTools.defaultFontPointSize
                }else if(count === 2){
                    return ScreenTools.mediumFontPointSize
                }else{
                    return ScreenTools.smallFontPointSize
                }
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
                    font.pointSize:         getVisibleCount()
                    visible:                _showPercentage ? _showPercentage.rawValue : false
                }
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getBatteryVoltageText()
                    font.pointSize:         getVisibleCount()
                    visible:                _showVoltage ? _showVoltage.rawValue : false
                }
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   getRemainingTimeText()
                    font.pointSize:         getVisibleCount()
                    visible:                _showRemainingTime ? _showRemainingTime.rawValue : false
                }
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

            property var fuelCellDataList: [
                { label: qsTr("Voltage"),             fact: "loadVoltage" },
                { label: qsTr("Current"),             fact: "dcOutputCurrent" },
                { label: qsTr("Pressure"),            fact: "pressureLowest" },
                { label: qsTr("Highest temperature"), fact: "highestTemperature" },
                { label: qsTr("Instant power"),       fact: "instantPower" },
                { label: qsTr("Remaining Energy"),    fact: "remainingEnergy" },
                { label: qsTr("Remaining Time"),      fact: "remainingTime" }
            ]

            SettingsGroupLayout {
                heading:        qsTr("Fuel Cell Status")
                contentSpacing: 0
                showDividers:   false

                Repeater {
                    model: fuelCellDataList

                    LabelledLabel {
                        property var factObj: control.fuelCell ? control.fuelCell[modelData.fact] : null
                        label:      modelData.label
                        labelText:  factObj ? (factObj.valueString + " " + factObj.units) : "N/A"
                        visible:    factObj !== null
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

            SettingsGroupLayout {
                heading: qsTr("Display Options")

                FactCheckBoxSlider { // Use QGCSwitch if you only need a toggle
                    text:           qsTr("Show Percentage")
                    fact:           control._showPercentage
                    visible:        control._showPercentage ? control._showPercentage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("Show Voltage")
                    fact:           control._showVoltage
                    visible:        control._showVoltage ? control._showVoltage.visible : false
                }
                FactCheckBoxSlider {
                    text:           qsTr("Show Remaining Time")
                    fact:           control._showRemainingTime
                    visible:        control._showRemainingTime ? control._showRemainingTime.visible : false
                }
            }
        }
    }
}
