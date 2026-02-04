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
Item {
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          height * 0.7

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

    QGCColoredImage {
        id:                 fuelCellImage
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height * 0.7
        sourceSize.width:   width
        source:             getBatterySvgSource()
        fillMode:           Image.PreserveAspectFit
        color:              getBatteryColor()
    }

    function getBatteryPercentageText() {
        if (fuelCell && fuelCell.percentRemaining) {
            // 直接显示百分比数值
            return fuelCell.percentRemaining.valueString + "%"
        }
        return qsTr("n/a")
    }

    ColumnLayout{
        id:                     valuesInImage
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           fuelCellImage.left
        anchors.right:          fuelCellImage.right
        spacing:                0

        QGCLabel {
            Layout.alignment:       Qt.AlignHCenter
            verticalAlignment:      Text.AlignVCenter
            color:                  qgcPal.text
            text:                   getBatteryPercentageText()
            font.pointSize:         ScreenTools.defaultFontPointSize
            visible:                true
        }
    }
}