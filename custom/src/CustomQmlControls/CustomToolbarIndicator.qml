import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Vehicle
import Custom.QmlControls

import Custom.Widgets

// Custom Toolbar Indicator
Item {
    id: _root
    anchors.fill: parent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

    // interface exposed to parent FlyViewToolBar(custom)
    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    // color gradual change on background
    Rectangle {
        anchors.fill: viewButtonRow
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: qgcPal.toolbarBackground }
        }
    }

    // buttons on the left side: Logo, Status, Disconnect
    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull.svg"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            id: mainStatusIndicator
            Layout.preferredHeight: viewButtonRow.height
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost
        }
    }

    // middle/right: Indicator Area (including native indicators + our custom buttons)
    QGCFlickable {
        id:                     toolsFlickable
        // the Margin between components
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        // avoid overlap
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        // fill parent
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorRow.width
        flickableDirection:     Flickable.HorizontalFlick

        Row {
            id:                 indicatorRow
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            spacing:            ScreenTools.defaultFontPixelWidth

            // 1. original indicators (GPS, RC, Telemetry, Battery, etc.)
            // FlyViewToolBarIndicators will load corePlugin.toolBarIndicators (we will clear it to avoid duplicates)
            // and vehicle.toolIndicators

            // FlyViewToolBarIndicators {
            //     id: toolIndicators
            //     anchors.verticalCenter: parent.verticalCenter
            // }

            // 2. custom buttons
            Row {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                spacing:            ScreenTools.defaultFontPixelWidth

                // Flight Mode Indicator
                Loader {
                    anchors.top:            parent.top
                    anchors.bottom:         parent.bottom
                    function getFlightModeIndicatorSource() {
                        if (!_activeVehicle) return ""
                        // find the FlightModeIndicator for specific vehicle
                        var indicators = _activeVehicle.toolIndicators
                        for (var i = 0; i < indicators.length; i++) {
                            if (indicators[i].toString().indexOf("FlightModeIndicator.qml") >= 0) {
                                return indicators[i]
                            }
                        }
                        // if no indicator found, use default
                        return "qrc:/qml/QGroundControl/Controls/FlightModeIndicator.qml"
                    }
                    source:             getFlightModeIndicatorSource()
                    visible: item ? item.showIndicator : false
                }

                // Add the new RC RSSI Indicator here
                RCRSSIIndicator { }

                // Firmware Type Indicator
                Rectangle {
                    height:         parent.height
                    width:          firmwareLabel.width + (ScreenTools.defaultFontPixelWidth * 2)
                    color:          qgcPal.button
                    radius:         ScreenTools.defaultFontPixelHeight / 4
                    visible:        _activeVehicle

                    QGCLabel {
                        id:                 firmwareLabel
                        anchors.centerIn:   parent
                        text:               _activeVehicle ? _activeVehicle.firmwareTypeString : ""
                        color:              qgcPal.text
                    }
                }

                // GPS Indicator
                Rectangle {
                    height:         parent.height
                    width:          gpsRow.width + (ScreenTools.defaultFontPixelWidth * 2)
                    color:          qgcPal.button
                    radius:         ScreenTools.defaultFontPixelHeight / 4
                    visible:        _activeVehicle

                    Row {
                        id:                 gpsRow
                        anchors.centerIn:   parent
                        spacing:            ScreenTools.defaultFontPixelWidth / 2

                        QGCColoredImage {
                            height:             ScreenTools.defaultFontPixelHeight * 1.5
                            width:              height
                            sourceSize.height:  height
                            source:             "/qmlimages/Gps.svg"
                            fillMode:           Image.PreserveAspectFit
                            color:              qgcPal.text
                            opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            id:                       gpsVaule
                            anchors.verticalCenter:   parent.verticalCenter
                            spacing:                  0

                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:                     _activeVehicle ? _activeVehicle.gps.count.valueString : ""
                                color:                    qgcPal.buttonText
                            }

                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                // explicitly binding to lock to ensure update data.
                                property int lock:        _activeVehicle ? _activeVehicle.gps.lock.rawValue : 0
                                text: {
                                    if (!_activeVehicle) return qsTr("No Conn")
                                    if (lock >= 6) return qsTr("RTK-Fixed")
                                    if (lock === 5) return qsTr("RTK-Float")
                                    if (lock === 4) return qsTr("DGPS")
                                    if (lock === 3) return qsTr("GNSS")
                                    if (lock === 2) return qsTr("2D")
                                    return qsTr("No Fix")
                                }
                                color:                    qgcPal.buttonText
                                font.pointSize:           ScreenTools.smallFontPointSize
                            }

                        }

                    }
                }

            }
        }
    }

    //-- Time Display Indicator --//
    // Rectangle {
    //     id:                         timeIndicator
    //     anchors.top:                parent.top
    //     anchors.bottom:             parent.bottom
    //     anchors.horizontalCenter:   parent.horizontalCenter
    //     width:                      timeLabel.width + (ScreenTools.defaultFontPixelWidth * 4)
    //     color:                      timeMouseArea.pressed ? qgcPal.buttonHighlight : (timeMouseArea.containsMouse ? qgcPal.button : "transparent")
    //     radius:                     ScreenTools.defaultFontPixelHeight / 4
    //
    //     QGCLabel {
    //         id:                     timeLabel
    //         anchors.centerIn:       parent
    //         text:                   "00:00:00"
    //         color:                  qgcPal.text
    //         font.pointSize:         ScreenTools.defaultFontPointSize
    //     }
    //
    //     Timer {
    //         interval:       1000
    //         repeat:         true
    //         running:        true
    //         onTriggered: {
    //             var now = new Date()
    //             var h = ("0" + now.getHours()).slice(-2)
    //             var m = ("0" + now.getMinutes()).slice(-2)
    //             var s = ("0" + now.getSeconds()).slice(-2)
    //             timeLabel.text = h + ":" + m + ":" + s
    //         }
    //     }
    //
    //     MouseArea {
    //         id:                 timeMouseArea
    //         anchors.fill:       parent
    //         hoverEnabled:       true
    //     }
    // }

    // brandImageIndoor/outdoor on the right side
    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) return _userBrandImageIndoor
            if (_userBrandingOutdoor) return _userBrandImageOutdoor
            if (_corePluginBranding) return QGroundControl.corePlugin.brandImageIndoor
            return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) return _userBrandImageOutdoor
            if (_userBrandingIndoor) return _userBrandImageIndoor
            if (_corePluginBranding) return QGroundControl.corePlugin.brandImageOutdoor
            return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
        }
    }

    // progressBar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         parent.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")
            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}