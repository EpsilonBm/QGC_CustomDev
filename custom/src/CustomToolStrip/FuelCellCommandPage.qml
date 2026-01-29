import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls
import QGroundControl.ScreenTools

// This component provides a drawer page for configuring and sending Fuel Cell commands.
ToolIndicatorPage {
    id: root

    // Get references to the active vehicle and the specific settings group
    property var _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var _fuelCellSettings:   QGroundControl.settingsManager.fuelCellIndicatorSettings

    // The main content of the drawer
    contentComponent: SettingsGroupLayout {
        heading: qsTr("Fuel Cell Command")

        // Use a GridLayout for clean alignment of labels and controls
        GridLayout {
            columns: 2
            columnSpacing: ScreenTools.defaultFontPixelWidth
            rowSpacing: ScreenTools.defaultFontPixelHeight / 2
            Layout.fillWidth: true

            // Row 1: Runtime Command (ComboBox)
            QGCLabel {
                text: _fuelCellSettings.RuntimeCommand.name
                Layout.alignment: Qt.AlignVCenter
            }
            FactComboBox {
                fact: _fuelCellSettings.RuntimeCommand
                Layout.fillWidth: true
            }

            // Row 2: Requested Power (TextField)
            QGCLabel {
                text: _fuelCellSettings.RequestedPower.name
                Layout.alignment: Qt.AlignVCenter
            }
            FactTextField {
                fact: _fuelCellSettings.RequestedPower
                Layout.fillWidth: true
            }

            // Row 3: Startup Mode (ComboBox)
            QGCLabel {
                text: _fuelCellSettings.StartupMode.name
                Layout.alignment: Qt.AlignVCenter
            }
            FactComboBox {
                fact: _fuelCellSettings.StartupMode
                Layout.fillWidth: true
            }
        }

        // Send Command Button
        QGCButton {
            text: qsTr("Send Command")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                if (_activeVehicle) {
                    _activeVehicle.sendFuelCellCommand(
                        _fuelCellSettings.RuntimeCommand.rawValue,
                        _fuelCellSettings.RequestedPower.rawValue,
                        _fuelCellSettings.StartupMode.rawValue
                    )
                    mainWindow.showMessageDialog("Command sent",
                        "Runtime=" + _fuelCellSettings.RuntimeCommand.rawValue + ", " +
                        "Power="   + _fuelCellSettings.RequestedPower.rawValue + ", " +
                        "Startup="  + _fuelCellSettings.StartupMode.rawValue)
                }
            }
        }
    }
}