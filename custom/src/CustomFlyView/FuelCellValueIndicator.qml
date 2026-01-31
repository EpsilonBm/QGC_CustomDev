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

import Custom.FuelCell

//-------------------------------------------------------------------------
//-- FuelCell Indicator from Battery Indicator
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          fuelCellIndicatorRow.width

    QGCPalette { id: qgcPal }

    property bool       showIndicator:      true
    property bool       waitForParameters:  false   // UI won't show until parameters are ready
    property Component  expandedPageComponent

    property var    _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var    _fuelCellSettings:   QGroundControl.settingsManager.fuelCellIndicatorSettings
    property var    _showPercentage:     _fuelCellSettings ? _fuelCellSettings.PercentageDisplay : null
    property var    _showVoltage:        _fuelCellSettings ? _fuelCellSettings.VoltageDisplay : null
    property var    _showRemainingTime:  _fuelCellSettings ? _fuelCellSettings.RemainingTimeDisplay : null

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

    Component{
        id: fuelCellPopup

        FuelCellPage{
            _fuelCell: fuelCell
            showPercentage: _showPercentage
            showVoltage: _showVoltage
            showRemainingTime: _showRemainingTime
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

            function getRemainingTimeText() {
                if (fuelCell && fuelCell.remainingTime) {
                    return fuelCell.remainingTime.valueString + " " + fuelCell.remainingTime.units
                }
                return qsTr("n/a")
            }

            function getVisibleCount(){
                let count = 0
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
                    return ScreenTools.mediumFontPointSize
                }else if(count === 2){
                    return ScreenTools.defaultFontPointSize
                }else{
                    return ScreenTools.smallFontPointSize
                }
            }

            function getSystemStatue(){
                if (fuelCell && fuelCell.systemStatus) {
                    switch (fuelCell.systemStatus.value) {
                        case 0:
                            return qsTr("停机")
                        case 1:
                            return qsTr("热机")
                        case 2:
                            return qsTr("运行")
                        case 3:
                            return qsTr("故障")
                    }
                }
            }

            function getSystemStatueColor(){
                if (fuelCell && fuelCell.systemStatus) {
                    switch (fuelCell.systemStatus.value) {
                        case 0:
                        case 1:
                        case 2:
                            return qgcPal.text
                        case 3:
                            return qgcPal.colorRed
                    }
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
            ColumnLayout {
                id:                     batteryInfoColumn2
                anchors.top:            parent.top
                anchors.bottom:         parent.bottom
                spacing:                0
                // TODO: Add Temperature showing, Statues and warning
                // Temperature
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  qgcPal.text
                    text:                   fuelCell.highestTemperature ? (fuelCell.highestTemperature.valueString + " " + fuelCell.highestTemperature.units) : "N/A"
                    font.pointSize:         ScreenTools.defaultFontPointSize
                    visible:                true
                }
                // SystemStatues
                QGCLabel {
                    Layout.alignment:       Qt.AlignHCenter
                    verticalAlignment:      Text.AlignVCenter
                    color:                  getSystemStatueColor()
                    text:                   fuelCell ? getSystemStatue() : "无效"
                    font.pointSize:         ScreenTools.defaultFontPointSize
                    visible:                true
                }
            }
        }
    }

}
