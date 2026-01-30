import QtQuick
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay

ToolStripAction {
    text:       _guidedController._customController.startSwitchText
    iconSource: _guidedController._customController.startSwitchIcon
    visible:    _guidedController._customController._fuelCell
    enabled:    _guidedController._customController._fuelCell

    property int actionID: _guidedController._customController.actionFuelCellStart
    // 显式获取 _guidedController，因为 ToolStripAction 默认不包含此属性
    property var _guidedController: globals.guidedControllerFlyView

    onTriggered: {
        _guidedController.confirmAction(actionID)
    }
}