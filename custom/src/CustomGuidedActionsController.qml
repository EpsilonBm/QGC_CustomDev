/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

// Custom builds can override this file to add custom guided actions.

import QtQml
import QGroundControl

QtObject {
    // action ID
    readonly property int actionCustomButton:   10000 + 0 // _guidedController.customActionStart is 10000
    readonly property int actionCameraSwitch:   10000 + 1
    readonly property int actionGimbalControl:  10000 + 2
    readonly property int actionLoadSec2:       10000 + 3
    readonly property int actionLoadSec3:       10000 + 4
    readonly property int actionFuelCellStart:  10000 + 5

    readonly property string customButtonTitle: qsTr("Custom")
    readonly property string customButtonMessage: qsTr("Example of a custom action.")

    // Camera properties
    property var    _activeVehicle:      QGroundControl.multiVehicleManager.activeVehicle
    property var    _cameraManager:      _activeVehicle ? _activeVehicle.cameraManager : null
    // Fix: use currentCameraInstance to get object, instead of currentCamera which get the camera index.
    property var    _currentCamera:      _cameraManager ? _cameraManager.currentCameraInstance : null
    property bool   cameraAvailable:     _currentCamera !== null
    property var    _fuelCell:           _activeVehicle ? _activeVehicle.fuelCell : null
    property var    _fuelCellSettings:   QGroundControl.settingsManager.fuelCellIndicatorSettings

    // TODO: Add -1 and 3 camera mode
    property string cameraSwitchIcon: {
        if (_currentCamera) {
            // 1 = Video Mode, 0 = Photo Mode
            if (_currentCamera.cameraMode === 1) {
                return "qrc:/custom/img/camera_video.svg"
            } else {
                return "qrc:/custom/img/camera_photo.svg"
            }
        }
        return "qrc:/custom/img/camera_photo.svg"
    }

    property string startSwitchIcon: {
        if (_fuelCell) {
            if (_fuelCell.systemStatus.rawValue === 0) {
                // 0 = Stop
                // when Stop show power icon
                return "qrc:/custom/img/PowerButton.svg"
            } else {
                // 1,2,3 = Warm-up, Running, Fault
                // when Running show pause icon
                return "qrc:/custom/img/pause.svg"
            }
        }
        // default show power icon
        return "qrc:/custom/img/PowerButton.svg"
    }

    property string startSwitchText: {
        if (_fuelCell) {
            if (_fuelCell.systemStatus.rawValue === 0) {
                // 0 = Stop
                // when Stop show power icon
                return "启动燃料电池"
            } else {
                // 1,2,3 = Warm-up, Running, Fault
                // when Running show pause icon
                return "停止燃料电池"
            }
        }
        // default show power icon
        return "启动燃料电池"
    }


    function customConfirmAction(actionCode, actionData, mapIndicator, confirmDialog) {
        switch (actionCode) {
        case actionCustomButton:
            confirmDialog.hideTrigger = true
            confirmDialog.title = customButtonTitle
            confirmDialog.message = customButtonMessage
            break
        case actionCameraSwitch:
            // We handle execution directly via executeAction override in QML, there is no need for confirm,
            // but if it falls through here, we don't need a dialog.
            return false
        case actionFuelCellStart:
            confirmDialog.hideTrigger = true
            confirmDialog.title = startSwitchText
            confirmDialog.message = startSwitchText
            break
        default:
            return false // false = action not handled here
        }

        return true // true = action handled here
    }

    function customExecuteAction(actionCode, actionData, sliderOutputValue, optionChecked) {
        switch (actionCode) {
        case actionCustomButton:
            mainWindow.showMessageDialog("Custom Action", "Custom action executed.")
            break
        case actionCameraSwitch:
            if (_currentCamera) {
                if (_currentCamera.cameraMode === -1){
                    mainWindow.showMessageDialog("Error", "Camera not set yet!")
                    //mainWindow.showMessageDialog("TestMessage", "_currentCamera:" + _currentCamera + "\ncameraMode: " + _currentCamera.cameraMode)
                    break
                }
                // Use toggle method provided by C++ layer
                _currentCamera.toggleCameraMode()
                //mainWindow.showMessageDialog("TestMessage", "_currentCamera:" + _currentCamera + "\ncameraMode: " + _currentCamera.cameraMode)
            }
            break
        case actionLoadSec2:
            // mainWindow.showMessageDialog("Load Control", "sec2 executed")
            break
        case actionLoadSec3:
            // mainWindow.showMessageDialog("Load Control", "sec3 executed")
            break
        case actionFuelCellStart:
            if (_fuelCell) {
                if (_fuelCell.systemStatus.rawValue === 0) {
                    // 0 = Stop
                    _activeVehicle.sendFuelCellStart()
                } else {
                    // 1,2,3 = Warm-up, Running, Fault
                    _activeVehicle.sendFuelCellStop()
                }
            }
            break
        default:
            return false // false = action not handled here
        }

        return true // true = action handled here
    }
}