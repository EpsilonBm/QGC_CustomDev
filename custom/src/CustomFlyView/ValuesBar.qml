import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap

import Custom.QmlControls // For FuelCellIndicator

Item {
    id: _root

    // 定义界面元素间距
    property real _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75
    
    // 计算指南针半径相关属性
    property real defaultCompassRadius: (mainWindow.width * 0.15) / 2  // 默认指南针半径为窗口宽度的15%的一半
    property real maxCompassRadius    : ScreenTools.defaultFontPixelHeight * 7 / 2  // 最大指南针半径
    property real compassRadius       : Math.min(defaultCompassRadius, maxCompassRadius)  // 实际使用的指南针半径
    property real compassBorder       : ScreenTools.defaultFontPixelHeight / 2  // 指南针边框宽度
    property real attitudeSize:         ScreenTools.defaultFontPixelHeight * 0.75  // 姿态指示器大小
    property real attitudeSpacing:      ScreenTools.defaultFontPixelHeight / 4  // 姿态指示器间距
    property real valuesBarHeight     : compassRadius * 1.5  // 整个数值栏的高度
    
    // 遥测数据显示配置：标签、单位和对应的数据字段
    property var _telemetryData: [
        { label: qsTr("对地速度"), unit: "m/s", fact: "groundSpeed" },      // 地面速度
        { label: qsTr("飞行空速"), unit: "m/s", fact: "airSpeed" },         // 空速
        { label: qsTr("上升速度"),  unit: "m/s",   fact: "climbRate" },   // 爬升率
        { label: qsTr("对地高度"),  unit: "m",   fact: "altitudeRelative" }   // 相对高度
    ]

    // 高度根据内容加上垂直边距确定
    height: valuesBarHeight

    // 宽度计算确保左右两侧对称
    width: Math.max((_leftDataColumn.implicitWidth + compassRadius + _leftMargin), (_fuelCellIndicator.implicitWidth + compassRadius + _rightMargin)) * 2

    // 从FlyViewCustomLayer传递下来的属性
    property var parentToolInsets

    QGCPalette { id: qgcPal }

    // 获取当前活动飞行器
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    // Background Rectangle
    Rectangle {
        id:           backgroundRect
        anchors.fill: parent
        color:        qgcPal.window
        opacity:      0.75
        radius:       ScreenTools.defaultFontPixelHeight / 4
    }

    // 左右两侧边距，考虑父级传入的工具插入值
    property real _leftMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeLeftInset : 0)
    property real _rightMargin: _toolsMargin + (_root.parentToolInsets ? _root.parentToolInsets.bottomEdgeRightInset : 0)

    // 左侧：遥测数据网格显示 - 包含标签、数值和单位三列
    GridLayout {
        id:                     _leftDataColumn
        anchors.right:          parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:    compassRadius + compassBorder  // 与中心指南针保持一定距离
        columnSpacing:          _toolsMargin / 2  // 列之间的间距
        rowSpacing:             _toolsMargin / 4  // 行之间的间距
        columns:                3  // 三列：标签、数值、单位
        rows:                   _telemetryData.length  // 行数等于遥测数据项数量
        flow:                   GridLayout.TopToBottom  // 从上到下排列

        // 第一列：显示数据项标签
        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignRight  // 垂直居中，右对齐
                text:               modelData.label  // 显示标签文本
                color:              qgcPal.text  // 文本颜色
            }
        }

        // 第二列：显示实际数值
        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignRight  // 垂直居中，右对齐
                property var factObj: _activeVehicle ? _activeVehicle[modelData.fact] : null  // 获取对应的遥测对象
                text:               factObj ? factObj.valueString : "--.--"  // 显示数值或默认提示
                color:              qgcPal.text  // 文本颜色
            }
        }

        // 第三列：显示单位
        Repeater {
            model: _telemetryData
            QGCLabel {
                Layout.alignment:   Qt.AlignVCenter | Qt.AlignLeft  // 垂直居中，左对齐
                text:               modelData.unit  // 显示单位
                color:              qgcPal.text  // 文本颜色
            }
        }
    }

    // 右侧：电池指示器
    FuelCellIndicator {
        id:                     _fuelCellIndicator
        anchors.left:           parent.horizontalCenter  // 左边锚定到父元素中心
        anchors.right:          parent.right  // 右边锚定到父元素右边
        anchors.verticalCenter: parent.verticalCenter  // 垂直居中
        anchors.leftMargin:     compassRadius  // 左边距，与指南针保持距离
        anchors.rightMargin:    _rightMargin  // 右边距
    }
}
