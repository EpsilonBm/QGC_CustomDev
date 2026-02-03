/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.FlightMap

import QGroundControl.FlightDisplay
import QGroundControl.FlightMap

import QGroundControl.Controllers

import Custom.FlyView 1.0
import Custom.Widgets

Item {
    id: _root
    property var parentToolInsets                       // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets: _totalToolInsets    // The insets updated for the custom overlay additions
    property var mapControl

    property bool rightPanelOpen: false

    readonly property string noGPS: qsTr("NO GPS")
    readonly property real   indicatorValueWidth: ScreenTools.defaultFontPixelWidth * 7

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _indicatorDiameter:     ScreenTools.defaultFontPixelWidth * 18
    property real   _indicatorsHeight:      ScreenTools.defaultFontPixelHeight
    property var    _sepColor:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.5) : Qt.rgba(1,1,1,0.5)
    property color  _indicatorsColor:       qgcPal.text
    property bool   _isVehicleGps:          _activeVehicle ? _activeVehicle.gps.count.rawValue > 1 && _activeVehicle.gps.hdop.rawValue < 1.4 : false
    property string _altitude:              _activeVehicle ? (isNaN(_activeVehicle.altitudeRelative.value) ? "0.0" : _activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + _activeVehicle.altitudeRelative.units : "0.0"
    property string _distanceStr:           isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property real   _distance:              _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0
    property string _messageTitle:          ""
    property string _messageText:           ""
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75

    function secondsToHHMMSS(timeS) {
        var sec_num = parseInt(timeS, 10);
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours   < 10) {hours   = "0"+hours;}
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return hours+':'+minutes+':'+seconds;
    }

    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    exampleRectangle.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset
    }

    // This is an example of how you can use parent tool insets to position an element on the custom fly view layer
    // - we use parent topEdgeLeftInset to position the widget below the toolstrip
    // - we use parent bottomEdgeLeftInset to dodge the virtual joystick if enabled
    // - we use the parent leftEdgeTopInset to size our element to the same width as the ToolStripAction
    // - we export the width of this element as the leftEdgeCenterInset so that the map will recenter if the vehicle flys behind this element
    Rectangle {
        id: exampleRectangle
        visible: false // to see this example, set this to true. To view insets, enable the insets viewer FlyView.qml
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: parentToolInsets.topEdgeLeftInset + _toolsMargin
        anchors.bottomMargin: parentToolInsets.bottomEdgeLeftInset + _toolsMargin
        anchors.leftMargin: _toolsMargin
        width: parentToolInsets.leftEdgeTopInset - _toolsMargin
        color: 'red'

        property real leftEdgeCenterInset: visible ? x + width : 0
    }

    // TODO: To see how its size adapted to the screen especially in Android
    CustomPanel {
        id:                        customPanel
        anchors.bottom:            parent.bottom
        anchors.horizontalCenter:  parent.horizontalCenter
        parentToolInsets:          _root.parentToolInsets
    }

    // 半透明背景覆盖层，用于点击关闭面板
    Rectangle {
        id: backgroundOverlay
        z: 99
        anchors.fill: parent
        color: "black"
        opacity: 0
        visible: rightPanelOpen
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                rightPanelOpen = false
            }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
    
    Rectangle {
        id: rightTaskPanel
        z: 100
        width: 120
        height: parent.height
        color: "#202020"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: rightPanelOpen ? 0 : -width  // 改成 rightMargin 来控制滑动

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 250
            }
        }

        // 阻止鼠标事件穿透到背景层
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                // 如果点击的是面板本身，则不关闭面板
                mouse.accepted = true
            }
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10
            
            Text {
                text: "任务 / 设置"
                color: "white"
                font.pixelSize: 18
                height: 30
            }
            
            Flickable {
                id: flickable
                width: parent.width
                height: parent.height - 40  // 减去标题的高度
                contentWidth: parent.width
                contentHeight: buttonColumn.height  // 根据内容调整高度
                clip: true
                
                Column {
                    id: buttonColumn
                    width: parent.width
                    spacing: 10
                    
                    Button {
                        text: "任务规划"
                        width: parent.width
                        height: 40
                        onClicked: {
                            // 跳转到任务规划视图
                            if (mainWindow.allowViewSwitch()) {
                                mainWindow.showPlanView()
                                rightPanelOpen = false  // 关闭面板
                            }
                        }
                    }
                    
                    Button {
                        text: "航线库"
                        width: parent.width
                        height: 40
                        onClicked: {
                            // 动态加载航线库界面
                            console.log("航线库按钮被点击");
                            flightPathLibraryLoader.source = "VtFlightPathLibrary.qml";
                            flightPathLibraryLoader.active = true;
                            rightPanelOpen = false;  // 关闭面板
                        }
                    }
                    
                    Button {
                        text: "设备状态"
                        width: parent.width
                        height: 40
                        onClicked: {
                            // 打开设备配置页面
                            if (mainWindow.allowViewSwitch()) {
                                mainWindow.showVehicleConfig()
                                rightPanelOpen = false
                            }
                        }
                    }
                    
                    Button {
                        text: "媒体库"
                        width: parent.width
                        height: 40
                        onClicked: {
                            // 动态加载媒体库界面
                            console.log("媒体库按钮被点击");
                            mediaLibraryLoader.source = "MediaLibraryView.qml";
                            mediaLibraryLoader.active = true;
                            rightPanelOpen = false;  // 关闭面板
                        }
                    }
                    
                    Button {
                        text: "设置"
                        width: parent.width
                        height: 40
                        onClicked: {
                            // 跳转到应用设置
                            if (mainWindow.allowViewSwitch()) {
                                mainWindow.showSettingsTool()
                                rightPanelOpen = false
                            }
                        }
                    }
                }
                
                ScrollBar.vertical: ScrollBar {}
            }
        }
    }

    Rectangle {
        id: toggleButton
        z: 200  // 确保它在面板上面
        width: 28
        height: 80
        radius: 4
        color: "#2c2c2c"

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: rightPanelOpen ? ">" : "<"
            color: "white"
            font.pixelSize: 16
        }

        MouseArea {
            anchors.fill: parent
            onClicked: rightPanelOpen = !rightPanelOpen
        }
    }

    // 使用Loader动态加载航线库组件
    Loader {
        id: flightPathLibraryLoader
        anchors.fill: parent
        z: 999  // 确保航线库显示在最上层
        active: false  // 默认不激活，只有点击航线库按钮时才加载

        // 当加载完成后，连接关闭信号
        onLoaded: {
            console.log("航线库组件加载完成");
            if (item && item.closeRequested) {
                console.log("连接关闭信号");
                item.closeRequested.connect(function() {
                    console.log("收到关闭信号，隐藏航线库");
                    flightPathLibraryLoader.active = false;
                });
            }
        }
    }

    // 使用Loader动态加载媒体库组件
    Loader {
        id: mediaLibraryLoader
        anchors.fill: parent
        z: 999  // 确保媒体库显示在最上层
        active: false  // 默认不激活，只有点击媒体库按钮时才加载

        // 当加载完成后，连接关闭信号
        onLoaded: {
            console.log("媒体库组件加载完成");
            if (item && item.closeRequested) {
                console.log("连接媒体库关闭信号");
                item.closeRequested.connect(function() {
                    console.log("收到媒体库关闭信号，隐藏媒体库");
                    mediaLibraryLoader.active = false;
                });
            }
        }
    }
}