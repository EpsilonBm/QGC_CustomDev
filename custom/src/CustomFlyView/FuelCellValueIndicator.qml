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

    function getSystemStatue(){
        if (fuelCell && fuelCell.systemStatus) {
            switch (fuelCell.systemStatus.value) {
                case 0:
                    return qsTr("初始化")
                case 1:
                    return qsTr("自检")
                case 2:
                    return qsTr("待命")
                case 3:
                    return qsTr("启动")
                case 4:
                    return qsTr("运行")
                case 5:
                    return qsTr("关机")
                case 6:
                    return qsTr("异常")
                case 7:
                    return qsTr("急停")
                case 8:
                    return qsTr("复位")
                case 9:
                    return qsTr("调试")
            }
        }
    }

    function getSystemStatueColor(){
        if (fuelCell && fuelCell.systemStatus) {
            switch (fuelCell.systemStatus.value) {
                case 6:
                case 7:
                    return qgcPal.colorRed
                default:
                    return qgcPal.text
            }
        }
    }

    // fuelCellIndicatorRow
    Row {
        id:             fuelCellIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        FuelCellImage{
            id:                     fuelCellImage
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
                text:                   fuelCell.highestTemperature ? (fuelCell.highestTemperature.valueString + " " + fuelCell.highestTemperature.units) : "N/A"
                font.pointSize:         ScreenTools.mediumFontPointSize
                visible:                true
            }
            // SystemStatus
            QGCLabel {
                Layout.alignment:       Qt.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  getSystemStatueColor()
                text:                   fuelCell ? getSystemStatue() : "无效"
                font.pointSize:         ScreenTools.mediumFontPointSize
                visible:                true
            }
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
}
