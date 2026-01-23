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

import QGroundControl.Controllers  // 添加这一行以导入QGCFileDialogController

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

        // 直接在Item中创建一个QGCFileDialogController实例
        QGCFileDialogController {
            id: fileDialogController
        }

        // 导入文件对话框
        QGCFileDialog {
            id: importFileDialog
            folder: QGroundControl.settingsManager.appSettings.missionSavePath
            title: qsTr("选择要导入的航线文件")
            nameFilters: ["Plan files (*.plan)", "Mission files (*.mission)", "All files (*)"]
            onAcceptedForLoad: {
                console.log("选择了导入文件: " + file);
                importFlightPath(file);
            }
            onRejected: {
                console.log("取消导入");
            }
        }

        // 文件对话框 - 导出
        QGCFileDialog {
            id: exportFileDialog
            folder: QGroundControl.settingsManager.appSettings.missionSavePath
            title: qsTr("导出航线到文件")
            nameFilters: ["Plan files (*.plan)", "Mission files (*.mission)", "All files (*)"]
            defaultSuffix: "plan"
            onAcceptedForSave: {
                console.log("选择了导出文件: " + file);
                if (flightPathList.currentIndex >= 0) {
                    exportFlightPath(flightPathList.currentIndex, file);
                } else {
                    console.log("没有选中的航线，无法导出");
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
            
            // 添加一个 MouseArea 来拦截点击外部区域以关闭界面，但不影响内部控件
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true  // 改为true，允许事件传播
                onClicked: {
                    // 只有点击在内容区域之外才关闭界面
                    if (!contentArea.contains(mapToItem(contentArea, mouseX, mouseY))) {
                        flightPathLibrary.visible = false;
                    }
                }
            }
        }

        // 白色内容区域
        Rectangle {
            id: contentArea
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.8, 800)  // 最大宽度800px，占父级80%
            height: Math.min(parent.height * 0.8, 600)  // 最大高度600px，占父级80%
            color: qgcPal.window  // 使用具体颜色值
            radius: 10
            border.color: qgcPal.windowText  // 使用具体颜色值
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
                        color: qgcPal.text // 使用具体颜色值
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
                            console.log("【DEBUG】导出按钮被点击");
                            console.log("【DEBUG】当前currentIndex: " + flightPathList.currentIndex);
                            
                            if (flightPathList.currentIndex >= 0) {
                                var selectedFlightPath = flightPathModel.get(flightPathList.currentIndex);
                                console.log("准备导出航线: " + selectedFlightPath.name);
                                
                                // 设置默认文件名
                                exportFileDialog.defaultSuffix = "plan";
                                exportFileDialog.folder = QGroundControl.settingsManager.appSettings.missionSavePath;
                                
                                // 设置导出对话框参数
                                exportFileDialog.defaultSuffix = "plan";
                                exportFileDialog.folder = QGroundControl.settingsManager.appSettings.missionSavePath;
                                                            
                                // 尝试设置默认文件名，如果支持的话
                                try {
                                    exportFileDialog.selectedName = selectedFlightPath.name + ".plan";
                                } catch (err) {
                                    console.log("设置默认文件名失败: " + err);
                                    // 即使设置默认文件名失败，也要继续打开对话框
                                }
                                
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

                    // 创建一个完全自定义的搜索框，绝对避免任何样式覆盖
                    Rectangle {
                        id: searchBoxContainer
                        Layout.fillWidth: true
                        height: ScreenTools.implicitTextFieldHeight + 8
                        color: "white"  // 强制白色背景
                        border.color: "black"  // 强制黑色边框，确保可见性
                        border.width: 2  // 明显的边框
                        radius: 4  // 固定圆角
                        
                        // 在矩形容器内放置TextInput以获得最大控制权
                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.margins: 8  // 内边距
                            text: ""  // 初始为空
                            font.pointSize: ScreenTools.defaultFontPointSize
                            font.family: ScreenTools.normalFontFamily
                            color: "black"  // 强制黑色文字
                            selectionColor: "#4a90e2"  // 选中文本颜色
                            selectedTextColor: "white"  // 选中的文字颜色
                            
                            // 当文本改变时触发搜索
                            onTextChanged: {
                                // 过滤航线列表
                                filterFlightPaths(text);
                            }
                        }
                        
                        // 手动实现占位符文本
                        Text {
                            id: placeholderText
                            text: qsTr("搜索航线...")
                            font.pointSize: ScreenTools.defaultFontPointSize
                            font.family: ScreenTools.normalFontFamily
                            color: "#555555"  // 深灰色占位符文字，确保可见
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchInput.length === 0  // 仅在输入框为空时显示
                            
                            // 鼠标点击占位符时聚焦到输入框
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    searchInput.forceActiveFocus();
                                }
                            }
                        }
                    }

                    QGCComboBox {
                        id: sortComboBox
                        model: [qsTr("按名称"), qsTr("按日期"), qsTr("按距离"), qsTr("按航点数")]
                        currentIndex: 0
                        onCurrentIndexChanged: {
                            // 在排序前重置选中状态，避免状态错乱
                            flightPathList.currentIndex = -1;
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
                    cacheBuffer: 0  // 禁用缓存以确保正确刷新

                    delegate: Rectangle {
                        id: listItem
                        width: ListView.view.width
                        height: 60
                        
                        // 保持统一的背景色，选中状态通过边框体现
                        color: qgcPalDelegate.window || "#ffffff"  // 总是使用窗口背景色
                        border.color: (index === flightPathList.currentIndex) ? "white" : "#AAAAAA"  // 选中时为白色边框，未选中时为浅灰色边框
                        border.width: (index === flightPathList.currentIndex) ? 3 : 1  // 选中时边框更粗，未选中时有细边框
                        radius: 5
                        
                        // 在delegate中也需要QGCPalette
                        QGCPalette { id: qgcPalDelegate; colorGroupEnabled: true }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            // 左侧信息区域 - 用于显示信息
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: parent.height

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    QGCLabel {
                                        text: name
                                        font.bold: true
                                        color: qgcPalDelegate.text
                                        Layout.fillWidth: true
                                    }

                                    QGCLabel {
                                        text: date
                                        color: qgcPalDelegate.text
                                        Layout.preferredWidth: 100
                                    }

                                    QGCLabel {
                                        text: distance
                                        color: qgcPalDelegate.text
                                        Layout.preferredWidth: 80
                                    }

                                    QGCLabel {
                                        text: qsTr("%1个航点").arg(waypoints)
                                        color: qgcPalDelegate.text
                                        Layout.preferredWidth: 80
                                    }
                                }

                                // 整个信息区域的QGCMouseArea - 用于选择航线
                                QGCMouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("【DEBUG】航线项被点击: " + name);
                                        console.log("【DEBUG】点击的索引: " + index);
                                        
                                        // 检查当前是否已经是选中状态
                                        if (flightPathList.currentIndex === index) {
                                            // 如果当前项已经是选中状态，则取消选中（设置为-1）
                                            flightPathList.currentIndex = -1;
                                            console.log("【DEBUG】取消选中航线项: " + name);
                                        } else {
                                            // 如果当前项不是选中状态，则选中它
                                            flightPathList.currentIndex = index;
                                            console.log("【DEBUG】设置currentIndex为: " + index);
                                        }
                                        
                                        // 强制触发更新以确保视觉状态同步
                                        flightPathList.forceLayout();
                                        
                                        console.log("【DEBUG】航线项选择完成，当前选中: " + flightPathList.currentIndex);
                                    }
                                    onEntered: {
                                        console.log("【DEBUG】鼠标进入航线项: " + name);
                                        // 只有当该项不是当前选中项时才改变颜色
                                        if (flightPathList && index !== flightPathList.currentIndex && listItem && qgcPalDelegate) {
                                            listItem.color = qgcPalDelegate.windowShade || "#e6e6e6";  // 使用窗口阴影色作为悬停效果
                                        }
                                    }
                                    onExited: {
                                        console.log("【DEBUG】鼠标离开航线项: " + name);
                                        if (listItem && qgcPalDelegate) {
                                            // 如果该项是选中项，则保持统一背景色；如果不是选中项，则恢复默认色
                                            if (flightPathList && index === flightPathList.currentIndex) {
                                                listItem.color = qgcPalDelegate.window || "#ffffff";  // 选中项也保持统一背景色
                                            } else {
                                                listItem.color = qgcPalDelegate.window || "#ffffff";  // 恢复默认背景色
                                            }
                                        }
                                    }
                                }
                            }

                            // 右侧按钮区域
                            Row {
                                spacing: 5

                                QGCButton {
                                    text: qsTr("加载")
                                    onClicked: {
                                        console.log("【DEBUG】加载按钮被点击 - 航线: " + name);
                                        console.log("【DEBUG】当前索引: " + index);
                                        
                                        // 选中当前项
                                        flightPathList.currentIndex = index;
                                        console.log("【DEBUG】设置flightPathList.currentIndex为: " + index);
                                        
                                        console.log("【DEBUG】调用loadFlightPath函数");
                                        loadFlightPath(index);
                                    }
                                }

                                QGCButton {
                                    text: qsTr("编辑")
                                    onClicked: {
                                        console.log("【DEBUG】编辑按钮被点击 - 航线: " + name);
                                        console.log("【DEBUG】当前索引: " + index);
                                        
                                        // 选中当前项
                                        flightPathList.currentIndex = index;
                                        console.log("【DEBUG】设置flightPathList.currentIndex为: " + index);
                                        
                                        console.log("【DEBUG】调用editFlightPath函数");
                                        editFlightPath(index);
                                    }
                                }

                                QGCButton {
                                    text: qsTr("删除")
                                    onClicked: {
                                        console.log("【DEBUG】删除按钮被点击 - 航线: " + name);
                                        console.log("【DEBUG】当前索引: " + index);
                                        
                                        // 选中当前项
                                        flightPathList.currentIndex = index;
                                        console.log("【DEBUG】设置flightPathList.currentIndex为: " + index);
                                        
                                        console.log("【DEBUG】调用deleteFlightPath函数");
                                        deleteFlightPath(index);
                                    }
                                }
                            }
                        }
                    }  // 这里结束 delegate: Rectangle

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }
                }  // 这里结束 ListView

                // 底部状态栏
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    QGCLabel {
                        id: statusLabel
                        text: qsTr("共 %1 条航线").arg(filteredFlightPathModel.count)
                        color: qgcPal.text  // 使用具体颜色值
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
            // 示例数据 - 现在移除测试航线，只从文件系统加载实际航线
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
            "waypoints": 0,
            "filePath": ""  // 新建的航线没有文件路径
        });
        updateFilteredModel();
    }

    function editFlightPath(index) {
        // 编辑航线的逻辑
        console.log("编辑航线: " + flightPathModel.get(index).name);
        // 这里可以打开一个编辑对话框或跳转到编辑页面
        // 暂时先提示用户
        console.log("编辑航线功能待实现: " + flightPathModel.get(index).name);
    }

    function loadFlightPath(index) {
        // 加载航线到地图的逻辑
        var flightPath = flightPathModel.get(index);
        console.log("加载航线到地图: " + flightPath.name);
        
        // 检查是否有文件路径
        if (!flightPath.filePath || flightPath.filePath === "") {
            console.log("航线没有关联的文件路径，无法加载");
            return;
        }
        
        // 尝试跳转到计划视图并加载航线
        if (mainWindow.allowViewSwitch()) {
            // 通知主窗口切换到计划视图
            mainWindow.showPlanView();
            rightPanelOpen = false;  // 关闭面板
            
            console.log("已切换到计划视图，将尝试加载文件: " + flightPath.filePath);
            
            // 使用QML的Timer来延迟执行
            var timer = Qt.createQmlObject("import QtQuick 2.0; Timer {}", flightPathLibrary, "loadTimer");
            timer.interval = 1500;  // 1.5秒延迟
            timer.repeat = false;
            timer.triggered.connect(function() {
                // 尝试触发QGC的内置文件加载功能
                // 通过QGC的PlanView来打开指定的.plan文件
                
                // 由于我们无法直接访问PlanView中的控制器，
                // 我们尝试使用QGC的全局API来触发文件加载
                
                // 1. 检查文件是否存在
                if (fileDialogController.fileExists(flightPath.filePath)) {
                    console.log("文件存在，尝试加载: " + flightPath.filePath);
                    
                    // 2. 尝试通过QGC的全局对象触发文件加载
                    // 这要访问PlanMasterController的实例
                    try {
                        // 尝试通过QGroundControl全局对象访问PlanMasterController
                        // 虽然我们无法直接访问，但我们可以尝试使用QGC的内置方法
                        console.log("正在尝试通过QGC API加载文件: " + flightPath.filePath);
                        
                        // 如果QGC有全局的文件加载方法
                        if (typeof QGroundControl.corePlugin.loadPlanFromFile === 'function') {
                            QGroundControl.corePlugin.loadPlanFromFile(flightPath.filePath);
                            console.log("已调用QGroundControl.corePlugin.loadPlanFromFile");
                        } else {
                            console.log("QGroundControl.corePlugin.loadPlanFromFile方法不可用");
                            
                            // 尝试另一种方式：使用QGC的菜单命令
                            // 通过模拟QGC的菜单操作来加载文件
                            console.log("文件已就绪，用户可在计划视图中手动加载: " + flightPath.filePath);
                            
                            // 在PlanView中，通常有"打开"菜单项，我们可以尝试触发它
                            // 但首先需要将文件路径存储在一个全局位置
                            QGroundControl.pendingLoadFile = flightPath.filePath;
                            console.log("已设置待加载文件路径: " + flightPath.filePath);
                        }
                    } catch (e) {
                        console.log("加载过程中发生错误: " + e.message);
                        console.log("错误堆栈: ", e);
                        
                        // 如果上述方法失败，至少通知用户要加载的文件路径
                        console.log("请在计划视图中手动加载文件: " + flightPath.filePath);
                    }
                } else {
                    console.log("文件不存在: " + flightPath.filePath);
                }
                
                // 销毁定时器对象
                timer.destroy();
            });
            
            // 启动定时器
            timer.start();
        }
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
        // 获取文件名（不含扩展名）
        var fileName = filePath.split('\\').pop().split('/').pop();
        var nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");
        // 添加一个新航线到模型，包含文件路径信息
        flightPathModel.append({
            "name": nameWithoutExt,
            "date": new Date().toISOString().split('T')[0],
            "distance": "未知",
            "waypoints": 0,
            "filePath": filePath  // 添加文件路径信息
        });
        updateFilteredModel();
        console.log("成功导入航线: " + nameWithoutExt);
    }

    function exportFlightPath(index, filePath) {
        // 导出航线文件的逻辑
        console.log("开始导出航线: " + flightPathModel.get(index).name + " 到 " + filePath);
        
        try {
            // 获取选中的航线数据
            var flightPath = flightPathModel.get(index);
            console.log("导出的航线信息: ", flightPath);
            
            // 尝试使用QGC的PlanMasterController来保存文件
            try {
                // 检查是否可以从MainWindow或其他地方获取PlanMasterController
                if (typeof mainWindow !== 'undefined' && mainWindow) {
                    // 尝试创建临时的PlanMasterController并保存任务
                    var tempController = Qt.createQmlObject(
                        'import QGroundControl.Controllers 1.0; PlanMasterController {}',
                        flightPathLibrary,
                        'tempPlanController'
                    );
                    
                    if (tempController) {
                        console.log("临时PlanMasterController创建成功，尝试保存到: " + filePath);
                        tempController.start(); // 启动控制器
                        
                        // 使用PlanMasterController的saveToFile方法，这是QGC标准的保存方法
                        tempController.saveToFile(filePath);
                        
                        // 销毁临时控制器
                        tempController.destroy();
                        
                        console.log("航线文件导出成功: " + filePath);
                        
                        // 显示成功消息
                        if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                            mainWindow.showMessageDialog(
                                qsTr("导出成功"),
                                qsTr("航线已成功导出到: %1").arg(filePath)
                            );
                        }
                    } else {
                        console.log("无法创建临时PlanMasterController");
                        
                        // 备选方案：构造一个基本的.plan文件内容
                        var planContent = {
                            "version": 1,
                            "type": "Plan",
                            "mavC27Config": {},
                            "firmwareType": 3,
                            "geoFence": {},
                            "mission": {
                                "cruiseSpeed": -1,
                                "hoverSpeed": 5,
                                "items": [],
                                "vehicleType": 2,
                                "missionItems": []
                            },
                            "rallyPoints": {
                                "items": []
                            },
                            "complexItems": {}
                        };
                        
                        var jsonString = JSON.stringify(planContent, null, 4);
                        var success = fileDialogController.writeFile(filePath, jsonString);
                        if (success) {
                            console.log("基本航线文件导出成功: " + filePath);
                            if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                                mainWindow.showMessageDialog(
                                    qsTr("导出成功"),
                                    qsTr("航线已成功导出到: %1 (空任务文件)").arg(filePath)
                                );
                            }
                        } else {
                            console.log("基本航线文件导出失败");
                            
                            // 最后的备选：使用QGC的全局方法
                            console.log("无法导出文件，建议使用QGC内置的保存功能");
                            
                            if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                                mainWindow.showMessageDialog(
                                    qsTr("导出失败"),
                                    qsTr("无法导出航线到文件: %1\n请在计划视图中使用保存功能").arg(filePath)
                                );
                            }
                        }
                    }
                } else {
                    console.log("mainWindow不可用，使用备选方法");
                    
                    // 构造基本的.plan文件内容
                    var planContent = {
                        "version": 1,
                        "type": "Plan",
                        "mavC27Config": {},
                        "firmwareType": 3,
                        "geoFence": {},
                        "mission": {
                            "cruiseSpeed": -1,
                            "hoverSpeed": 5,
                            "items": [],
                            "vehicleType": 2,
                            "missionItems": []
                        },
                        "rallyPoints": {
                            "items": []
                        },
                        "complexItems": {}
                    };
                    
                    var jsonString = JSON.stringify(planContent, null, 4);
                    var success = fileDialogController.writeFile(filePath, jsonString);
                    if (success) {
                        console.log("基本航线文件导出成功: " + filePath);
                    } else {
                        console.log("基本航线文件导出也失败");
                    }
                }
            } catch (planErr) {
                console.log("使用PlanMasterController保存失败: " + planErr.message);
                
                // 显示错误消息
                if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                    mainWindow.showMessageDialog(
                        qsTr("导出失败"),
                        qsTr("无法从当前任务获取数据，请确保已在计划视图中创建了任务").arg(filePath)
                    );
                }
            }
            
        } catch (e) {
            console.log("导出过程中发生错误: " + e.message);
            console.log("错误详情: ", e);
            
            // 显示错误消息
            if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                mainWindow.showMessageDialog(
                    qsTr("导出错误"),
                    qsTr("导出过程中发生错误: %1").arg(e.message)
                );
            }
        }
    }

    function loadFlightPathsFromStorage() {
        // 从存储加载航线的逻辑
        console.log("从存储加载航线 - 开始");
        
        // 使用QGC的文件系统API获取默认任务目录
        var missionDir = QGroundControl.settingsManager.appSettings.missionSavePath;
        console.log("扫描目录: " + missionDir);
        
        var planFiles = [];
        var missionFiles = [];
        
        console.log("检查fileDialogController是否可用...");
        console.log("fileDialogController: ", fileDialogController);
        console.log("typeof fileDialogController: ", typeof fileDialogController);
        
        if (fileDialogController) {
            console.log("fileDialogController存在，检查getFiles方法...");
            console.log("typeof fileDialogController.getFiles: ", typeof fileDialogController.getFiles);
            
            if (typeof fileDialogController.getFiles === 'function') {
                try {
                    // 使用fileDialogController的getFiles方法获取.plan文件
                    planFiles = fileDialogController.getFiles(missionDir, ["*.plan"]);
                    console.log("找到 " + planFiles.length + " 个.plan文件: ", planFiles);
                } catch (e) {
                    console.log("调用getFiles方法失败: " + e.message + " at " + e.lineNumber);
                    console.log("错误堆栈: ", e.stack);
                }
            } else {
                console.log("getFiles方法不存在于fileDialogController上");
            }
        } else {
            console.log("fileDialogController不可用");
        }
        
        // 保存现有的非文件航线（如用户创建的临时航线）
        var existingTempPaths = [];
        var filePathsInDir = {};
        
        // 构建文件路径映射，便于快速查找
        for (var i = 0; i < planFiles.length; i++) {
            filePathsInDir[missionDir + "/" + planFiles[i]] = true;
        }
        for (var j = 0; j < missionFiles.length; j++) {
            filePathsInDir[missionDir + "/" + missionFiles[j]] = true;
        }
        
        // 保存非文件相关的航线（即用户创建的临时航线）
        for (var k = flightPathModel.count - 1; k >= 0; k--) {
            var item = flightPathModel.get(k);
            if (!item.filePath || !filePathsInDir[item.filePath]) {
                // 这是一个临时航线或来自其他目录的航线，保存它
                existingTempPaths.push({
                    name: item.name,
                    date: item.date,
                    distance: item.distance,
                    waypoints: item.waypoints,
                    filePath: item.filePath
                });
                // 从模型中移除，稍后重新添加
                flightPathModel.remove(k);
            }
        }
        
        // 添加新发现的.plan文件到模型
        for (var i = 0; i < planFiles.length; i++) {
            var fileName = planFiles[i];
            var nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");  // 去掉擴展名
            
            // 检查是否已经存在于模型中
            var exists = false;
            for (var m = 0; m < flightPathModel.count; m++) {
                var existingItem = flightPathModel.get(m);
                if (existingItem.filePath === missionDir + "/" + fileName) {
                    exists = true;
                    break;
                }
            }
            
            if (!exists) {
                // 为每个文件添加条目到模型
                flightPathModel.append({
                    "name": nameWithoutExt,
                    "date": new Date().toISOString().split('T')[0],  // 实际应该从文件获取时间
                    "distance": "未知",
                    "waypoints": 0,
                    "filePath": missionDir + "/" + fileName  // 完整路径
                });
                
                console.log("添加.plan文件: " + fileName);
            }
        }
        
        // 对.mission文件做同样的处理
        if (fileDialogController && typeof fileDialogController.getFiles === 'function') {
            try {
                // 使用fileDialogController的getFiles方法获取.mission文件
                missionFiles = fileDialogController.getFiles(missionDir, ["*.mission"]);
                console.log("找到 " + missionFiles.length + " 个.mission文件: ", missionFiles);
            } catch (e) {
                console.log("调用getFiles方法获取mission文件失败: " + e.message + " at " + e.lineNumber);
                console.log("错误堆栈: ", e.stack);
            }
        }
        
        for (var j = 0; j < missionFiles.length; j++) {
            var fileName = missionFiles[j];
            var nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");  // 去掉擴展名
            
            // 检查是否已经存在于模型中
            var exists = false;
            for (var m = 0; m < flightPathModel.count; m++) {
                var existingItem = flightPathModel.get(m);
                if (existingItem.filePath === missionDir + "/" + fileName) {
                    exists = true;
                    break;
                }
            }
            
            if (!exists) {
                // 为每个文件添加条目到模型
                flightPathModel.append({
                    "name": nameWithoutExt,
                    "date": new Date().toISOString().split('T')[0],  // 实际应该从文件获取时间
                    "distance": "未知",
                    "waypoints": 0,
                    "filePath": missionDir + "/" + fileName  // 完整路径
                });
                
                console.log("添加.mission文件: " + fileName);
            }
        }
        
        // 重新添加之前保存的临时航线
        for (var n = 0; n < existingTempPaths.length; n++) {
            flightPathModel.append(existingTempPaths[n]);
        }
        
        // 更新過濾模型
        updateFilteredModel();
        
        // 在加载完数据后，确保currentIndex为-1，避免选中状态残留
        flightPathList.currentIndex = -1;
        
        console.log("完成扫描，当前模型总数: " + flightPathModel.count);
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
                // 将ListModel中的元素复制为普通JS对象再添加
                filteredFlightPathModel.append({
                    name: item.name,
                    date: item.date,
                    distance: item.distance,
                    waypoints: item.waypoints,
                    filePath: item.filePath
                });
            }
        }
        statusLabel.text = qsTr("共 %1 条航线").arg(filteredFlightPathModel.count);
    }

    function sortFlightPaths(sortIndex) {
        // 记录当前选中的项目（如果有的话），以便在排序后尝试恢复
        var currentSelectedItem = null;
        if (flightPathList.currentIndex >= 0 && flightPathList.currentIndex < filteredFlightPathModel.count) {
            var currentItem = filteredFlightPathModel.get(flightPathList.currentIndex);
            currentSelectedItem = {
                name: currentItem.name,
                date: currentItem.date,
                distance: currentItem.distance,
                waypoints: currentItem.waypoints,
                filePath: currentItem.filePath
            };
        }
        
        // 排序航线的逻辑
        console.log("排序航线，索引: " + sortIndex);
        
        // 获取当前过滤后的数据并排序
        var tempArray = [];
        for (let i = 0; i < filteredFlightPathModel.count; i++) {
            // 将ListModel中的元素复制为普通JS对象
            var item = filteredFlightPathModel.get(i);
            tempArray.push({
                name: item.name,
                date: item.date,
                distance: item.distance,
                waypoints: item.waypoints,
                filePath: item.filePath
            });
        }
        
        // 根据sortIndex进行排序
        switch(sortIndex) {
            case 0: // 按名称排序
                tempArray.sort(function(a, b) {
                    return a.name.localeCompare(b.name);
                });
                break;
            case 1: // 按日期排序
                tempArray.sort(function(a, b) {
                    return new Date(b.date) - new Date(a.date); // 新日期在前
                });
                break;
            case 2: // 按距离排序
                tempArray.sort(function(a, b) {
                    // 提取数字部分进行比较
                    var numA = parseFloat(a.distance);
                    var numB = parseFloat(b.distance);
                    if (isNaN(numA)) numA = Infinity;
                    if (isNaN(numB)) numB = Infinity;
                    return numB - numA; // 大距离在前
                });
                break;
            case 3: // 按航点数排序
                tempArray.sort(function(a, b) {
                    return b.waypoints - a.waypoints; // 多航点在前
                });
                break;
            default:
                // 不排序，保持原样
                break;
        }
        
        // 记录当前选中项在排序前的索引，然后清空并重新填充模型
        filteredFlightPathModel.clear();
        for (let i = 0; i < tempArray.length; i++) {
            filteredFlightPathModel.append(tempArray[i]);
        }
        
        // 尝试恢复选中状态到具有相同名称的项目
        if (currentSelectedItem) {
            for (let i = 0; i < filteredFlightPathModel.count; i++) {
                var item = filteredFlightPathModel.get(i);
                if (item.name === currentSelectedItem.name && 
                    item.date === currentSelectedItem.date &&
                    item.distance === currentSelectedItem.distance &&
                    item.waypoints === currentSelectedItem.waypoints &&
                    item.filePath === currentSelectedItem.filePath) {
                    flightPathList.currentIndex = i;
                    break;
                }
            }
        }
    }

    function updateFilteredModel() {
        // 更新过滤模型
        filterFlightPaths(searchInput.text);
        // 应用当前排序
        sortFlightPaths(sortComboBox.currentIndex);
    }
}