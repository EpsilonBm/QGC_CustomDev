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
// 消息指示器
Item {
    id:             _root
    // 设置高度以填充父工具栏行
    height: parent.height
    // 设置宽度以适应内容
    width:  height

    property bool showIndicator: true

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isMessageImportant:    _activeVehicle ? !_activeVehicle.messageTypeNormal && !_activeVehicle.messageTypeNone : false

    /// 显示消息指示器抽屉/弹窗
    function dropMessageIndicator() {
        mainWindow.showIndicatorDrawer(vehicleMessagesPopup, _root);
    }

    /// 根据当前消息类型返回适当的颜色
    /// @return {color} 表示消息类型的颜色
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
            // 这种情况不应该发生，但如果发生了，使用醒目的颜色来表示错误
            console.warn("MessageIndicator.qml:getMessageColor 无效的载具类型", _activeVehicle.messageTypeNone)
            return "purple";
        }
        // 此条件发生在窗口仍活动时车辆关闭的情况下
        return qgcPal.colorGrey
    }

    // 重要消息图标 - 当有重要消息时显示
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

    // 常规消息图标 - 当有消息但不重要时显示
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

    // 处理点击事件以打开消息弹窗
    MouseArea {
        anchors.fill:   parent
        onClicked:      dropMessageIndicator()
    }

    // 用于显示车辆消息的弹窗组件
    Component {
        id: vehicleMessagesPopup

        ToolIndicatorPage {
            showExpand: false

            contentComponent: Component {
                ColumnLayout {
                    spacing: ScreenTools.defaultFontPixelHeight / 2

                    SettingsGroupLayout {
                        heading:            qsTr("载具信息")
                        Layout.fillWidth:   true

                        // 使用Loader加载VehicleMessageList以确保我们从标准QGC控件获取正确的组件
                        Loader {
                            Layout.fillWidth: true
                            source: "qrc:/qml/QGroundControl/Controls/VehicleMessageList.qml"
                        }
                    }

                    QGCButton {
                        text:               qsTr("清除信息")
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
