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

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.Controls

// Toolstrip控件，显示一列可交互的工具按钮
Rectangle {
    id:         _root
    color:      qgcPal.toolbarBackground  // 设置工具条背景色
    width:      ScreenTools.defaultFontPixelWidth * 8  // 工具条宽度
    height:     Math.min(maxHeight, toolStripColumn.height + (flickable.anchors.margins * 2))  // 高度取最大高度和内容高度的最小值
    radius:     ScreenTools.defaultFontPixelWidth / 2  // 圆角半径

    // 定义属性
    property alias  model:              repeater.model  // 按钮数据模型
    property real   maxHeight           ///< 控件的最大高度，决定是否隐藏文本使控件更短
    property alias  title:              titleLabel.text  // 标题文本
    property var    fontSize:           ScreenTools.smallFontPointSize  // 字体大小

    property var _dropPanel: dropPanel  // 下拉面板

    // 模拟点击指定索引的按钮
    function simulateClick(buttonIndex) {
        buttonIndex = buttonIndex + 1 // 跳过标题标签
        var button = toolStripColumn.children[buttonIndex]  // 获取对应按钮
        if (button.checkable) {  // 如果按钮可选中
            button.checked = !button.checked  // 切换选中状态
        }
        button.clicked()  // 触发点击事件
    }

    signal dropped(int index)  // 拖拽放下信号

    // 死区鼠标事件处理，防止与底层控件交互
    DeadMouseArea {
        anchors.fill: parent
    }

    // 可滚动容器，允许在内容超出最大高度时滚动
    QGCFlickable {
        id:                 flickable
        anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.4  // 边距
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        height:             parent.height - anchors.margins * 2  // 高度减去边距
        contentHeight:      toolStripColumn.height  // 内容高度
        flickableDirection: Flickable.VerticalFlick  // 垂直滚动
        clip:               true  // 超出部分裁剪

        // 垂直布局容器，放置标题和按钮
        Column {
            id:             toolStripColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelWidth * 0.25  // 按钮间距

            // 标题标签
            QGCLabel {
                id:                     titleLabel
                anchors.left:           parent.left
                anchors.right:          parent.right
                horizontalAlignment:    Text.AlignHCenter  // 文本居中对齐
                font.pointSize:         ScreenTools.smallFontPointSize  // 字体大小
                visible:                title != ""  // 仅当标题不为空时显示
            }

            // 重复器，根据model生成多个按钮
            Repeater {
                id: repeater

                // 工具条按钮模板
                ToolStripHoverButton {
                    id:                 buttonTemplate
                    anchors.left:       toolStripColumn.left
                    anchors.right:      toolStripColumn.right
                    height:             width  // 高度等于宽度，形成正方形按钮
                    radius:             ScreenTools.defaultFontPixelWidth / 2  // 圆角
                    fontPointSize:      _root.fontSize  // 字体大小
                    toolStripAction:    modelData  // 绑定到模型数据
                    dropPanel:          _dropPanel  // 关联下拉面板
                    onDropped: (index) => _root.dropped(index)  // 处理拖放事件

                    onCheckedChanged: {
                        // 手动处理互斥选择状态，因为使用autoExclusive导致各种问题
                        if (checked) {  // 如果当前按钮被选中
                            for (var i=0; i<repeater.count; i++) {  // 遍历所有按钮
                                if (i != index) {  // 排除当前按钮
                                    var button = repeater.itemAt(i)  // 获取其他按钮
                                    if (button.checked) {  // 如果其他按钮被选中
                                        button.checked = false  // 取消选中
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 下拉面板
    ToolStripDropPanel {
        id:         dropPanel
        toolStrip:  _root  // 关联工具条
    }
}
