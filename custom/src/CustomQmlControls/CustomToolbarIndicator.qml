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

    //-- Time Display Indicator --//
    Column {
        id:                         timeIndicator
        anchors.top:                parent.top
        anchors.bottom:             parent.bottom
        anchors.left:               viewButtonRow.right
        width:                      Math.max(systemTimeLabel.width, flightTimeLabel.width) + (ScreenTools.defaultFontPixelWidth * 4)
        spacing:                    2

        Rectangle {
            width:                  systemTimeLabel.width + (ScreenTools.defaultFontPixelWidth * 4)
            //height:                 systemTimeLabel.height + (ScreenTools.defaultFontPixelHeight)
            height:                 parent.height / 2
            color:                  systemTimeMouseArea.pressed ? qgcPal.buttonHighlight : (systemTimeMouseArea.containsMouse ? qgcPal.button : "transparent")
            radius:                 ScreenTools.defaultFontPixelHeight / 4

            QGCLabel {
                id:                     systemTimeLabel
                anchors.centerIn:       parent
                text:                   "00:00:00"
                color:                  qgcPal.text
                font.pointSize:         ScreenTools.defaultFontPointSize
            }

            Timer {
                interval:       1000
                repeat:         true
                running:        true
                onTriggered: {
                    var now = new Date()
                    var h = ("0" + now.getHours()).slice(-2)
                    var m = ("0" + now.getMinutes()).slice(-2)
                    var s = ("0" + now.getSeconds()).slice(-2)
                    systemTimeLabel.text = h + ":" + m + ":" + s
                }
            }

            MouseArea {
                id:                 systemTimeMouseArea
                anchors.fill:       parent
                hoverEnabled:       true
            }
        }

        Rectangle {
            width:                  flightTimeLabel.width + (ScreenTools.defaultFontPixelWidth * 4)
            //height:                 flightTimeLabel.height + (ScreenTools.defaultFontPixelHeight)
            height:                 parent.height / 2
            color:                  flightTimeMouseArea.pressed ? qgcPal.buttonHighlight : (flightTimeMouseArea.containsMouse ? qgcPal.button : "transparent")
            radius:                 ScreenTools.defaultFontPixelHeight / 4

            QGCLabel {
                id:                     flightTimeLabel
                anchors.centerIn:       parent
                text:                   "00:00:00"
                color:                  qgcPal.text
                font.pointSize:         ScreenTools.defaultFontPointSize
            }

            Timer {
                interval:       1000
                repeat:         true
                running:        true
                onTriggered: {
                    if(_activeVehicle && _activeVehicle.vehicle) {
                        var flightSecs = _activeVehicle.vehicle.flightTime
                        var hrs = Math.floor(flightSecs / 3600)
                        var mins = Math.floor((flightSecs % 3600) / 60)
                        var secs = flightSecs % 60
                        var h = ("0" + hrs).slice(-2)
                        var m = ("0" + mins).slice(-2)
                        var s = ("0" + secs).slice(-2)
                        flightTimeLabel.text = h + ":" + m + ":" + s
                    } else {
                        flightTimeLabel.text = "00:00:00"
                    }
                }
            }

            MouseArea {
                id:                 flightTimeMouseArea
                anchors.fill:       parent
                hoverEnabled:       true
            }
        }
    }

    // middle/right: Indicator Area (including native indicators + our custom buttons)
    QGCFlickable {
        id:                     toolsFlickable
        // the Margin between components
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        // avoid overlap
        anchors.left:           timeIndicator.right
        anchors.bottomMargin:   1
        // fill parent
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorRow.width
        flickableDirection:     Flickable.HorizontalFlick

        // indicator row
        Row {
            id:                 indicatorRow
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

            // GPS Indicator
            GPSIndicator { }

            // Message indicator
            // Attention that the MessageIndicator is not supported in v5.0, cause many problems.
            // Original MessageIndicator function is shift into the MainStatueIndicator.
            MessageIndicator { }

            // Fuel Cell Indicator
            FuelCellIndicator { }

            // Battery Indicator
            BatteryIndicator { }
        }
    }

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
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandImageOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandImageOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandImageIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // progressBar
    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         parent.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
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