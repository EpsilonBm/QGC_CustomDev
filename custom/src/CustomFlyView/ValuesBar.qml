import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap

import Custom.QmlControls // For FuelCellIndicator

Item {
    id: _root

    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    // Calculate the height
    property real defaultCompassRadius: (mainWindow.width * 0.15) / 2
    property real maxCompassRadius    : ScreenTools.defaultFontPixelHeight * 7 / 2
    property real compassRadius       : Math.min(defaultCompassRadius, maxCompassRadius)
    property real compassBorder       : ScreenTools.defaultFontPixelHeight / 2
    property real attitudeSize:         ScreenTools.defaultFontPixelHeight * 0.75
    property real attitudeSpacing:      ScreenTools.defaultFontPixelHeight / 4
    property real valuesBarHeight     : compassRadius * 1.5
    
    property var _telemetryData: [
        { label: qsTr("G_Speed"), unit: "m/s", fact: "groundSpeed" },
        { label: qsTr("A_Speed"), unit: "m/s", fact: "airSpeed" },
        { label: qsTr("climbRate"),  unit: "m/s",   fact: "climbRate" },
        { label: qsTr("alt_R"),  unit: "m",   fact: "altitudeRelative" }
    ]

    // The height is determined by the content (the left column) plus vertical margins.
    height: valuesBarHeight

    // The width is calculated to be symmetrical based on the content of both sides.
    width: Math.max((_leftDataColumn.implicitWidth + compassRadius + _leftMargin), (_fuelCellIndicator.implicitWidth + compassRadius + _rightMargin)) * 2

    // This property is passed down from FlyViewCustomLayer
    property var parentToolInsets

    QGCPalette { id: qgcPal }

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Background Rectangle
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: qgcPal.window
        opacity: 0.75
    }

    property real _leftMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeLeftInset : 0)
    property real _rightMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeRightInset : 0)

    // Left side: 4 data rectangles
    GridLayout {
        id:                     _leftDataColumn
        anchors.right:          parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:    compassRadius + compassBorder
        columnSpacing:          _toolsMargin / 2
        rowSpacing:             _toolsMargin / 4
        columns:                3
        rows:                   _telemetryData.length
        flow:                   GridLayout.TopToBottom

        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignRight
                text:               modelData.label
                color:              qgcPal.text
            }
        }

        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignRight
                property var factObj: _activeVehicle ? _activeVehicle[modelData.fact] : null
                text:               factObj ? factObj.valueString : "0.00"
                color:              qgcPal.text
            }
        }

        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignLeft
                text:               modelData.unit
                color:              qgcPal.text
            }
        }
    }

    // Right side: Battery Indicator
    // TODO: create a new type of the fuelcell indicator to change the mouse event
    // TODO: two cell statue in column
    FuelCellIndicator {
        id:                     _fuelCellIndicator
        anchors.left:           parent.horizontalCenter
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin:     compassRadius + compassBorder + attitudeSpacing + attitudeSize
        anchors.rightMargin:    _rightMargin
    }
}
