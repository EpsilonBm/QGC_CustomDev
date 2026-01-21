import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

Item {
    id: _root

    // Make this component visible as long as a vehicle is connected.
    visible: _activeVehicle

    // Set height to fill the parent toolbar row.
    height: parent.height
    // Set width to fit the content.
    width:  _rowLayout.width

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    // The RC RSSI value from the vehicle. It's a percentage (0-100) or 255 for invalid.
    property int _rcRSSI: _activeVehicle ? _activeVehicle.rcRSSI : 0

    QGCPalette { id: qgcPal }

    RowLayout {
        id:                     _rowLayout
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        // TODO: Change to other kind of component that can show different color
        QGCColoredImage {
            Layout.alignment:       Qt.AlignVCenter
            Layout.preferredHeight: _root.height * 0.6
            Layout.preferredWidth:  Layout.preferredHeight

            sourceSize.height:      height
            fillMode:               Image.PreserveAspectFit
            color:                  qgcPal.text

            function getIconSource() {
                var val = _rcRSSI > 100 ? 0 : _rcRSSI
                if (val < 20) return "qrc:/custom/img/RC_signal_0.svg"
                if (val < 40) return "qrc:/custom/img/RC_signal_25.svg"
                if (val < 60) return "qrc:/custom/img/RC_signal_50.svg"
                if (val < 90) return "qrc:/custom/img/RC_signal_75.svg"
                return "qrc:/custom/img/RC_signal_100.svg"
            }

            source: getIconSource()
        }

        QGCLabel {
            Layout.alignment:   Qt.AlignVCenter
            text:               _rcRSSI > 100 ? qsTr("Invalid") : (_rcRSSI + "%")
            color:              qgcPal.text
            font.pointSize:     ScreenTools.defaultFontPointSize
        }
    }
}
