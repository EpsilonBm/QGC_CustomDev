import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

// Created by Gemini 3, better that default component provided by QGC so saved.

Item {
    id: control

    // define properties
    property alias iconSource:  iconImage.source
    property alias text:        label.text

    // define signals
    signal clicked()

    // define outlook
    width:  rowLayout.width
    height: parent.height
    visible: _activeVehicle

    RowLayout {
        id:                     rowLayout
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth

        Rectangle {
            Layout.fillHeight:      true
            Layout.preferredWidth:  contentRow.width + (ScreenTools.defaultFontPixelWidth * 2)
            color:                  mouseArea.pressed ? qgcPal.buttonHighlight : (mouseArea.containsMouse ? qgcPal.button : "transparent")
            radius:                 ScreenTools.defaultFontPixelHeight / 4

            Row {
                id:                 contentRow
                anchors.centerIn:   parent
                spacing:            ScreenTools.defaultFontPixelWidth

                QGCColoredImage {
                    id:                 iconImage
                    height:             ScreenTools.defaultFontPixelHeight
                    width:              height
                    sourceSize.height:  height
                    fillMode:           Image.PreserveAspectFit
                    color:              qgcPal.text
                }

                QGCLabel {
                    id:                 label
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id:                 mouseArea
                anchors.fill:       parent
                hoverEnabled:       true
                onClicked:          control.clicked()
            }
        }
    }
}