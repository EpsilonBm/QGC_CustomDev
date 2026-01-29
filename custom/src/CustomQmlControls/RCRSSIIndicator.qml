import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette
/*
 * 这个组件显示遥控器信号强度指示器
 * 它会根据车辆发送的RC RSSI值显示相应的信号图标和百分比
 */

Item {
    id: _root

    // 只要连接了飞行器就显示此组件
    visible: _activeVehicle

    // 设置高度以填充父工具栏行
    height: parent.height
    // 设置宽度以适应内容
    width:  _rowLayout.width

    // 获取当前活动的飞行器实例
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    // 从飞行器获取RC RSSI值，这是一个百分比(0-100)，无效时为255
    property int _rcRSSI: _activeVehicle ? _activeVehicle.rcRSSI : 0

    // QGroundControl调色板，用于统一颜色主题
    QGCPalette { id: qgcPal }

    /*
     * 布局容器，包含信号图标和数值显示
     * 使用RowLayout来水平排列组件
     */
    RowLayout {
        id:                     _rowLayout
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        /*
         * 显示信号强度图标的图像组件
         * 根据信号强度动态切换不同的SVG图标
         */
        Image{
            id:                     signalStrengthIcon
            Layout.alignment:       Qt.AlignVCenter
            Layout.preferredHeight: _root.height * 0.6
            Layout.preferredWidth:  Layout.preferredHeight

            sourceSize.height:      height
            fillMode:               Image.PreserveAspectFit
            //color:                  qgcPal.text

            /*
             * 根据RC RSSI值返回对应的信号图标路径
             * 如果值大于100(无效值)，则显示最低信号图标
             */
            function getIconSource() {
                var val = _rcRSSI > 100 ? 0 : _rcRSSI
                if (val < 20) return "qrc:/custom/img/RC_signal_0.svg"
                if (val < 40) return "qrc:/custom/img/RC_signal_25.svg"
                if (val < 60) return "qrc:/custom/img/RC_signal_50.svg"
                if (val < 90) return "qrc:/custom/img/RC_signal_75.svg"
                return "qrc:/custom/img/RC_signal_100.svg"
            }

            source: getIconSource()
        }

        /*
         * 显示具体的RC RSSI数值或"无效"文本
         * 当值大于100时显示"Invalid"，否则显示百分比
         */
        QGCLabel {
            Layout.alignment:   Qt.AlignVCenter
            text:               _rcRSSI > 100 ? qsTr("无效") : (_rcRSSI + "%")
            color:              qgcPal.text
            font.pointSize:     ScreenTools.defaultFontPointSize
        }
    }
}
