import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

import Custom.Widgets

// Remote Control RSSI Indicator
Item {
    id: _root

    // Make this component visible as long as a vehicle is connected.
    visible: _activeVehicle

    // Set height to fill the parent toolbar row.
    // Set width to fit the content.
    height: parent.height
    width:  _rowLayout.width

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // The RC RSSI value from the vehicle. It's a percentage (0-100) or 255 for invalid.
    property int _rcRSSI: _activeVehicle ? _activeVehicle.rcRSSI : 0

    QGCPalette { id: qgcPal }

    RowLayout {
        id: _rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: ScreenTools.defaultFontPixelWidth / 2

        // The signal strength icon.
        CustomSignalStrength {
            size:       parent.height * 0.8
            percent:    _rcRSSI > 100 ? 0 : _rcRSSI // Treat invalid values as 0% for icon display
            //percent:    _rcRSSI / 255 * 100 // For test
        }

        // The text label for the signal strength value.
        QGCLabel {
            // Display the percentage value or "Invalid"
            text: _rcRSSI > 100 ? qsTr("Invalid") : `${_rcRSSI}%`
            color: qgcPal.text
            font.pointSize: ScreenTools.defaultFontPointSize
        }
    }
}