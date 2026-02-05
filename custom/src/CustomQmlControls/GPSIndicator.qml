import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Palette

/* Note:
*  When using the value that would update with times or event, must define a
*  property to hold the value. This explicitly bind ensure the value would
*  update when the up-flow value change.
*/


Item {
    id: _root
    height:         parent.height
    width:          gpsRow.width + (ScreenTools.defaultFontPixelWidth * 2)
    visible:        _activeVehicle

    // 获取当前活动的飞行器对象
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    Row {
        id:                 gpsRow
        anchors.centerIn:   parent
        spacing:            ScreenTools.defaultFontPixelWidth / 2

        // 显式绑定GPS锁定状态，确保图像和标签的数据同步更新
        property int gpsLock: _activeVehicle ? _activeVehicle.gps.lock.rawValue : 0

        // GPS图标，根据锁定状态显示不同颜色
        QGCColoredImage {
            height:             ScreenTools.defaultFontPixelHeight * 1.5
            width:              height
            sourceSize.height:  height
            source:             "qrc:/custom/img/Gps.svg"
            fillMode:           Image.PreserveAspectFit
            //color:              qgcPal.text
            color: {
                if (gpsRow.gpsLock >= 6) return qgcPal.colorGreen     // RTK-Fixed
                if (gpsRow.gpsLock === 5) return qgcPal.colorYellow   // RTK-Float
                if (gpsRow.gpsLock === 4 || gpsRow.gpsLock === 3) return qgcPal.colorOrange   // DGPS and GNSS
                return qgcPal.colorRed
            }
            // 根据卫星数量调整透明度，有信号则完全不透明，无信号则半透明
            opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
            anchors.verticalCenter: parent.verticalCenter
        }

        // GPS数值和状态信息列布局
        Column {
            id:                       gpsVaule
            anchors.verticalCenter:   parent.verticalCenter
            spacing:                  0

            // 显示卫星数量的标签
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text:                     _activeVehicle ? _activeVehicle.gps.count.valueString : ""
                color:                    qgcPal.buttonText
            }

            // 显示GPS定位模式的标签
            QGCLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (!_activeVehicle) return qsTr("No Conn")
                    if (gpsRow.gpsLock >= 6) return qsTr("RTK-Fixed")
                    if (gpsRow.gpsLock === 5) return qsTr("RTK-Float")
                    if (gpsRow.gpsLock === 4) return qsTr("DGPS")
                    if (gpsRow.gpsLock === 3) return qsTr("GNSS")
                    if (gpsRow.gpsLock === 2) return qsTr("2D")
                    return qsTr("No Fix")
                }
                color:                    qgcPal.buttonText
                font.pointSize:           ScreenTools.smallFontPointSize
            }
        }
    }
    // 鼠标交互区域，允许用户点击打开GPS详情面板
    MouseArea {
        anchors.fill: parent
        enabled: _activeVehicle && _activeVehicle.gps.count.value >= 0
        onClicked: {
            // 检查主窗口是否存在以及方法是否可用后，打开指示器抽屉
            if(mainWindow && typeof mainWindow.showIndicatorDrawer === 'function') {
                mainWindow.showIndicatorDrawer(gpsIndicatorPage, _root)
            }
        }
    }

    // 定义GPS指示器页面组件
    Component {
        id: gpsIndicatorPage
        GPSIndicatorPage { }
    }
}