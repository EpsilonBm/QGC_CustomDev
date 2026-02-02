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

    readonly property real   indicatorValueWidth: ScreenTools.defaultFontPixelWidth * 7

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75

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
        bottomEdgeCenterInset:  customPanel.height + parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   customPanel.height + parentToolInsets.bottomEdgeRightInset
    }

    CustomPanel {
        id:                        customPanel
        anchors.bottom:            parent.bottom
        anchors.horizontalCenter:  parent.horizontalCenter
        parentToolInsets:          _root.parentToolInsets
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

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: "任务 / 设置"
                color: "white"
                font.pixelSize: 18
            }

            Button {
                text: "任务规划"
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
                onClicked: {
                    // 跳转到应用设置
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.showSettingsTool()
                        rightPanelOpen = false
                    }
                }
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