import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

// import custom modules
import Custom.Widgets 1.0 
import Custom.QmlControls 1.0

// load toolbar via loader(or directly use CustomToolbarIndicator here)

Rectangle {
    id:     _root
    width:  parent.width
    height: ScreenTools.toolbarHeight
    color:  qgcPal.toolbarBackground

    // interface exposed to oudside and keep compatible with original
    function dropMainStatusIndicatorTool() {
        if (customIndicator.item && customIndicator.item.dropMainStatusIndicatorTool) {
            customIndicator.item.dropMainStatusIndicatorTool()
        }
    }

    QGCPalette { id: qgcPal }

    // black bottom line
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    // load custom toolbar content
    Loader {
        id:             customIndicator
        anchors.fill:   parent
        // use sourceComponent instead of source string path
        sourceComponent: indicatorComponent
    }

    Component {
        id: indicatorComponent
        CustomToolbarIndicator { }
    }
}