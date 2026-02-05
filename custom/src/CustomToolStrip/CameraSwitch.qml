import QtQuick
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay

ToolStripAction {
    text:       qsTr("切换")
    iconSource: _guidedController._customController.cameraSwitchIcon
    visible:    _guidedController._customController.cameraAvailable
    enabled:    _guidedController._customController.cameraAvailable
    
    property int actionID: _guidedController._customController.actionCameraSwitch
    // 显式获取 _guidedController，因为 ToolStripAction 默认不包含此属性
    property var _guidedController: globals.guidedControllerFlyView

    // Override triggered to execute immediately without confirmation dialog
    onTriggered: _guidedController.executeAction(actionID, null, null, false)
}