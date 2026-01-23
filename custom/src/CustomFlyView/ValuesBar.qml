import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

import Custom.QmlControls // For FuelCellIndicator

Item {
    id: _root

    // The height is determined by the content (the left column) plus vertical margins.
    height: _leftDataColumn.implicitHeight + (_toolsMargin * 2)
    // The width is calculated to be symmetrical based on the left column and the compass width.
    // Width = 2 * (LeftMargin + ColumnWidth + CompassHalfWidth)
    width: (_leftMargin + _leftDataColumn.implicitWidth + (compassWidth / 2)) * 2

    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    property real compassWidth: 0

    // This property is passed down from FlyViewCustomLayer
    property var parentToolInsets

    QGCPalette { id: qgcPal }

    // Background Rectangle
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: qgcPal.window
        opacity: 0.75
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
            model: 4
            delegate: Rectangle {
                implicitWidth: ScreenTools.defaultFontPixelWidth * 15
                implicitHeight: ScreenTools.defaultFontPixelHeight * 1.5
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: _toolsMargin / 2

                    QGCColoredImage {
                        Layout.preferredWidth: height
                        Layout.preferredHeight: parent.height
                        Layout.alignment: Qt.AlignVCenter
                        source: "qrc:/custom/img/chronometer.svg"
                        color: qgcPal.text
                        fillMode: Image.PreserveAspectFit
                    }

                    QGCLabel {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr("Speed: 00.00m/s")
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