import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools
import Custom.ToolStrip 1.0

ToolStripAction{
    property var    _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var    fuelCell:            _activeVehicle ? _activeVehicle.fuelCell : null

    id:            fuelCellCommandButton
    text:          qsTr("FuelCellCommand")
    iconSource:    "qrc:/custom/img/waves.svg"
    visible:       fuelCell !== null
    enabled:       visible

    onTriggered: {
        mainWindow.showIndicatorDrawer(fuelCellCommandPage, fuelCellCommandButton)
    }

    property Component fuelCellCommandPage: Component {
        FuelCellCommandPage {}
    }
}