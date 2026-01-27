import QtQuick
import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.FlightMap

Item {
    id: _root
    
    property var parentToolInsets
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75

    ValuesBar {
        id: valuesBar
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        parentToolInsets: _root.parentToolInsets
    }

    // TODO: Change the color to match the theme
    IntegratedCompassAttitude {
        id: compass
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeCenterInset : 0)

        vehicle:                QGroundControl.multiVehicleManager.activeVehicle
    }
}