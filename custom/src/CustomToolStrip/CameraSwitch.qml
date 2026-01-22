import QtQuick
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay

ToolStripAction {
    text:       qsTr("Photo/Video Switch")
    iconSource: _guidedController ? _guidedController._customController.cameraSwitchIcon : ""
    visible:    _guidedController ? _guidedController._customController.cameraAvailable : false
    enabled:    _guidedController ? _guidedController._customController.cameraAvailable : false
    
    property int actionID: _guidedController ? _guidedController._customController.actionCameraSwitch : 0
    // 显式获取 _guidedController，因为 ToolStripAction 默认不包含此属性
    property var _guidedController: globals.guidedControllerFlyView

    // Override triggered to execute immediately without confirmation dialog
    onTriggered: _guidedController.executeAction(actionID, null, null, false)
}