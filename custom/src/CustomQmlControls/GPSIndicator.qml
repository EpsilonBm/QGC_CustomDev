import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

Item {
    id: _root
    height:         parent.height
    width:          gpsRow.width + (ScreenTools.defaultFontPixelWidth * 2)
    visible:        _activeVehicle

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    Row {
        id:                 gpsRow
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelWidth / 2

        QGCColoredImage {
            height:             ScreenTools.defaultFontPixelHeight * 1.5
            width:              height
            sourceSize.height:  height
            source:             "/qmlimages/Gps.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
            opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            id:                       gpsVaule
            anchors.verticalCenter:   parent.verticalCenter
            spacing:                  0

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text:                     _activeVehicle ? _activeVehicle.gps.count.valueString : ""
                color:                    qgcPal.buttonText
            }

            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                // explicitly binding to lock to ensure update data.
                property int lock:        _activeVehicle ? _activeVehicle.gps.lock.rawValue : 0
                text: {
                    if (!_activeVehicle) return qsTr("No Conn")
                    if (lock >= 6) return qsTr("RTK-Fixed")
                    if (lock === 5) return qsTr("RTK-Float")
                    if (lock === 4) return qsTr("DGPS")
                    if (lock === 3) return qsTr("GNSS")
                    if (lock === 2) return qsTr("2D")
                    return qsTr("No Fix")
                }
                color:                    qgcPal.buttonText
                font.pointSize:           ScreenTools.smallFontPointSize
            }
        }
    }
}