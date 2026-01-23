import QtQuick
import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.FlightMap

Item {
    id: _root
    
    property var parentToolInsets
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75

    property real size:     ScreenTools.defaultFontPixelHeight * 10
    property real attSize:  ScreenTools.defaultFontPixelHeight * 0.75
    property real c_Radius:  (size / 2) - attSize - (attSize / 2)

    ValuesBar {
        id: valuesBar
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        parentToolInsets: _root.parentToolInsets
        ca_Width: _root.size
        c_R:      _root.c_Radius
    }

    // TODO: Change the color to match the theme
    IntegratedCompassAttitude {
        id: compass
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeCenterInset : 0)

        //compassRadius:          (size / 2) - attSize - (attSize / 2)
        compassRadius:          _root.c_Radius
        attitudeSize:           _root.attSize
        attitudeSpacing:        _root.attSize / 2
        vehicle:                QGroundControl.multiVehicleManager.activeVehicle
    }
}