/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

//-------------------------------------------------------------------------
//-- Message Indicator
Item {
    id:             _root
    // Set height to fill the parent toolbar row.
    height: parent.height
    // Set width to fit the content.
    width:  height

    property bool showIndicator: true

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isMessageImportant:    _activeVehicle ? !_activeVehicle.messageTypeNormal && !_activeVehicle.messageTypeNone : false

    function dropMessageIndicator() {
        mainWindow.showIndicatorDrawer(vehicleMessagesPopup, _root);
    }

    function getMessageColor() {
        if (_activeVehicle) {
            if (_activeVehicle.messageTypeNone)
                return qgcPal.colorGrey
            if (_activeVehicle.messageTypeNormal)
                return qgcPal.colorBlue;
            if (_activeVehicle.messageTypeWarning)
                return qgcPal.colorOrange;
            if (_activeVehicle.messageTypeError)
                return qgcPal.colorRed;
            // Cannot be so make it obnoxious to show error
            console.warn("MessageIndicator.qml:getMessageColor Invalid vehicle message type", _activeVehicle.messageTypeNone)
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return qgcPal.colorGrey
    }

    Image {
        id:                 criticalMessageIcon
        anchors.centerIn:   parent
        height:             parent.height * 0.6
        width:              height
        source:             "qrc:/custom/img/Yield.svg"
        sourceSize.height:  height
        fillMode:           Image.PreserveAspectFit
        cache:              false
        visible:            _activeVehicle && _activeVehicle.messageCount > 0 && _isMessageImportant
    }

    QGCColoredImage {
        anchors.centerIn:   parent
        height:             parent.height * 0.6
        width:              height
        source:             "qrc:/custom/img/Megaphone.svg"
        sourceSize.height:  height
        fillMode:           Image.PreserveAspectFit
        color:              getMessageColor()
        visible:            !criticalMessageIcon.visible
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      dropMessageIndicator()
    }

    Component {
        id: vehicleMessagesPopup

        ToolIndicatorPage {
            showExpand: false

            contentComponent: Component {
                ColumnLayout {
                    spacing: ScreenTools.defaultFontPixelHeight / 2

                    SettingsGroupLayout {
                        heading:            qsTr("Vehicle Messages")
                        Layout.fillWidth:   true

                        // Use Loader to load VehicleMessageList to ensure we get the correct component
                        // from the standard QGC controls.
                        Loader {
                            Layout.fillWidth: true
                            source: "qrc:/qml/QGroundControl/Controls/VehicleMessageList.qml"
                        }
                    }

                    QGCButton {
                        text:               qsTr("Clear Messages")
                        Layout.alignment:   Qt.AlignRight
                        onClicked: {
                            if (_activeVehicle) {
                                _activeVehicle.clearMessages()
                                mainWindow.closeIndicatorDrawer()
                            }
                        }
                    }
                }
            }
        }
    }
}
