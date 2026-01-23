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
        compassWidth: compass.width
    }

    IntegratedCompassAttitude {
        id: compass
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeCenterInset : 0)

        property real size:     ScreenTools.defaultFontPixelHeight * 10
        property real attSize:  ScreenTools.defaultFontPixelHeight * 0.75

        compassRadius:          (size / 2) - attSize - (attSize / 2)
        attitudeSize:           attSize
        attitudeSpacing:        attSize / 2
        vehicle:                QGroundControl.multiVehicleManager.activeVehicle
    }
}