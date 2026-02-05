/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Window
import QtQuick.Controls

import QGroundControl
import QGroundControl.Palette
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.ScreenTools

// AnalyzeView.qml - QGroundControl 分析视图组件
// 这个组件提供了一个可停靠/弹出的分析界面，包含多个子页面选项卡
Rectangle {
    id:     _root
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    // 弹出信号，用于将分析页面弹出到单独窗口
    signal popout()

    // 定义常用的尺寸属性
    readonly property real  _defaultTextHeight:     ScreenTools.defaultFontPixelHeight      // 默认文本高度
    readonly property real  _defaultTextWidth:      ScreenTools.defaultFontPixelWidth       // 默认文本宽度
    readonly property real  _horizontalMargin:      _defaultTextWidth / 2                   // 水平边距
    readonly property real  _verticalMargin:        _defaultTextHeight / 2                  // 垂直边距
    readonly property real  _buttonWidth:           _defaultTextWidth * 18                  // 按钮宽度

    // 阻止鼠标事件穿透到底层地图的区域
    DeadMouseArea {
        anchors.fill: parent
    }

    // 地理标记控制器
    GeoTagController {
        id: geoController
    }

    // 包含按钮列表的可滚动区域
    QGCFlickable {
        id:                 buttonScroll
        width:              buttonColumn.width
        anchors.topMargin:  _defaultTextHeight / 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left:       parent.left
        contentHeight:      buttonColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        // 按钮列布局 - 显示所有可用的分析页面
        Column {
            id:         buttonColumn
            width:      _maxButtonWidth
            spacing:    _defaultTextHeight / 2

            property real _maxButtonWidth: 0

            // 组件完成加载后调整按钮宽度
            Component.onCompleted: reflowWidths()

            // I don't know why this does not work
            Connections {
                target:         QGroundControl.settingsManager.appSettings.appFontPointSize
                onValueChanged: buttonColumn.reflowWidths()
            }

            // 调整按钮宽度函数 - 确保所有按钮具有相同的最大宽度
            function reflowWidths() {
                buttonColumn._maxButtonWidth = 0
                for (var i = 0; i < children.length; i++) {
                    buttonColumn._maxButtonWidth = Math.max(buttonColumn._maxButtonWidth, children[i].width)
                }
                for (var j = 0; j < children.length; j++) {
                    children[j].width = buttonColumn._maxButtonWidth
                }
            }

            // 使用重复器动态创建分析页面按钮
            Repeater {
                id:     buttonRepeater
                model:  QGroundControl.corePlugin ? QGroundControl.corePlugin.analyzePages : []

                // 组件完成加载后，默认选择第一个按钮
                Component.onCompleted:  itemAt(0).checked = true

                // 子菜单按钮 - 每个分析页面对应一个按钮
                SubMenuButton {
                    id:                 subMenu
                    imageResource:      modelData.icon      // 从model获取图标资源
                    autoExclusive:      true                // 自动排他性，一次只能选择一个
                    text:               modelData.title     // 从model获取标题

                    onClicked: {
                        // 点击按钮时更新加载器的源和标题
                        panelLoader.source  = modelData.url
                        panelLoader.title   = modelData.title
                        checked             = true
                    }
                }
            }
        }
    }

    // 分隔线 - 将按钮列表和内容面板分开
    Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonScroll.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  qgcPal.windowShade
    }

    // 加载并显示所选分析页面内容
    Loader {
        id:                     panelLoader
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.left:           divider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        source:                 "LogDownloadPage.qml"       // 默认加载日志下载页面

        property string title                                   // 当前面板的标题

        // 监听加载项的弹出信号，创建新的分析页面窗口
        Connections {
            target:     panelLoader.item
            onPopout:   mainWindow.createrWindowedAnalyzePage(panelLoader.title, panelLoader.source)
        }
    }
}
