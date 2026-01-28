import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

/* Note:
*  When using the value that would update with times or event, must define a
*  property to hold the value. This explicitly bind ensure the value would
*  update when the up-flow value change.
*/


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

        // Explicitly bind to lock to ensure update data for both Image and Label
        property int gpsLock: _activeVehicle ? _activeVehicle.gps.lock.rawValue : 0

        QGCColoredImage {
            height:             ScreenTools.defaultFontPixelHeight * 1.5
            width:              height
            sourceSize.height:  height
            source:             "qrc:/custom/img/Gps.svg"
            fillMode:           Image.PreserveAspectFit
            //color:              qgcPal.text
            color: {
                if (gpsRow.gpsLock >= 6) return qgcPal.colorGreen     // RTK-Fixed
                if (gpsRow.gpsLock === 5) return qgcPal.colorYellow   // RTK-Float
                if (gpsRow.gpsLock === 4 || gpsRow.gpsLock === 3) return qgcPal.colorOrange   // DGPS and GNSS
                return qgcPal.colorRed
            }
            //color:              qgcPal.colorRed
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
                text: {
                    if (!_activeVehicle) return qsTr("No Conn")
                    if (gpsRow.gpsLock >= 6) return qsTr("RTK-Fixed")
                    if (gpsRow.gpsLock === 5) return qsTr("RTK-Float")
                    if (gpsRow.gpsLock === 4) return qsTr("DGPS")
                    if (gpsRow.gpsLock === 3) return qsTr("GNSS")
                    if (gpsRow.gpsLock === 2) return qsTr("2D")
                    return qsTr("No Fix")
                }
                color:                    qgcPal.buttonText
                font.pointSize:           ScreenTools.smallFontPointSize
            }
        }
    }
}