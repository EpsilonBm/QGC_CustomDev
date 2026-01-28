/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * @file
 *   @author Gus Grubba <gus@auterion.com>
 */

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
import QGroundControl.FlightMap

import QGroundControl.FlightDisplay
import QGroundControl.FlightMap

import QGroundControl.Controllers  // 添加这一行以导入QGCFileDialogController

import Custom.FlyView 1.0
import Custom.Widgets

Item {
    id: _root
    property var parentToolInsets                       // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets: _totalToolInsets    // The insets updated for the custom overlay additions
    property var mapControl

    property bool rightPanelOpen: false

    readonly property string noGPS: qsTr("NO GPS")
    readonly property real   indicatorValueWidth: ScreenTools.defaultFontPixelWidth * 7

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   _indicatorDiameter:     ScreenTools.defaultFontPixelWidth * 18
    property real   _indicatorsHeight:      ScreenTools.defaultFontPixelHeight
    property var    _sepColor:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0,0,0,0.5) : Qt.rgba(1,1,1,0.5)
    property color  _indicatorsColor:       qgcPal.text
    property bool   _isVehicleGps:          _activeVehicle ? _activeVehicle.gps.count.rawValue > 1 && _activeVehicle.gps.hdop.rawValue < 1.4 : false
    property string _altitude:              _activeVehicle ? (isNaN(_activeVehicle.altitudeRelative.value) ? "0.0" : _activeVehicle.altitudeRelative.value.toFixed(1)) + ' ' + _activeVehicle.altitudeRelative.units : "0.0"
    property string _distanceStr:           isNaN(_distance) ? "0" : _distance.toFixed(0) + ' ' + QGroundControl.unitsConversion.appSettingsHorizontalDistanceUnitsString
    property real   _heading:               _activeVehicle   ? _activeVehicle.heading.rawValue : 0
    property real   _distance:              _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0
    property string _messageTitle:          ""
    property string _messageText:           ""
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75

    function secondsToHHMMSS(timeS) {
        var sec_num = parseInt(timeS, 10);
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);
        if (hours   < 10) {hours   = "0"+hours;}
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return hours+':'+minutes+':'+seconds;
    }

    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeTopInset:       parentToolInsets.leftEdgeTopInset
        leftEdgeCenterInset:    exampleRectangle.leftEdgeCenterInset
        leftEdgeBottomInset:    parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      parentToolInsets.rightEdgeTopInset
        rightEdgeCenterInset:   parentToolInsets.rightEdgeCenterInset
        rightEdgeBottomInset:   parentToolInsets.rightEdgeBottomInset
        topEdgeLeftInset:       parentToolInsets.topEdgeLeftInset
        topEdgeCenterInset:     parentToolInsets.topEdgeCenterInset
        topEdgeRightInset:      parentToolInsets.topEdgeRightInset
        bottomEdgeLeftInset:    parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  parentToolInsets.bottomEdgeCenterInset
        bottomEdgeRightInset:   parentToolInsets.bottomEdgeRightInset
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

    // TODO: To see how its size adapted to the screen especially in Android
    CustomPanel {
        id:                        customPanel
        anchors.bottom:            parent.bottom
        anchors.horizontalCenter:  parent.horizontalCenter
        parentToolInsets:          _root.parentToolInsets
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
        var flightPath = flightPathModel.get(index);
        console.log("加载航线到地图: " + flightPath.name);

        if (!flightPath.filePath || flightPath.filePath === "") {
            console.log("航线没有关联的文件路径，无法加载");
            return;
        }

        if (mainWindow.allowViewSwitch()) {
            // 将文件路径存储到全局对象
            QGroundControl.planFilePathToLoad = flightPath.filePath;

            // 切换到计划视图
            mainWindow.showPlanView();
            rightPanelOpen = false;

            console.log("已设置全局文件路径: " + flightPath.filePath);

            // 关闭航线库界面，返回到计划视图
            flightPathLibrary.visible = false;
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

        // 解析任务信息
        var missionInfo = parseMissionInfo(filePath);

        // 添加一个新航线到模型，包含文件路径信息
        flightPathModel.append({
            "name": nameWithoutExt,
            "date": new Date().toISOString().split('T')[0],
            "distance": missionInfo.isValid ? formatDistance(missionInfo.totalDistance) : "未知",
            "waypoints": missionInfo.isValid ? missionInfo.waypointCount : 0,
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

        // 检查目录是否存在
        if (!missionDir || missionDir === "") {
            console.log("任务保存路径未设置或为空");
            return;
        }

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
                    console.log("调用getFiles方法获取plan文件失败: " + e.message + " at " + e.lineNumber);
                    console.log("错误堆栈: ", e.stack);
                }
            } else {
                console.log("getFiles方法不存在于fileDialogController上，尝试其他方法");

                // 尝试使用QDir方式
                try {
                    // 作为后备方案，手动构建文件列表
                    console.log("使用备用方案加载.plan文件");
                    // 这里我们可以尝试其他方式，但目前依赖fileDialogController
                } catch (backupError) {
                    console.log("备用方案也失败: " + backupError.message);
                }
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
                // 解析任务信息
                var missionInfo = parseMissionInfo(missionDir + "/" + fileName);

                // 为每个文件添加条目到模型
                flightPathModel.append({
                    "name": nameWithoutExt,
                    "date": new Date().toISOString().split('T')[0],  // 实际应该从文件获取时间
                    "distance": missionInfo.isValid ? formatDistance(missionInfo.totalDistance) : "未知",
                    "waypoints": missionInfo.isValid ? missionInfo.waypointCount : 0,
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
                // 解析任务信息
                var missionInfo = parseMissionInfo(missionDir + "/" + fileName);

                // 为每个文件添加条目到模型
                flightPathModel.append({
                    "name": nameWithoutExt,
                    "date": new Date().toISOString().split('T')[0],  // 实际应该从文件获取时间
                    "distance": missionInfo.isValid ? formatDistance(missionInfo.totalDistance) : "未知",
                    "waypoints": missionInfo.isValid ? missionInfo.waypointCount : 0,
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
        console.log("当前filtered模型总数: " + filteredFlightPathModel.count);
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

    // 添加一个定时器，持续检查planView是否已初始化
    Timer {
        id: planViewInitTimer
        interval: 100  // 每100ms检查一次
        repeat: true
        running: false  // 默认不运行，只在需要时启动
        onTriggered: {
            if (mainWindow && mainWindow.planView && mainWindow.planView._planMasterController) {
                console.log("检测到planView已完全初始化");
                stop(); // 停止定时器
            }
        }
    }

    // 添加初始化检查
    Component.onCompleted: {
        // 确保MainWindow完全加载后再执行操作
        if (mainWindow && (mainWindow.planView === undefined || mainWindow.planView._planMasterController === undefined)) {
            console.log("等待planView初始化...");
            planViewInitTimer.start(); // 启动定时器监控planView初始化
        }
    }

    // 优化后的导航航点计算 - 使用更安全的方法
    function calculateNavigationWaypoints(visualItems) {
        var count = 0;
        try {
            for (var i = 0; i < visualItems.count; i++) {
                var item = visualItems.get(i);

                if (!item) continue; // 确保项目存在

                // 安全检查isSimpleItem属性
                var isSimpleItem = false;
                if (typeof item.isSimpleItem !== 'undefined') {
                    if (typeof item.isSimpleItem === 'function') {
                        isSimpleItem = item.isSimpleItem();
                    } else {
                        isSimpleItem = Boolean(item.isSimpleItem);
                    }
                }

                // 检查命令是否存在
                var command = 0;
                if (typeof item.command !== 'undefined') {
                    command = Number(item.command);
                }

                // 检查是否为SimpleMissionItem且命令为MAV_CMD_NAV_WAYPOINT
                if (isSimpleItem && command === 16) { // MAV_CMD_NAV_WAYPOINT
                    count++;
                }
            }
        } catch (e) {
            console.log("计算航点数时发生错误: " + e.message);
        }
        return count;
    }

    // 优化后的任务信息解析器
    function parseMissionInfo(filePath) {
        var info = {
            waypointCount: 0,
            totalDistance: 0,
            isValid: false,
            errorString: ""
        };

        console.log("开始解析任务文件: " + filePath);

        try {
            var tempController = Qt.createQmlObject(
                'import QGroundControl.Controllers; PlanMasterController {}',
                flightPathLibrary,  // 使用flightPathLibrary作为父对象而不是null
                'tempPlanController'
            );

            console.log("PlanMasterController 创建结果: " + (tempController !== null && tempController !== undefined));

            if (tempController) {
                tempController.start();

                tempController.loadFromFile(filePath);

                console.log("文件加载完成，检查是否包含项目...");

                if (tempController.containsItems) {
                    console.log("文件包含项目，获取missionController...");
                    var missionController = tempController.missionController;
                    console.log("missionController 获取结果: " + (missionController !== null && missionController !== undefined));

                    if (missionController) {
                        var visualItems = missionController.visualItems;
                        console.log("visualItems 获取结果: " + (visualItems !== null && visualItems !== undefined) + ", count: " + (visualItems ? visualItems.count : "undefined"));

                        // 计算航点数量
                        if (visualItems && visualItems.count > 0) {
                            info.waypointCount = calculateNavigationWaypoints(visualItems);
                            console.log("计算航点数结果: " + info.waypointCount);
                        }

                        // 直接使用QGC计算的距离，无需等待
                        info.totalDistance = missionController.missionTotalDistance;
                        console.log("初始距离值: " + info.totalDistance);

                        // 计算距离可能会失败，但我们仍要确保航点数被记录
                        try {
                            // 检查QGC内置计算是否合理（如果距离异常大，使用备选方法）
                            // 注意：当distance为0时，可能只是尚未计算完成，我们仍尝试备选方法
                            if (info.totalDistance > 10000000) {
                                console.log("QGC内置距离异常，使用修复后的备选方法计算距离，当前距离: " + info.totalDistance);
                                info.totalDistance = calculateTotalDistanceFromVisualItems(visualItems);
                                console.log("备选方法计算结果: " + info.totalDistance);
                            } else if (info.totalDistance === 0) {
                                // 当内置距离为0时，使用备选方法计算
                                console.log("QGC内置距离为0，使用修复后的备选方法计算距离");
                                info.totalDistance = calculateTotalDistanceFromVisualItems(visualItems);
                                console.log("备选方法计算结果: " + info.totalDistance);
                            } else {
                                // 如果QGC内置计算在合理范围内，但看起来像以米为单位（大于1000米），则转换为公里
                                if (info.totalDistance > 1000 && info.totalDistance <= 10000000) {
                                    // 假设这个值是以米为单位，转换为公里
                                    info.totalDistance = info.totalDistance / 1000;
                                    console.log("QGC内置距离看起来是以米为单位，转换为公里: " + info.totalDistance);
                                }
                            }

                            info.isValid = true; // 如果距离计算成功，设置为有效
                        } catch (distanceError) {
                            console.log("距离计算失败: " + distanceError.message);
                            info.totalDistance = 0; // 重置距离为0
                            // 即使距离计算失败，如果航点数已经计算出来了，我们仍然标记为部分有效
                            info.isValid = (info.waypointCount > 0); // 如果有航点数，则部分有效
                        }
                        console.log("解析完成 - 航点数: " + info.waypointCount + ", 距离: " + info.totalDistance);
                    } else {
                        info.errorString = "无法获取missionController";
                        console.log("错误：无法获取missionController");
                    }
                } else {
                    info.errorString = "文件为空或无效";
                    console.log("错误：文件为空或无效");
                }

                // 确保清理资源
                if (tempController.destroy) {
                    tempController.destroy();
                }
            } else {
                info.errorString = "无法创建PlanMasterController实例";
                console.log("错误：无法创建PlanMasterController实例");
            }
        } catch (e) {
            info.errorString = "解析失败: " + e.message;
            console.log("解析任务文件失败: " + e.message);
        }

        return info;
    }

    // 修复后的距离计算函数
    function calculateTotalDistanceFromVisualItems(visualItems) {
        var totalDistance = 0;
        var lastCoordinate = null;

        try {
            // 从索引1开始，跳过MissionSettingsItem
            for (var i = 1; i < visualItems.count; i++) {
                var item = visualItems.get(i);

                if (!item) continue; // 确保项目存在

                // 只处理指定坐标的项目
                // 修复：检查specifiesCoordinate属性是函数还是布尔值
                var hasCoordinate = false;
                if (typeof item.specifiesCoordinate !== 'undefined') {
                    if (typeof item.specifiesCoordinate === 'function') {
                        hasCoordinate = item.specifiesCoordinate();
                    } else {
                        // 如果是布尔值，直接使用它
                        hasCoordinate = Boolean(item.specifiesCoordinate);
                    }
                }

                if (hasCoordinate) {
                    // 安全地获取坐标
                    var coord = null;
                    try {
                        coord = item.coordinate;
                    } catch (e) {
                        console.log("获取坐标失败: " + e.message);
                        continue; // 跳过此项目
                    }

                    // 验证坐标有效性
                    if (coord && typeof coord.isValid !== 'undefined' && coord.isValid &&
                        !isNaN(coord.latitude) && !isNaN(coord.longitude) &&
                        Math.abs(coord.latitude) <= 90 && Math.abs(coord.longitude) <= 180) {

                        if (lastCoordinate) {
                            try {
                                var segmentDistance = lastCoordinate.distanceTo(coord);
                                // 检查距离是否合理（避免异常值）
                                if (segmentDistance > 0 && segmentDistance < 1000000) { // 小于1000km
                                    totalDistance += segmentDistance;
                                }
                            } catch (distanceError) {
                                console.log("计算距离失败: " + distanceError.message);
                                continue; // 跳过此段距离计算
                            }
                        }
                        lastCoordinate = coord;
                    }
                }
            }
        } catch (e) {
            console.log("计算距离时发生错误: " + e.message);
        }

        return totalDistance;
    }

    // 格式化距离显示
    function formatDistance(distance) {
        // 确保距离是有效的数字
        var distNum = Number(distance);

        if (isNaN(distNum) || distNum <= 0) {
            return "未知";
        }

        console.log("【DEBUG】原始距离值: " + distNum);

        // 优化的单位转换逻辑
        // 如果距离大于1000000（假设是毫米或厘米单位）
        if (distNum > 10000000) {  // 超过10000km，几乎不可能是正常的飞行距离
            distNum = distNum / 100000;  // 假设是厘米，转换为公里
            console.log("【DEBUG】检测到超大距离值，转换为公里: " + distNum);
        } else if (distNum > 100000) {  // 超过100km，可能需要单位转换
            // 这里可能是以米为单位的大距离
            distNum = distNum / 1000;  // 转换为公里
            console.log("【DEBUG】转换为公里: " + distNum);
        } else if (distNum > 1000) {  // 超过1km，可能是以米为单位
            distNum = distNum / 1000;  // 转换为公里
            console.log("【DEBUG】转换为公里: " + distNum);
        }

        // 如果距离看起来像是以米为单位的较大数值，转换为合适的单位
        if (distNum < 1000) {
            return Math.round(distNum) + " m";
        } else {
            return (distNum).toFixed(2) + " km";
        }
    }
}