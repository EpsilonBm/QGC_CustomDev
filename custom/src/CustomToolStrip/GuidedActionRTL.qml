import QtQuick
import QGroundControl.FlightDisplay
import QGroundControl // For globalPalette

GuidedToolStripAction {
    text:       _guidedController ? _guidedController.rtlTitle : ""
    iconSource: "/res/rtl.svg"
    visible:    true
    enabled:    _guidedController ? _guidedController.showRTL : false
    actionID:   _guidedController ? _guidedController.actionRTL : 0


    // // Define the color property. The ToolStrip delegate will use this.
    // // Use the global palette singleton to avoid instantiation errors.
    // property color color: QGroundControl.globalPalette.colorOrange
    // Define a custom property to hold the color, which the delegate will read.
    property color customButtonColor: QGroundControl.globalPalette.colorOrange
}