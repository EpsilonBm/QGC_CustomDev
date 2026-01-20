import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

import Custom.Widgets

CustomToolBarButton {
    icon.source:    "/custom/img/dronecode-white.svg"
    text:           "Custom"

    onClicked:      console.log("Custom Toolbar Button Clicked!")
}