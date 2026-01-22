import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.ScreenTools

import QGroundControl.FlightDisplay
import QGroundControl.FlightMap

import Custom.Widgets

Item {
    property var parentToolInsets                       // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets: _totalToolInsets    // The insets updated for the custom overlay additions
    property var mapControl

    property bool rightPanelOpen: false

    readonly property string noGPS: qsTr("NO GPS")
    readonly property real   indicatorValueWidth: ScreenTools.defaultFontPixelWidth * 7

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property real   _indicatorDiameter: ScreenTools.defaultFontPixelWidth * 18
    property real   _indicatorsHeight: ScreenTools.defaultFontHeight
    property var    _sepColor: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(1, 1, 1, 0.5)
    property color  _indicatorsColor: qgcPal.text
    property bool   _isVehicleGps: _activeVehicle ? _activeVehicle.gps.count.rawValue > 1 && _activeVehicle.gps.hdop.rawValue < 1.4 : false
    property string _altitude: _activeVehicle ? (isNaN(_activeVehicle.altitudeRelative.value) ? "0.0" : _activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + _activeVehicle.altitudeRelative.units : "0.0"
    property string _distanceStr: isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property real   _heading: _activeVehicle ? _activeVehicle.heading.rawValue : 0
    property real   _distance: _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0
    property string _messageTitle: ""
    property string _messageText: ""
    property real   _toolsMargin: ScreenTools.defaultFontPixelWidth * 0.75

    function secondsToHHMMSS(timeS) {
        var sec_num = parseInt(timeS, 10);
        var hours = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours < 10) {
            hours = "0" + hours;
        }
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
        if (seconds < 10) {
            seconds = "0" + seconds;
        }
        return hours + ':' + minutes + ':' + seconds;
    }

    QGCToolInsets {
        id: _totalToolInsets
        leftEdgeTopInset: parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset: exampleRectangle.leftEdgeCenterInset
        leftEdgeBottomInset: parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset: parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset: parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset: parent.width - compassBackground.x
        topEdgeLeftInset: parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset: compassArrowIndicator.y + compassArrowIndicator.height
        topEdgeRightInset: parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset: parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset: parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset: parent.height - attitudeIndicator.y
    }

    // This is an example of how you can use parent tool insets to position an element on the custom fly view layer
    // - we use parent topEdgeLeftInset to position the widget below the toolstrip
    // - we use parent bottomEdgeLeftInset to dodge the virtual joystick if enabled
    // - we use the parent leftEdgeTopInset to size our element to the same width as the ToolStripAction
    // - we export the width of this element as the leftEdgeCenterInset so that the map will recenter if the vehicle flys behind this element
    Rectangle {
        id: exampleRectangle
        visible: false // to see this example, set this to true. To view insets, enable the insets viewer FlyView.qml
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: parentToolInsets.topEdgeLeftInset + _toolsMargin
        anchors.bottomMargin: parentToolInsets.bottomEdgeLeftInset + _toolsMargin
        anchors.leftMargin: _toolsMargin
        width: parentToolInsets.leftEdgeTopInset - _toolsMargin
        color: 'red'

        property real leftEdgeCenterInset: visible ? x + width : 0
    }

    //-------------------------------------------------------------------------
    //-- Heading Indicator
    Rectangle {
        id: compassBar
        height: ScreenTools.defaultFontPixelHeight * 1.5
        width: ScreenTools.defaultFontPixelWidth * 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: _toolsMargin
        color: "#DEDEDE"
        radius: 2
        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: 720
            QGCLabel {
                function _normalize(degrees) {
                    var a = degrees % 360
                    if (a < 0) a += 360
                    return a
                }

                property int _startAngle: modelData + 180 + _heading
                property int _angle: _normalize(_startAngle)
                anchors.verticalCenter: parent.verticalCenter
                x: visible ? ((modelData * (compassBar.width / 360)) - (width * 0.5)) : 0
                visible: _angle % 45 == 0
                color: "#75505565"
                font.pointSize: ScreenTools.smallFontPointSize
                text: {
                    switch (_angle) {
                        case 0:
                            return "N"
                        case 45:
                            return "NE"
                        case 90:
                            return "E"
                        case 135:
                            return "SE"
                        case 180:
                            return "S"
                        case 225:
                            return "SW"
                        case 270:
                            return "W"
                        case 315:
                            return "NW"
                    }
                    return ""
                }
            }
        }
    }
    Rectangle {
        id: headingIndicator
        height: ScreenTools.defaultFontPixelHeight
        width: ScreenTools.defaultFontPixelWidth * 4
        color: qgcPal.windowShadeDark
        anchors.top: compassBar.top
        anchors.topMargin: -headingIndicator.height / 2
        anchors.horizontalCenter: parent.horizontalCenter
        QGCLabel {
            text: _heading
            color: qgcPal.text
            font.pointSize: ScreenTools.smallFontPointSize
            anchors.centerIn: parent
        }
    }
    Image {
        id: compassArrowIndicator
        height: _indicatorsHeight
        width: height
        source:                     "/custom/img/compass_pointer.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize.height: height
        anchors.top: compassBar.bottom
        anchors.topMargin: -height / 2
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: compassBackground
        anchors.bottom: attitudeIndicator.bottom
        anchors.right: attitudeIndicator.left
        anchors.rightMargin: -attitudeIndicator.width / 2
        width: -anchors.rightMargin + compassBezel.width + (_toolsMargin * 2)
        height: attitudeIndicator.height * 0.75
        radius: 2
        color: qgcPal.window

        Rectangle {
            id: compassBezel
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: _toolsMargin
            anchors.left: parent.left
            width: height
            height: parent.height - (northLabelBackground.height / 2) - (headingLabelBackground.height / 2)
            radius: height / 2
            border.color: qgcPal.text
            border.width: 1
            color: Qt.rgba(0, 0, 0, 0)
        }

        Rectangle {
            id: northLabelBackground
            anchors.top: compassBezel.top
            anchors.topMargin: -height / 2
            anchors.horizontalCenter: compassBezel.horizontalCenter
            width: northLabel.contentWidth * 1.5
            height: northLabel.contentHeight * 1.5
            radius: ScreenTools.defaultFontPixelWidth * 0.25
            color: qgcPal.windowShade

            QGCLabel {
                id: northLabel
                anchors.centerIn: parent
                text: "N"
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }

        Image {
            id: headingNeedle
            anchors.centerIn: compassBezel
            height: compassBezel.height * 0.75
            width: height
            source:             "/custom/img/compass_needle.svg"
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
            transform: [
                Rotation {
                    origin.x: headingNeedle.width / 2
                    origin.y: headingNeedle.height / 2
                    angle: _heading
                }]
        }

        Rectangle {
            id: headingLabelBackground
            anchors.top: compassBezel.bottom
            anchors.topMargin: -height / 2
            anchors.horizontalCenter: compassBezel.horizontalCenter
            width: headingLabel.contentWidth * 1.5
            height: headingLabel.contentHeight * 1.5
            radius: ScreenTools.defaultFontPixelWidth * 0.25
            color: qgcPal.windowShade

            QGCLabel {
                id: headingLabel
                anchors.centerIn: parent
                text: _heading
                color: qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
    }

    Rectangle {
        id: attitudeIndicator
        anchors.bottomMargin: _toolsMargin + parentToolInsets.bottomEdgeRightInset
        anchors.rightMargin: _toolsMargin
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: ScreenTools.defaultFontPixelHeight * 6
        width: height
        radius: height * 0.5
        color: qgcPal.windowShade

        CustomAttitudeWidget {
            size: parent.height * 0.95
            vehicle: _activeVehicle
            showHeading: false
            anchors.centerIn: parent
        }
    }

    Rectangle {
        id: rightTaskPanel
        z: 100
        width: 120
        height: parent.height
        color: "#202020"

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: rightPanelOpen ? 0 : -width  // 改成 rightMargin 来控制滑动

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 250
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: "任务 / 设置"
                color: "white"
                font.pixelSize: 18
            }

            Button {
                text: "任务规划"
                onClicked: {
                    // 跳转到任务规划视图
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.showPlanView()
                        rightPanelOpen = false  // 关闭面板
                    }
                }
            }

            Button {
                text: "航线库"
                onClicked: {
                    // 显示航线库界面
                    console.log("航线库按钮被点击");
                    console.log("设置 flightPathLibrary.visible 为 true");
                    flightPathLibrary.visible = true;
                    console.log("当前 flightPathLibrary.visible 状态: " + flightPathLibrary.visible);
                    console.log("当前 flightPathLibrary.source: " + flightPathLibrary.source);
                    rightPanelOpen = false;  // 关闭面板
                    // 尝试确保覆盖层在最前面
                    flightPathLibrary.z = 1000;
                }
            }

            Button {
                text: "设备状态"
                onClicked: {
                    // 打开设备配置页面
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.showVehicleConfig()
                        rightPanelOpen = false
                    }
                }
            }

            Button {
                text: "媒体库"
                onClicked: {
                    // 可以复用QGCMediaBrowser组件
                    console.log("媒体库功能待实现")
                }
            }

            Button {
                text: "设置"
                onClicked: {
                    // 跳转到应用设置
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.showSettingsTool()
                        rightPanelOpen = false
                    }
                }
            }
        }
    }

    Rectangle {
        id: toggleButton
        z: 200  // 确保它在面板上面
        width: 28
        height: 80
        radius: 4
        color: "#2c2c2c"

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.centerIn: parent
            text: rightPanelOpen ? ">" : "<"
            color: "white"
            font.pixelSize: 16
        }

        MouseArea {
            anchors.fill: parent
            onClicked: rightPanelOpen = !rightPanelOpen
        }
    }

    // 航线库覆盖层 - 直接内联定义，包含完整功能
    Item {
        id: flightPathLibrary
        z: 1000  // 确保覆盖层在最顶层
        anchors.fill: parent
        visible: false  // 控制显示/隐藏

        // 导入文件对话框
        QGCFileDialog {
            id: importFileDialog
            folder: QGroundControl.settingsManager.appSettings.missionSavePath
            title: qsTr("选择要导入的航线文件")
            nameFilters: ["Mission files (*.mission)", "All files (*)"]
            onAcceptedForLoad: {
                console.log("选择了导入文件: " + file);
                importFlightPath(file);
            }
            onRejected: {
                console.log("取消导入");
            }
        }

        // 导出文件对话框
        QGCFileDialog {
            id: exportFileDialog
            folder: QGroundControl.settingsManager.appSettings.missionSavePath
            title: qsTr("导出航线到文件")
            nameFilters: ["Mission files (*.mission)", "All files (*)"]
            onAcceptedForSave: {
                console.log("选择了导出文件: " + file);
                if (flightPathList.currentIndex >= 0) {
                    exportFlightPath(flightPathList.currentIndex, file);
                }
            }
            onRejected: {
                console.log("取消导出");
            }
        }

        // 半透明背景
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"  // 半透明黑色背景
            
            // 添加一个 MouseArea 来拦截所有点击事件，防止事件穿透
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
                onPressed: mouse.accepted = true
                onReleased: mouse.accepted = true
                onClicked: mouse.accepted = true
                onDoubleClicked: mouse.accepted = true
                onPositionChanged: mouse.accepted = true
            }
        }

        // 白色内容区域
        Rectangle {
            id: contentArea
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.8, 800)  // 最大宽度800px，占父级80%
            height: Math.min(parent.height * 0.8, 600)  // 最大高度600px，占父级80%
            color: qgcPal.window
            radius: 10
            border.color: qgcPal.windowText
            border.width: 1

            QGCPalette { id: qgcPal }

            // 主布局
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                // 标题栏
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QGCLabel {
                        text: qsTr("航线库")
                        font.pixelSize: 20
                        color: qgcPal.text
                    }

                    Item { Layout.fillWidth: true }

                    QGCButton {
                        text: qsTr("导入")
                        onClicked: {
                            // 导入航线文件
                            console.log("准备导入航线文件");
                            importFileDialog.openForLoad();
                        }
                    }

                    QGCButton {
                        text: qsTr("导出")
                        onClicked: {
                            // 导出选中的航线
                            if (flightPathList.currentIndex >= 0) {
                                console.log("准备导出航线: " + flightPathModel.get(flightPathList.currentIndex).name);
                                exportFileDialog.openForSave();
                            } else {
                                console.log("请先选择要导出的航线");
                            }
                        }
                    }

                    QGCButton {
                        text: qsTr("新建")
                        onClicked: {
                            // 创建新航线
                            console.log("准备创建新航线");
                            createNewFlightPath();
                        }
                    }

                    QGCButton {
                        text: qsTr("关闭")
                        onClicked: {
                            // 隐藏航线库界面
                            flightPathLibrary.visible = false;
                        }
                    }
                }

                // 搜索栏
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QGCTextField {
                        id: searchField
                        placeholderText: qsTr("搜索航线...")
                        Layout.fillWidth: true
                        onTextChanged: {
                            // 过滤航线列表
                            filterFlightPaths(text);
                        }
                    }

                    QGCComboBox {
                        id: sortComboBox
                        model: [qsTr("按名称"), qsTr("按日期"), qsTr("按距离"), qsTr("按航点数")]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            sortFlightPaths(currentIndex);
                        }
                    }
                }

                // 航线列表
                ListView {
                    id: flightPathList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: filteredFlightPathModel  // 使用过滤后的模型
                    clip: true
                    currentIndex: -1  // 默认不选择任何项

                    delegate: Rectangle {
                        id: listItem
                        width: ListView.view.width
                        height: 60
                        color: (index === ListView.view.currentIndex) ? qgcPal.highlight : (index % 2 ? qgcPal.window : qgcPal.windowShade)
                        border.color: (index === ListView.view.currentIndex) ? qgcPal.highlight : qgcPal.windowText
                        border.width: (index === ListView.view.currentIndex) ? 2 : 1
                        radius: 5

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            QGCLabel {
                                text: name
                                font.bold: true
                                color: qgcPal.text
                                Layout.fillWidth: true
                            }

                            QGCLabel {
                                text: date
                                color: qgcPal.text
                                Layout.preferredWidth: 100
                            }

                            QGCLabel {
                                text: distance
                                color: qgcPal.text
                                Layout.preferredWidth: 80
                            }

                            QGCLabel {
                                text: qsTr("%1个航点").arg(waypoints)
                                color: qgcPal.text
                                Layout.preferredWidth: 80
                            }

                            Row {
                                spacing: 5

                                QGCButton {
                                    text: qsTr("加载")
                                    onClicked: {
                                        console.log("加载航线: " + name);
                                        ListView.view.currentIndex = index;
                                        loadFlightPath(index);
                                    }
                                }

                                QGCButton {
                                    text: qsTr("编辑")
                                    onClicked: {
                                        console.log("编辑航线: " + name);
                                        ListView.view.currentIndex = index;
                                        editFlightPath(index);
                                    }
                                }

                                QGCButton {
                                    text: qsTr("删除")
                                    onClicked: {
                                        console.log("删除航线: " + name);
                                        ListView.view.currentIndex = index;
                                        flightPathModel.remove(index);
                                        updateFilteredModel();
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                ListView.view.currentIndex = index;
                            }
                            onEntered: {
                                if (index !== ListView.view.currentIndex) {
                                    parent.color = qgcPal.highlight;
                                }
                            }
                            onExited: {
                                if (index !== ListView.view.currentIndex) {
                                    parent.color = index % 2 ? qgcPal.window : qgcPal.windowShade;
                                } else {
                                    parent.color = qgcPal.highlight;
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }
                }

                // 底部状态栏
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QGCLabel {
                        id: statusLabel
                        text: qsTr("共 %1 条航线").arg(filteredFlightPathModel.count)
                        color: qgcPal.text
                    }

                    Item { Layout.fillWidth: true }

                    QGCButton {
                        text: qsTr("刷新")
                        onClicked: {
                            // 刷新航线列表
                            console.log("刷新航线列表");
                            loadFlightPathsFromStorage();
                        }
                    }
                }
            }
        }

        // 数据模型
        ListModel {
            id: flightPathModel
            // 示例数据 - 实际应用中应从文件加载
            ListElement {
                name: "测试航线1"
                date: "2024-01-15"
                distance: "15.2 km"
                waypoints: 8
            }
            ListElement {
                name: "测试航线2"
                date: "2024-01-10"
                distance: "8.7 km"
                waypoints: 5
            }
            ListElement {
                name: "测试航线3"
                date: "2024-01-05"
                distance: "22.3 km"
                waypoints: 12
            }
        }

        // 过滤后的航线模型
        ListModel {
            id: filteredFlightPathModel
        }
    }

    // JavaScript 函数实现实际功能
    function createNewFlightPath() {
        // 创建新航线的逻辑
        console.log("创建新航线功能");
        // 添加一个新航线到模型
        flightPathModel.append({
            "name": "新航线_" + (flightPathModel.count + 1),
            "date": new Date().toISOString().split('T')[0],
            "distance": "未知",
            "waypoints": 0
        });
        updateFilteredModel();
    }

    function editFlightPath(index) {
        // 编辑航线的逻辑
        console.log("编辑航线: " + flightPathModel.get(index).name);
        // 例如，可以弹出一个编辑对话框
    }

    function loadFlightPath(index) {
        // 加载航线到地图的逻辑
        console.log("加载航线到地图: " + flightPathModel.get(index).name);
        // 这里可以调用QGC的航线加载功能
    }

    function deleteFlightPath(index) {
        // 删除航线的逻辑
        console.log("删除航线: " + flightPathModel.get(index).name);
        flightPathModel.remove(index);
        updateFilteredModel();
    }

    function importFlightPath(filePath) {
        // 导入航线文件的逻辑
        console.log("导入航线文件: " + filePath);
        // 示例添加一个新航线
        flightPathModel.append({
            "name": "导入的航线_" + Date.now(),
            "date": new Date().toISOString().split('T')[0],
            "distance": "未知",
            "waypoints": 0
        });
        updateFilteredModel();
    }

    function exportFlightPath(index, filePath) {
        // 导出航线文件的逻辑
        console.log("导出航线: " + flightPathModel.get(index).name + " 到 " + filePath);
        // 这里需要将航线数据写入文件
    }

    function loadFlightPathsFromStorage() {
        // 从存储加载航线的逻辑
        console.log("从存储加载航线");
        // 这里可以从本地存储或其他位置加载航线数据
        updateFilteredModel();
    }

    function filterFlightPaths(filterText) {
        // 过滤航线的逻辑
        console.log("过滤航线: " + filterText);
        filteredFlightPathModel.clear();
        for (let i = 0; i < flightPathModel.count; i++) {
            let item = flightPathModel.get(i);
            if (filterText === "" || 
                item.name.toLowerCase().includes(filterText.toLowerCase()) ||
                item.date.toLowerCase().includes(filterText.toLowerCase()) ||
                item.distance.toLowerCase().includes(filterText.toLowerCase())) {
                filteredFlightPathModel.append(item);
            }
        }
        statusLabel.text = qsTr("共 %1 条航线").arg(filteredFlightPathModel.count);
    }

    function sortFlightPaths(sortIndex) {
        // 排序航线的逻辑
        console.log("排序航线，索引: " + sortIndex);
        // 这里可以实现实际的排序算法
        updateFilteredModel();
    }

    function updateFilteredModel() {
        // 更新过滤模型
        filterFlightPaths(searchField.text);
    }
}