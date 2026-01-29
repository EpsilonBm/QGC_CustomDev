/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
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
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.FactSystem
import QGroundControl.FactControls

// This component encapsulates the Gimbal Control Page, extracted from GimbalIndicator
ToolIndicatorPage {
    id: root

    // Properties copied from GimbalIndicator to make this component self-contained
    property var    activeVehicle:              QGroundControl.multiVehicleManager.activeVehicle
    property var    gimbalController:           activeVehicle ? activeVehicle.gimbalController : null
    property var    activeGimbal:               gimbalController ? gimbalController.activeGimbal : null
    property var    multiGimbalSetup:           gimbalController ? gimbalController.gimbals.count > 1 : false
    property bool   joystickButtonsAvailable:   activeVehicle ? activeVehicle.joystickEnabled : false

    property var    margins:                    ScreenTools.defaultFontPixelWidth
    property var    panelRadius:                ScreenTools.defaultFontPixelWidth * 0.5
    property var    buttonHeight:               ScreenTools.defaultFontPixelHeight * 3.5 // Using a fixed height as it's no longer in the toolbar
    property var    squareButtonPadding:        ScreenTools.defaultFontPixelWidth
    property var    separatorHeight:            buttonHeight * 0.9
    property bool   settingsPanelVisible:       false

    QGCPalette { id: qgcPal }

    contentComponent: GridLayout {
        // Label indicating the purpose of the panel and active gimbal instance
        QGCLabel {
            text:                   qsTr("Gimbal ") +
                                        (root.multiGimbalSetup ? root.activeGimbal.deviceId.rawValue : "") +
                                            qsTr("<br> Controls")

            font.pointSize:         ScreenTools.smallFontPointSize
            Layout.preferredWidth:  root.buttonHeight * 1.1
            font.weight:            Font.DemiBold
        }

        // These are simple buttons that can be grouped on this Repeater
        Repeater {
            id: simpleGimbalButtonsRepeater
            property var hasControl:              root.gimbalController && root.gimbalController.activeGimbal && root.gimbalController.activeGimbal.gimbalHaveControl
            property var acqControlButtonEnabled: QGroundControl.settingsManager.gimbalControllerSettings.toolbarIndicatorShowAcquireReleaseControl.rawValue

            model: [
                {id: "yawLock",   text: root.activeGimbal.yawLock ? qsTr("Yaw <br> Follow") : qsTr("Yaw <br> Lock")  , visible: true                    },
                {id: "center",    text: qsTr("Center")                                                          , visible: true                    },
                {id: "tilt90",    text: qsTr("Tilt 90")                                                         , visible: true                    },
                {id: "pointHome", text: qsTr("Point <br> Home")                                                 , visible: true                    },
                {id: "retract",   text: qsTr("Retract")                                                         , visible: true                    },
                {id: "acqControl",text: hasControl ? qsTr("Release <br> Control") : qsTr("Acquire <br> Control"), visible: acqControlButtonEnabled }
            ]

            QGCButton {
                property var callbackList: [
                   {"yawLock":      function(){ root.gimbalController.toggleGimbalYawLock(!root.activeGimbal.yawLock) }   },
                   {"center":       function(){ root.gimbalController.centerGimbal() }                               },
                   {"tilt90":       function(){ root.gimbalController.sendPitchBodyYaw(-90, 0) }                     },
                   {"pointHome":    function(){ root.activeVehicle.guidedModeROI(root.activeVehicle.homePosition) }       },
                   {"retract":      function(){ root.gimbalController.toggleGimbalRetracted(true) }                  },
                   // This button changes its action depending on gimbal being under control or not
                   {"acqControl":   function(){ simpleGimbalButtonsRepeater.hasControl ?
                                                    root.gimbalController.releaseGimbalControl() :
                                                        root.gimbalController.acquireGimbalControl() }               }
                ]

                Layout.preferredWidth: Layout.preferredHeight
                Layout.preferredHeight: root.buttonHeight
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: modelData.text
                fontWeight: Font.DemiBold
                visible: modelData.visible
                pointSize: ScreenTools.smallFontPointSize
                backRadius: root.panelRadius * 0.5
                leftPadding: root.squareButtonPadding
                rightPadding: root.squareButtonPadding
                onClicked: {
                    var callback = callbackList.find(function(item) {
                        return item.hasOwnProperty(modelData.id);
                    });
                    if (callback !== undefined) {
                        callback[modelData.id]();
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.leftMargin:      root.margins
            Layout.preferredWidth:  2
            Layout.preferredHeight: root.separatorHeight
            color:                  qgcPal.windowShade
            visible:                root.multiGimbalSetup
        }

        // Active gimbal selector section
        QGCLabel {
            text:                   qsTr("Active <br> Gimbal: ") + (root.activeGimbal ? root.activeGimbal.deviceId.rawValue : "")
            font.pointSize:         ScreenTools.smallFontPointSize
            Layout.preferredWidth:  root.buttonHeight * 1.1
            Layout.leftMargin:      root.margins
            font.weight:            Font.DemiBold
            visible:                root.multiGimbalSetup
        }
        QGCButton {
            id:                     gimbalSelectorButton
            Layout.preferredWidth:  Layout.preferredHeight
            Layout.preferredHeight: root.buttonHeight
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignBottom
            text:                   qsTr("Select <br> Gimbal")
            fontWeight:             Font.DemiBold
            pointSize:              ScreenTools.smallFontPointSize
            backRadius:             root.panelRadius * 0.5
            visible:                root.multiGimbalSetup
            checkable:              true

            // This rectangle is to hide the "roundness" of panels when showing the dropdown, in the join between the 2 panels
            Rectangle {
                id:                         hideRoundCornersRectangle
                anchors.verticalCenter:     gimbalSelectorPanel.top
                anchors.horizontalCenter:   gimbalSelectorPanel.horizontalCenter
                width:                      gimbalSelectorPanel.width
                height:                     root.panelRadius * 2
                color:                      qgcPal.window
                visible:                    gimbalSelectorPanel.visible
            }

            Rectangle {
                id:                         gimbalSelectorPanel
                width:                      root.buttonHeight + root.margins * 2
                height:                     gimbalSelectorContentGrid.childrenRect.height + root.margins * 2
                visible:                    gimbalSelectorButton.checked
                color:                      qgcPal.window
                radius:                     root.panelRadius
                // We only show border if the extended settings panel is visible
                border.color:               root.settingsPanelVisible ? qgcPal.windowShade : qgcPal.window
                border.width:               5

                anchors.top:                parent.bottom
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.topMargin:          root.margins

                property var buttonWidth:    width - root.margins * 2
                property var panelHeight:    gimbalSelectorContentGrid.childrenRect.height + root.margins * 2
                property var gridRowSpacing: root.margins
                property var buttonFontSize: ScreenTools.smallFontPointSize * 0.9

                GridLayout {
                    id:               gimbalSelectorContentGrid
                    width:            parent.width
                    rowSpacing:       gimbalSelectorPanel.gridRowSpacing
                    columns:          1

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:              parent.top
                    anchors.topMargin:        root.margins

                    Repeater {
                        model: root.gimbalController && root.gimbalController.gimbals ? root.gimbalController.gimbals : undefined
                        delegate: QGCButton {
                            Layout.preferredWidth:  Layout.preferredHeight
                            Layout.preferredHeight: root.buttonHeight
                            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
                            fontWeight:             Font.DemiBold
                            pointSize:              ScreenTools.smallFontPointSize
                            backRadius:             root.panelRadius * 0.5
                            text:                   qsTr("Gimbal ") + object.deviceId.rawValue
                            checked:                root.activeGimbal === object
                            onClicked: {
                                root.gimbalController.activeGimbal = object
                                gimbalSelectorButton.checked = false
                            }
                        }
                    }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.leftMargin:      root.margins
            Layout.preferredWidth:  2
            Layout.preferredHeight: root.separatorHeight
            color:                  qgcPal.windowShade
        }

        // Show settings button.
        QGCButton {
            id:                     extendedOptionsButton
            Layout.leftMargin:      root.margins
            Layout.preferredWidth:  Layout.preferredHeight
            Layout.preferredHeight: root.buttonHeight
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignBottom
            text:                   qsTr("Settings")
            fontWeight:             Font.DemiBold
            pointSize:              ScreenTools.smallFontPointSize
            backRadius:             root.panelRadius * 0.5
            checkable:              true
            checked:                root.settingsPanelVisible
            leftPadding:            root.squareButtonPadding
            rightPadding:           root.squareButtonPadding
            onCheckedChanged: {
                if (checked !== root.settingsPanelVisible) {
                    root.settingsPanelVisible = checked
                }
            }
        }

        // Settings panel
        GridLayout {
            Layout.row:         2
            Layout.columnSpan:  8
            Layout.fillWidth:   true
            height:             root.buttonHeight * 1.5
            visible:            root.settingsPanelVisible
            columns:            2
            rowSpacing:         root.margins

            // Click on screen settings
            FactCheckBox {
                id:                 enableOnScreenControlCheckbox
                text:               "  " + QGroundControl.settingsManager.gimbalControllerSettings.EnableOnScreenControl.shortDescription
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.EnableOnScreenControl
                checkedValue:       1
                uncheckedValue:     0
                Layout.columnSpan:  2
            }

            QGCLabel {
                id:                 controlTypeLabel
                text:               qsTr("Control type: ")
                visible:            enableOnScreenControlCheckbox.checked
            }
            FactComboBox {
                id:                 controlTypeCombo
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.ControlType
                visible:            enableOnScreenControlCheckbox.checked
            }

            QGCLabel {
                text:               qsTr("Horizontal FOV")
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 0
            }
            FactTextField {
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.CameraHFov
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 0
            }

            QGCLabel {
                text:               qsTr("Vertical FOV")
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 0
            }
            FactTextField {
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.CameraVFov
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 0
            }

            QGCLabel {
                text:               qsTr("Max speed:")
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 1
            }
            FactTextField {
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.CameraSlideSpeed
                visible:            enableOnScreenControlCheckbox.checked && QGroundControl.settingsManager.gimbalControllerSettings.ControlType.rawValue === 1
            }

            // Separator
            Rectangle {
                Layout.columnSpan:       2
                Layout.preferredHeight:  2
                Layout.preferredWidth:   gimbalAzimuthMapCheckbox.width
                Layout.margins:          root.margins
                color:                   qgcPal.windowShade
            }

            QGCLabel {
                text:               qsTr("Joystick buttons speed:")
                visible:            root.joystickButtonsAvailable && QGroundControl.settingsManager.gimbalControllerSettings.visible
            }
            FactTextField {
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.joystickButtonsSpeed
                visible:            root.joystickButtonsAvailable && QGroundControl.settingsManager.gimbalControllerSettings.visible
                showHelp:           true
            }

            // Separator
            Rectangle {
                Layout.columnSpan:       2
                Layout.preferredHeight:  2
                Layout.preferredWidth:   gimbalAzimuthMapCheckbox.width
                Layout.margins:          root.margins
                color:                   qgcPal.windowShade
                visible:                 root.joystickButtonsAvailable && QGroundControl.settingsManager.gimbalControllerSettings.visible
            }

            FactCheckBox {
                id:                 gimbalAzimuthMapCheckbox
                text:               "  " + qsTr("Show gimbal Azimuth indicator in map")
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.showAzimuthIndicatorOnMap
                Layout.columnSpan:  2
                checkedValue:       1
                uncheckedValue:     0
            }

            FactCheckBox {
                id:                 gimbalAzimutIndicatorCheckbox
                text:               "  " + qsTr("Use Azimuth instead of local yaw on top toolbar indicator")
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.toolbarIndicatorShowAzimuth
                Layout.columnSpan:  2
                checkedValue:       1
                uncheckedValue:     0
            }

            FactCheckBox {
                id:                 showAcquireControlCheckbox
                text:               "  " + qsTr("Show Acquire/Release control button")
                fact:               QGroundControl.settingsManager.gimbalControllerSettings.toolbarIndicatorShowAcquireReleaseControl
                Layout.columnSpan:  2
                checkedValue:       1
                uncheckedValue:     0
            }
        }
    }
}