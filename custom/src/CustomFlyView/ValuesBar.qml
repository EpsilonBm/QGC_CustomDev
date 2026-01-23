import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

import Custom.QmlControls // For FuelCellIndicator

Item {
    id: _root

    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    // Last method: just define it without relationship
    property real ca_Width: 0
    property real c_R: 0
    property real columnDataNum: 4

    // The height is determined by the content (the left column) plus vertical margins.
    //height: _leftDataColumn.implicitHeight + (_toolsMargin * 2)
    height: c_R * 2

    // The width is calculated to be symmetrical based on the left column and the compass width.
    // Width = 2 * (LeftMargin + ColumnWidth + CompassHalfWidth)
    //width: (_leftMargin + _leftDataColumn.implicitWidth + (compassWidth / 2)) * 2
    width: (_leftMargin + _leftDataColumn.implicitWidth + (ca_Width / 2)) * 2

    // This property is passed down from FlyViewCustomLayer
    property var parentToolInsets

    QGCPalette { id: qgcPal }

    // Background Rectangle
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: qgcPal.window
        opacity: 1
    }

    property real _leftMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeLeftInset : 0)

    // Left side: 4 data rectangles
    ColumnLayout {
        id: _leftDataColumn
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: _leftMargin
        spacing: _toolsMargin / 4

        Repeater {
            model: columnDataNum
            delegate: Rectangle {
                id:            dataRec
                implicitWidth: ScreenTools.defaultFontPixelWidth * 25
                //implicitHeight: ScreenTools.defaultFontPixelHeight * 1.5
                implicitHeight: _root.height / 4
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: _toolsMargin / 2

                    QGCLabel {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr("Speed: ")
                        color: qgcPal.text
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        // TODO: get the data
                        text: qsTr("00.00")
                        color: qgcPal.text
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr(" m/s")
                        color: qgcPal.text
                    }
                }
            }
        }
    }

    // Right side: Battery Indicator
    FuelCellIndicator {
        id: _fuelCellIndicator
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeRightInset : 0)
    }
}