import QtQuick
import QtQuick.Controls

import QGroundControl.Palette
import QGroundControl.ScreenTools

/// File Button controls used by QGCFileDialog control
// 文件按钮控件，用于 QGCFileDialog 控制
Rectangle {
    implicitWidth:  ScreenTools.implicitButtonWidth
    implicitHeight: ScreenTools.implicitButtonHeight
    color:          highlight ? qgcPal.buttonHighlight : qgcPal.button
    border.color:   highlight ? qgcPal.buttonHighlightText : qgcPal.buttonText

    // 文本属性别名，用于设置按钮显示文本
    property alias  text:       label.text
    // 高亮状态属性，默认为 false
    property bool   highlight:  false

    // 按钮点击信号
    signal clicked
    // 菜单图标点击信号
    signal hamburgerClicked

    // 内边距大小，基于默认字体宽度的一半
    property real _margins: ScreenTools.defaultFontPixelWidth / 2

    // QGC 调色板，用于管理颜色主题
    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    // 显示按钮文本的标签
    QGCLabel {
        id:                     label
        anchors.margins:         _margins
        anchors.left:           parent.left
        anchors.right:          hamburger.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        verticalAlignment:      Text.AlignVCenter
        horizontalAlignment:    Text.AlignHCenter
        color:                  highlight ? qgcPal.buttonHighlightText : qgcPal.buttonText
        elide:                  Text.ElideRight
    }

    // 菜单图标，显示汉堡菜单样式
    QGCColoredImage {
        id:                     hamburger
        anchors.rightMargin:    _margins
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        width:                  _hamburgerSize
        height:                 _hamburgerSize
        sourceSize.height:      _hamburgerSize
        source:                 "qrc:/qmlimages/Hamburger.svg"
        color:                  highlight ? qgcPal.buttonHighlightText : qgcPal.buttonText

        // 菜单图标的大小，为父元素高度的 75%
        property real _hamburgerSize: parent.height * 0.75
    }

    // 主按钮区域的鼠标事件处理
    QGCMouseArea {
        anchors.fill:   parent
        onClicked:      parent.clicked()
    }

    // 菜单图标区域的鼠标事件处理
    QGCMouseArea {
        anchors.leftMargin: -_margins * 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.right:      parent.right
        anchors.left:       hamburger.left
        onClicked:          parent.hamburgerClicked()
    }
}
