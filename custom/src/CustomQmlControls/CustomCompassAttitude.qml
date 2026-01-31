import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

import Custom.Widgets

Item {
    id : _root
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle

    // Heading Fact and distance Fact
    property string _distanceStr:           isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property real   _distance:              _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0

    // Compass Fact
    property real   _compassRadius:         0
    property real   _backgroundHeight:      0

    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75

    //-------------------------------------------------------------------------
    Rectangle {
        id:                     attitudeIndicator
        anchors.bottomMargin:   _toolsMargin
        anchors.bottom:         parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height:                 _compassRadius * 2
        width:                  height
        radius:                 height * 0.5
        color:                  qgcPal.windowShade

        CustomAttitudeWidget {
            size:               parent.height * 0.95
            vehicle:            _activeVehicle
            showHeading:        false
            anchors.centerIn:   parent
        }
    }

    Image {
        id:                 headingNeedle
        anchors.centerIn:   attitudeIndicator
        height:             attitudeIndicator.height * 0.75
        width:              height
        source:             "/custom/img/compass_needle.svg"
        fillMode:           Image.PreserveAspectFit
        sourceSize.height:  height
        transform: [
            Rotation {
                origin.x:   headingNeedle.width  / 2
                origin.y:   headingNeedle.height / 2
                angle:      _heading
            }]
    }
}