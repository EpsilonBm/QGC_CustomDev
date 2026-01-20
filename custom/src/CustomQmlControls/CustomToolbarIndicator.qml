import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

import Custom.Widgets

Row {
    spacing: ScreenTools.defaultFontPixelWidth

    CustomToolBarButton2 {
        text :         "1"
        iconSource:    "/custom/img/odometer.svg"
        onClicked:{
            console.log("1 Toolbar Button2 Clicked!")
        }
    }

    CustomToolBarButton2 {
        text :         "2"
        iconSource:    "/custom/img/microSD.svg"
        onClicked:{
            console.log("2 Toolbar Button2 Clicked!")
        }
    }
}