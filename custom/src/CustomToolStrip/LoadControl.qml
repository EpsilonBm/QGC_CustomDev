import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools
import Custom.ToolStrip 1.0

ToolStripAction {
    text:           qsTr("负载控制")
    iconSource:     "/qmlimages/Gears.svg"
    visible:        QGroundControl.multiVehicleManager.activeVehicle
    enabled:        visible

    property var _guidedController: globals.guidedControllerFlyView

    dropPanelComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelWidth

            QGCButton {
                id:                 gimbalButton
                text:               "云台"
                iconSource:         "qrc:/custom/img/gimbal.svg"
                Layout.fillWidth:   true
                onClicked: {
                    mainWindow.showIndicatorDrawer(gimbalPageComponent, gimbalButton)
                    dropPanel.hide()
                }
            }

            // QGCButton {
            //     text:               "sec2"
            //     iconSource:         "qrc:/custom/img/chronometer.svg"
            //     Layout.fillWidth:   true
            //     onClicked: {
            //         _guidedController.executeAction(_guidedController._customController.actionLoadSec2, null, null, false)
            //         dropPanel.hide()
            //     }
            // }
            //
            // QGCButton {
            //     text:               "sec3"
            //     iconSource:         "qrc:/custom/img/Gps.svg"
            //     Layout.fillWidth:   true
            //     onClicked: {
            //         _guidedController.executeAction(_guidedController._customController.actionLoadSec3, null, null, false)
            //         dropPanel.hide()
            //     }
            // }
        }
    }

    property Component gimbalPageComponent: Component {
        GimbalPage {}
    }
}