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
import Custom.FlyView

Item {
    id: _root
    
    QGCPalette { id: qgcPal }

    property var parentToolInsets
    property real _toolsMargin:         ScreenTools.defaultFontPixelWidth * 0.75
    property real defaultCompassRadius: (mainWindow.width * 0.15) / 2
    property real maxCompassRadius:     ScreenTools.defaultFontPixelHeight * 11 / 2
    property real compassRadius:        Math.min(defaultCompassRadius, maxCompassRadius)

    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property real _heading:             _activeVehicle ? _activeVehicle.heading.rawValue : 0
    property real _rollAngle:           _activeVehicle ? _activeVehicle.roll.rawValue  : 0
    property real _pitchAngle:          _activeVehicle ? _activeVehicle.pitch.rawValue : 0

    height:                             valuesBar.height > 0 ? valuesBar.height : ScreenTools.defaultFontPixelHeight * 3

    // ValuesBar {
    //     id: valuesBar
    //     anchors.bottom: parent.bottom
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     parentToolInsets: _root.parentToolInsets
    // }
    TelemetryValuesBar {
        id:                     valuesBar
        Layout.alignment:       Qt.AlignBottom

        extraWidth:             compassRadius
        anchors.bottom:         parent.bottom
        anchors.right:          parent.horizontalCenter
        anchors.rightMargin:    compassRadius
        settingsGroup:          factValueGrid.telemetryBarSettingsGroup
        specificVehicleForCard: null // Tracks active vehicle
    }

    Rectangle {
        id:                 fuelCellBackRect
        anchors.bottom:     parent.bottom
        anchors.left:       parent.horizontalCenter
        anchors.leftMargin: 0

        width:              _fuelCellIndicator.width + compassRadius + headingAttitudeValues.width
        height:             valuesBar.height > 0 ? valuesBar.height : ScreenTools.defaultFontPixelHeight * 3

        color:              qgcPal.window
        opacity:            0.75
        radius:             ScreenTools.defaultFontPixelWidth / 2

        ColumnLayout {
            id:                     headingAttitudeValues
            anchors.top:            parent.top
            anchors.bottom:         parent.bottom
            anchors.left:           parent.left
            anchors.leftMargin:     compassRadius
            spacing:                0

            QGCLabel {
                Layout.alignment:       Qt.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  qgcPal.text
                text:                   "航向角:" + (_activeVehicle ? _heading.toFixed(0) : "-.-") + "°"
                font.pointSize:         ScreenTools.smallFontPointSize
                visible:                true
            }
            QGCLabel {
                Layout.alignment:       Qt.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  qgcPal.text
                text:                   "俯仰角:" + (_activeVehicle ? _pitchAngle.toFixed(0) : "-.-") + "°"
                font.pointSize:         ScreenTools.smallFontPointSize
                visible:                true
            }
            QGCLabel {
                Layout.alignment:       Qt.AlignHCenter
                verticalAlignment:      Text.AlignVCenter
                color:                  qgcPal.text
                text:                   "滚转角:" + (_activeVehicle ? _rollAngle.toFixed(0) : "-.-") + "°"
                font.pointSize:         ScreenTools.smallFontPointSize
                visible:                true
            }
        }

        FuelCellValueIndicator {
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
        id:                          compass
        anchors.bottom:              parent.bottom
        anchors.horizontalCenter:    parent.horizontalCenter
        anchors.bottomMargin:        0
        _compassRadius:              compassRadius
        _backgroundHeight:           valuesBar.height > 0 ? valuesBar.height : ScreenTools.defaultFontPixelHeight * 3
    }
}