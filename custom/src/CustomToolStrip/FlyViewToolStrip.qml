import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.FlightDisplay
import QGroundControl.ScreenTools

Rectangle {
    id: _root
    color:  qgcPal.toolbarBackground
    radius: ScreenTools.defaultFontPixelWidth / 2

    // Properties expected by FlyViewWidgetLayer
    property real maxHeight: parent.height

        signal displayPreFlightChecklist

    FlyViewToolStripActionList {
        id: flyViewToolStripActionList
        onDisplayPreFlightChecklist: _root.displayPreFlightChecklist()
    }

    property var model: flyViewToolStripActionList.model

    QGCPalette { id: qgcPal }

    // Calculate dimensions based on content
    width:  column.width + (ScreenTools.defaultFontPixelWidth * 2)
    height: Math.min(maxHeight, column.height + (ScreenTools.defaultFontPixelWidth * 2))

    QGCFlickable {
        id:             flickable
        anchors.fill:   parent
        anchors.margins: ScreenTools.defaultFontPixelWidth
        contentHeight:  column.height
        contentWidth:   column.width
        clip:           true

        ColumnLayout {
            id:         column
            spacing:    ScreenTools.defaultFontPixelWidth

            Repeater {
                model: _root.model
                delegate: QGCButton {
                    id:         button

                    // Access the ToolStripAction object from the model
                    property var actionItem: modelData

                    Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 3
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 3

                    text:       actionItem.text
                    iconSource: actionItem.iconSource
                    visible:    actionItem.visible
                    enabled:    actionItem.enabled
                    checkable:  actionItem.checkable
                    checked:    actionItem.checked

                    // --- Custom Color Logic ---
                    // Check if the actionItem has the 'customButtonColor' property we defined
                    property color customColor: {
                        if (actionItem && actionItem.customButtonColor !== undefined) {
                            return actionItem.customButtonColor
                        }
                        // Default QGC behavior
                        return button.checked ? qgcPal.buttonHighlightText : qgcPal.buttonText
                    }

                    textColor: customColor
                    // --------------------------

                    onClicked: {
                        if (actionItem.dropPanelComponent) {
                            _root.showDropPanel(actionItem.dropPanelComponent, button)
                        } else {
                            actionItem.onTriggered()
                        }
                    }
                }
            }
        }
    }

    // Loader for Drop Panels (like File, Pattern, Center)
    Loader {
        id: dropPanelLoader
        active: false

        property var _targetButton

        onLoaded: {
            if (item) {
                // Position the panel to the right of the button
                var mapPos = _targetButton.mapToItem(_root.parent, 0, 0)
                item.x = _root.x + _root.width + ScreenTools.defaultFontPixelWidth
                item.y = mapPos.y

                // Keep it on screen vertically
                if (item.y + item.height > _root.parent.height) {
                    item.y = _root.parent.height - item.height - ScreenTools.defaultFontPixelWidth
                }

                // Connect dropped signal to hide panel
                if (item.hasOwnProperty("dropped")) {
                    item.dropped.connect(function(){ dropPanelLoader.active = false })
                }

                // Inject properties if needed (some panels expect 'dropPanel')
                if (item.hasOwnProperty("dropPanel")) {
                    item.dropPanel = dropPanelController
                }
            }
        }
    }

    // Controller object to mimic standard ToolStrip dropPanel behavior
    QtObject {
        id: dropPanelController
        function hide() {
            dropPanelLoader.active = false
        }
    }

    function showDropPanel(component, button) {
        if (dropPanelLoader.active && dropPanelLoader.sourceComponent === component) {
            dropPanelLoader.active = false
            return
        }
        dropPanelLoader._targetButton = button
        dropPanelLoader.sourceComponent = component
        dropPanelLoader.active = true
    }
}