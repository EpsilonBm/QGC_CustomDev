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

    // function getVisibleCount(){
    //     let count = 0
    //     if(control._showPercentage && control._showPercentage.rawValue){
    //         count += 1
    //     }
    //     if(control._showVoltage && control._showVoltage.rawValue){
    //         count += 1
    //     }
    //     if(control._showRemainingTime && control._showRemainingTime.rawValue){
    //         count += 1
    //     }
    //     if(count === 1){
    //         return ScreenTools.mediumFontPointSize
    //     }else if(count === 2){
    //         return ScreenTools.defaultFontPointSize
    //     }else{
    //         return ScreenTools.smallFontPointSize
    //     }
    // }

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

            // QGCLabel {
            //     Layout.alignment:       Qt.AlignHCenter
            //     verticalAlignment:      Text.AlignVCenter
            //     color:                  qgcPal.text
            //     text:                   getRemainingTimeText()
            //     font.pointSize:         getVisibleCount()
            //     visible:                _showRemainingTime ? _showRemainingTime.rawValue : false
            // }
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
