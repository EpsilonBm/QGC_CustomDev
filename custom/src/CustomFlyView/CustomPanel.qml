import QtQuick
import QtQuick.Layouts
import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.FlightMap
import QGroundControl.Controls
import QGroundControl.FlightDisplay
import QGroundControl.Palette

import Custom.QmlControls
import Custom.Widgets

Item {
    id: _root
    
    QGCPalette { id: qgcPal }

    property var parentToolInsets
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    property real defaultCompassRadius: (mainWindow.width * 0.15) / 2
    property real maxCompassRadius    : ScreenTools.defaultFontPixelHeight * 11 / 2
    property real compassRadius       : Math.min(defaultCompassRadius, maxCompassRadius)
    property real compassBorder       : ScreenTools.defaultFontPixelHeight / 2

    // ValuesBar {
    //     id: valuesBar
    //     anchors.bottom: parent.bottom
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     parentToolInsets: _root.parentToolInsets
    // }
    TelemetryValuesBar {
        id:                     valuesBar
        Layout.alignment:       Qt.AlignBottom

        // extraWidth:             compassRadius
        anchors.bottom:         parent.bottom
        // anchors.right:          parent.horizontalCenter
        // anchors.rightMargin:    compassRadius + compassBorder
        anchors.right:          parent.horizontalCenter
        anchors.rightMargin:    0

        settingsGroup:          factValueGrid.telemetryBarSettingsGroup
        specificVehicleForCard: null // Tracks active vehicle
    }

    Rectangle {
        id:                 fuelCellBackRect
        // 我真草了，极致的面多加水水多加面，兼容性是什么？我不到啊，反正不是这个距离就是那个距离，一个一个试总能试出来的
        // anchors.left:           valuesBar.right
        // anchors.leftMargin:     compassRadius
        anchors.bottom:         parent.bottom
        anchors.left:           parent.horizontalCenter
        anchors.leftMargin:     0

        width:              _fuelCellIndicator.width + compassRadius + compassBorder
        height:             valuesBar.height > 0 ? valuesBar.height : ScreenTools.defaultFontPixelHeight * 3

        color:              qgcPal.window
        opacity:            0.75
        radius:             ScreenTools.defaultFontPixelWidth / 2

        FuelCellIndicator {
            id:                 _fuelCellIndicator
            anchors.right:      parent.right
        }
    }

    // IntegratedCompassAttitude {
    //     id: compass
    //     anchors.bottom: parent.bottom
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottomMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeCenterInset : 0)
    //     vehicle:                QGroundControl.multiVehicleManager.activeVehicle
    // }
    CustomCompassAttitude {
        id : compass
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeCenterInset : 0)
        _compassRadius : compassRadius
    }
}