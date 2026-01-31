import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.4
import QtLocation 5.9
import QtPositioning 5.5

import QGroundControl.Palette 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.Vehicle 1.0
import QGroundControl.MultiVehicleManager 1.0

import QGroundControl

Item {
    id: root
    anchors.fill: parent

    // 定义关闭信号，用于通知父级隐藏自身
    signal closeRequested()

    // 添加PlanMasterController实例用于导出功能
    PlanMasterController {
        id: exportController
        flyView: false
        
        Component.onCompleted: {
            exportController.start()
        }
    }

    // 用于跟踪当前选中的航线
    property var selectedRouteForExport: null

    // 删除确认对话框组件
    Component {
        id: deleteRouteDialogComponent
        
        QGCPopupDialog {
            id: deleteRouteDialog
            title: qsTr("删除航线")
            buttons: Dialog.Yes | Dialog.No
            
            property string routeFilePath
            property var deleteCallback
            
            onAccepted: {
                console.log("删除对话框确认事件被触发");
                if (routeFilePath) {
                    console.log("准备删除文件路径:", routeFilePath);
                    
                    // 确保文件存在
                    var fileExistsBefore = fileDialogController.fileExists(routeFilePath);
                    console.log("文件是否存在:", fileExistsBefore);
                    
                    if (fileExistsBefore) {
                        console.log("调用fileDialogController.deleteFile: " + routeFilePath);
                        try {
                            // 执行删除操作
                            fileDialogController.deleteFile(routeFilePath);
                            console.log("fileDialogController.deleteFile调用完成");
                            
                            // 验证删除结果
                            setTimeout(function() {
                                var fileExistsAfter = fileDialogController.fileExists(routeFilePath);
                                console.log("删除后文件是否存在:", fileExistsAfter);
                                
                                if (!fileExistsAfter) {
                                    console.log("文件删除成功");
                                } else {
                                    console.log("文件删除失败");
                                }
                                
                                if (deleteCallback) {
                                    console.log("调用删除回调函数");
                                    deleteCallback();
                                }
                            }, 200); // 增加延时以确保删除操作完成
                            
                        } catch (error) {
                            console.log("删除文件时发生错误: " + error.message);
                        }
                    } else {
                        console.log("文件不存在，跳过删除操作");
                        if (deleteCallback) {
                            console.log("调用删除回调函数");
                            deleteCallback();
                        }
                    }
                }
            }
            
            ColumnLayout {
                QGCLabel {
                    text: qsTr("确定要删除这条航线吗？")
                    Layout.preferredWidth: Math.max(mainWindow.width / 3, headerMinWidth)
                    wrapMode: Text.WordWrap
                }
                
                QGCLabel {
                    text: qsTr("此操作无法撤销。")
                    color: qgcPal.warningText
                    Layout.preferredWidth: Math.max(mainWindow.width / 3, headerMinWidth)
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // 半透明背景，让用户知道覆盖层已显示
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

        QGCPalette { 
            id: qgcPal 
            colorGroupEnabled: enabled  // 确保启用颜色组
        }

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
                        console.log("【DEBUG】导出按钮被点击");
                        console.log("【DEBUG】当前currentIndex: " + flightPathList.currentIndex);
                        
                        if (flightPathList.currentIndex >= 0) {
                            var selectedFlightPath = flightPathModel.get(flightPathList.currentIndex);
                            console.log("准备导出航线: " + selectedFlightPath.name);
                            
                            // 选择航线用于导出（加载到exportController）
                            selectRouteForExport(flightPathList.currentIndex);
                            
                            // 设置默认文件名
                            exportFileDialog.defaultSuffix = "plan";
                            exportFileDialog.folder = QGroundControl.settingsManager.appSettings.missionSavePath;
                            
                            // 设置导出对话框参数
                            exportFileDialog.nameFilters = exportController.saveNameFilters;
                            
                            // 尝试设置默认文件名，如果支持的话
                            try {
                                // 如果航线有文件路径，则使用该路径的文件名
                                if (selectedFlightPath.filePath && selectedFlightPath.filePath !== "") {
                                    var fileName = selectedFlightPath.filePath.substring(selectedFlightPath.filePath.lastIndexOf("/") + 1);
                                    // 检查是否已经以.plan结尾
                                    if (fileName.toLowerCase().indexOf(".plan") !== fileName.length - 5) {
                                        // 如果没有.plan扩展名，则添加
                                        exportFileDialog.selectedName = fileName;
                                    } else {
                                        // 如果已经有.plan扩展名，则直接使用
                                        exportFileDialog.selectedName = fileName;
                                    }
                                } else {
                                    // 如果没有文件路径，则使用航线名称
                                    exportFileDialog.selectedName = selectedFlightPath.name + ".plan";
                                }
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
                        // 可以在这里打开一个新的创建航线对话框
                        createNewFlightPath();
                    }
                }

                QGCButton {
                    text: qsTr("关闭")
                    onClicked: {
                        // 发送关闭信号给父级
                        root.closeRequested();
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
                // 关键：启用缓存以确保正确刷新
                cacheBuffer: 0  // 设置为0以强制在刷新时重建所有项

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
                        // 在刷新前重置选中状态，避免状态混乱
                        flightPathList.currentIndex = -1;
                        loadFlightPathsFromStorage();
                    }
                }
            }
        }
    }

    // 航线库数据模型
    ListModel {
        id: flightPathModel
        // 实际应用中会从文件加载数据
    }

    // 过滤后的航线模型
    ListModel {
        id: filteredFlightPathModel
    }

    // 直接在Item中创建一个QGCFileDialogController实例
    QGCFileDialogController {
        id: fileDialogController
    }

    // 文件对话框 - 导入
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
        nameFilters: exportController.saveNameFilters
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

    // 添加一个定时器，持续检查planView是否已初始化
    Timer {
        id: planViewInitTimer
        interval: 100  // 每100ms检查一次
        repeat: true
        running: false  // 默认不运行，只在需要时启动
        onTriggered: {
            if (mainWindow && mainWindow.planView && mainWindow.planView._planMasterController) {
                console.log("检测到planView已完全初始化");
                // 如果有等待加载的航线，可以在这里处理
                stop(); // 停止定时器
            }
        }
    }

    // 初始化时加载航线数据
    Component.onCompleted: {
        console.log("航线库界面已加载");
        // 调试QGCFileDialogController
        debugQGCFileDialogController();
        // 从文件系统加载航线数据
        loadFlightPathsFromStorage();
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
            
            console.log("已设置全局文件路径: " + flightPath.filePath);
            
            // 关闭航线库界面，返回到计划视图
            root.closeRequested();
        }
    }

    function deleteFlightPath(index) {
        // 删除航线的逻辑
        var flightPath = flightPathModel.get(index);
        console.log("=== 开始删除调试 ===");
        console.log("准备删除航线: " + flightPath.name);
        console.log("文件路径:", flightPath.filePath);
        
        // 检查是否有文件路径，如果有则需要删除物理文件
        if (flightPath.filePath && flightPath.filePath !== "") {
            // 确保文件存在
            var fileExistsBefore = fileDialogController.fileExists(flightPath.filePath);
            console.log("文件是否存在:", fileExistsBefore);
            if (!fileExistsBefore) {
                console.log("文件不存在或路径错误:", flightPath.filePath);
                // 即使文件不存在，也从模型中移除条目
                flightPathModel.remove(index);
                updateFilteredModel();
                console.log("航线已从模型中移除（文件不存在）: " + flightPath.name);
                return;
            }
            
            // 检查是否可以通过MainWindow的showMessageDialog方法显示确认对话框
            if (typeof mainWindow !== 'undefined' && mainWindow && typeof mainWindow.showMessageDialog === 'function') {
                // 使用MainWindow的简化方法
                console.log("使用MainWindow.showMessageDialog方法");
                mainWindow.showMessageDialog(
                    qsTr("删除航线"), 
                    qsTr("确定要删除这条航线吗？此操作无法撤销。"), 
                    Dialog.Yes | Dialog.No,
                    function() {
                        console.log("确认删除，执行删除操作");
                        try {
                            // 执行删除操作
                            fileDialogController.deleteFile(flightPath.filePath);
                            console.log("删除命令已执行");
                            
                            // 验证删除结果
                            setTimeout(function() {
                                var fileExistsAfter = fileDialogController.fileExists(flightPath.filePath);
                                console.log("删除后文件是否存在:", fileExistsAfter);
                                
                                if (!fileExistsAfter) {
                                    console.log("文件删除成功");
                                    // 从模型中移除条目
                                    flightPathModel.remove(index);
                                    updateFilteredModel();
                                    console.log("航线已从模型中移除: " + flightPath.name);
                                } else {
                                    console.log("文件删除失败");
                                    // 即使文件删除失败，也从模型中移除条目，但给出警告
                                    flightPathModel.remove(index);
                                    updateFilteredModel();
                                    console.log("航线已从模型中移除（但文件未删除）: " + flightPath.name);
                                }
                                
                                // 参考QGC官方实现，刷新整个列表
                                setTimeout(function() {
                                    console.log("刷新航线列表");
                                    loadFlightPathsFromStorage();
                                }, 300); // 稍微延时以确保删除操作彻底完成
                                
                            }, 200); // 增加延时以确保删除操作完成
                            
                        } catch (e) {
                            console.log("删除失败:", e.message);
                            // 即使删除失败，也从模型中移除条目，但给出警告
                            flightPathModel.remove(index);
                            updateFilteredModel();
                        }
                    }
                );
            } else {
                // 使用自定义对话框组件
                console.log("使用自定义对话框组件");
                var deleteDialog = deleteRouteDialogComponent.createObject(root, {
                    routeFilePath: flightPath.filePath,
                    deleteCallback: function() {
                        console.log("自定义对话框删除回调函数被调用");
                        // 删除成功后的回调，刷新列表
                        flightPathModel.remove(index);
                        updateFilteredModel();
                        console.log("航线删除成功: " + flightPath.name);
                        
                        // 参考QGC官方实现，刷新整个列表
                        setTimeout(function() {
                            console.log("刷新航线列表");
                            loadFlightPathsFromStorage();
                        }, 300); // 稍微延时以确保删除操作彻底完成
                    }
                });
                if (deleteDialog) {
                    console.log("打开删除确认对话框");
                    deleteDialog.open();
                } else {
                    console.log("无法创建删除对话框，直接删除");
                    // 直接执行删除
                    fileDialogController.deleteFile(flightPath.filePath);
                    // 验证删除结果
                    setTimeout(function() {
                        var fileExistsAfter = fileDialogController.fileExists(flightPath.filePath);
                        console.log("直接删除后文件是否存在:", fileExistsAfter);
                        
                        if (!fileExistsAfter) {
                            console.log("文件直接删除成功");
                        } else {
                            console.log("文件直接删除失败");
                        }
                        
                        // 从模型中移除条目
                        flightPathModel.remove(index);
                        updateFilteredModel();
                        
                        // 参考QGC官方实现，刷新整个列表
                        setTimeout(function() {
                            console.log("刷新航线列表");
                            loadFlightPathsFromStorage();
                        }, 300); // 稍微延时以确保删除操作彻底完成
                    }, 200);
                }
            }
        } else {
            // 没有文件路径，直接删除模型中的条目
            flightPathModel.remove(index);
            updateFilteredModel();
            console.log("航线已删除（无文件）: " + flightPath.name);
        }
        console.log("=== 删除调试结束 ===");
    }

    function importFlightPath(filePath) {
        // 导入航线文件的逻辑
        console.log("导入航线文件: " + filePath);
        // 获取文件名（不含扩展名）
        var fileName = filePath.split('/').pop().split('/').pop();
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

    PlanMasterController {
        id: _planMasterController
        Component.onCompleted: start()
    }

    function exportFlightPath(index, targetPath) {
        var flightPath = flightPathModel.get(index)
        if (!flightPath || !flightPath.filePath)
            return

        var sourcePath = flightPath.filePath
        console.log("准备导出航线:", flightPath.name, sourcePath)

        if (!fileDialogController.fileExists(sourcePath)) {
            console.warn("源航线不存在:", sourcePath)
            return
        }

        // 1. 加载原始航线
        _planMasterController.loadFromFile(sourcePath)

        // 2. 构造目标文件名（推荐加时间戳，避免覆盖）
        var timeStr = Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss")
        var fileName = flightPath.name + "_" + timeStr + ".plan"

        // 3. 目标路径（Android 安全）
        var targetPath =
            QGCFileDialogController.defaultSavePath()
            + "/" + fileName

        console.log("导出目标路径:", targetPath)

        // 4. 保存
        _planMasterController.saveToFile(targetPath)

        // 5. 可选：提示
        qgcApp.showMessage("航线已导出到:\n" + targetPath)
    }

    function loadFlightPathsFromStorage() {  
        console.log("从存储加载航线 - 开始");  
      
        var missionDir = QGroundControl.settingsManager.appSettings.missionSavePath;  
        console.log("扫描目录: " + missionDir);  
      
        if (!missionDir || missionDir === "") {  
            console.log("任务保存路径未设置或为空");  
            return;  
        }  
      
        var planFiles = [];  
        var missionFiles = [];  
      
        try {  
            // 备选方案：通过实例调用  
            var controller = fileDialogController;  
            if (controller && typeof controller.getFiles === 'function') {  
                planFiles = controller.getFiles(missionDir, ["*.plan"]);  
                missionFiles = controller.getFiles(missionDir, ["*.mission"]);  
            } else {  
                console.log("getFiles方法不可用，尝试其他方案");  
                // 使用QDir直接扫描  
                planFiles = scanDirectory(missionDir, "*.plan");  
                missionFiles = scanDirectory(missionDir, "*.mission");  
            }  
      
            console.log("找到 " + planFiles.length + " 个.plan文件");  
            console.log("找到 " + missionFiles.length + " 个.mission文件");  
      
            // 更新航线模型  
            flightPathModel.clear();  
            addFilesToModel(planFiles, ".plan");  
            addFilesToModel(missionFiles, ".mission");  
      
        } catch (e) {  
            console.log("扫描文件失败: " + e.message);  
            console.log("错误详情: " + e.stack);  
        }  
      
        updateFilteredModel();  
        flightPathList.currentIndex = -1;  
    }  
      
    // 备选的目录扫描函数  
    function scanDirectory(directory, filter) {  
        var files = [];  
        try {  
            console.log("扫描目录: " + directory + " 过滤器: " + filter);  
            
            // 使用QGCFileDialogController来扫描文件
            if (fileDialogController && typeof fileDialogController.getFiles === 'function') {
                files = fileDialogController.getFiles(directory, [filter]);
                console.log("通过fileDialogController找到 " + files.length + " 个文件");
            } else {
                console.log("fileDialogController.getFiles方法不可用");
            }
              
        } catch (e) {  
            console.log("目录扫描失败: " + e.message);  
        }  
        return files;  
    }  
      
    function addFilesToModel(files, extension) {  
        var missionDir = QGroundControl.settingsManager.appSettings.missionSavePath;  
        for (var i = 0; i < files.length; i++) {  
            var fileName = files[i].replace(extension, '');  
            var filePath = missionDir + "/" + files[i];
            
            // 解析任务信息
            var missionInfo = parseMissionInfo(filePath);
            
            flightPathModel.append({  
                "name": fileName,  
                "filePath": filePath,  
                "date": new Date().toISOString().split('T')[0],  
                "distance": missionInfo.isValid ? formatDistance(missionInfo.totalDistance) : "未知",
                "waypoints": missionInfo.isValid ? missionInfo.waypointCount : 0
            });  
        }  
    }
    
    function debugQGCFileDialogController() {  
        console.log("=== QGCFileDialogController 调试信息 ===");  
        console.log("QGCFileDialogController 类型: " + typeof QGCFileDialogController);  
        console.log("getFiles 方法类型: " + typeof QGCFileDialogController.getFiles);  
          
        // 列出所有可用方法  
        for (var prop in QGCFileDialogController) {  
            if (typeof QGCFileDialogController[prop] === 'function') {  
                console.log("可用方法: " + prop);  
            }  
        }  
          
        // 检查实例方法  
        if (fileDialogController) {  
            console.log("fileDialogController 类型: " + typeof fileDialogController);  
            console.log("实例getFiles 方法类型: " + typeof fileDialogController.getFiles);  
        }  
    }
    
    function updateFilteredModel() {
        // 清空过滤模型
        filteredFlightPathModel.clear();
        
        // 复制当前搜索和排序条件下的数据到过滤模型
        for (let i = 0; i < flightPathModel.count; i++) {
            let item = flightPathModel.get(i);
            // 如果当前没有搜索词或搜索词匹配，则添加到过滤模型
            if (!searchInput || searchInput.text === "" || 
                item.name.toLowerCase().includes(searchInput.text.toLowerCase()) ||
                item.date.toLowerCase().includes(searchInput.text.toLowerCase())) {
                filteredFlightPathModel.append(item);
            }
        }
        
        // 对过滤后的模型进行排序
        sortFlightPaths(sortComboBox.currentIndex);
    }

    function filterFlightPaths(filterText) {
        // 过滤航线的逻辑
        console.log("过滤航线: " + filterText);
        filteredFlightPathModel.clear();
        for (let i = 0; i < flightPathModel.count; i++) {
            let item = flightPathModel.get(i);
            if (filterText === "" || 
                item.name.toLowerCase().includes(filterText.toLowerCase()) ||
                item.date.toLowerCase().includes(filterText.toLowerCase())) {
                // 将ListModel中的元素复制为普通JS对象再添加
                filteredFlightPathModel.append({
                    name: item.name,
                    date: item.date,
                    distance: item.distance,
                    waypoints: item.waypoints
                });
            }
        }
        statusLabel.text = qsTr("共 %1 条航线").arg(filteredFlightPathModel.count);
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
                root,  // 使用root作为父对象而不是flightPathLibrary
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
                            // 直接使用QGC计算的距离，单位已经是米
                            // 只有当距离为0或异常时才使用备选方法
                            if (info.totalDistance === 0 || info.totalDistance > 100000) {  // 超过100km认为是异常值
                                console.log("QGC内置距离异常或为0，使用备选方法计算距离，当前距离: " + info.totalDistance);
                                info.totalDistance = calculateTotalDistanceFromVisualItems(visualItems);
                                console.log("备选方法计算结果: " + info.totalDistance);
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

    // 从距离字符串中提取数值（考虑单位）
    function extractDistanceValue(distanceStr) {
        if (typeof distanceStr !== 'string' && typeof distanceStr !== 'number') {
            return NaN;
        }

        if (typeof distanceStr === 'number') {
            return distanceStr;
        }

        // 移除所有空格
        var cleanStr = distanceStr.trim();

        if (cleanStr === "未知") {
            return NaN;
        }

        // 检查是否包含单位
        if (cleanStr.includes("km")) {
            // 提取km单位的数值
            var kmValue = parseFloat(cleanStr.replace(/km/gi, "").trim());
            return isNaN(kmValue) ? NaN : kmValue * 1000;  // 转换为米
        } else if (cleanStr.includes("m")) {
            // 提取m单位的数值
            var mValue = parseFloat(cleanStr.replace(/m/gi, "").trim());
            return mValue;  // 保持为米
        } else {
            // 假设纯数字是米
            return parseFloat(cleanStr);
        }
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
        var distNum = Number(distance);

        if (isNaN(distNum) || distNum <= 0) {
            return "未知";
        }
        
        // 根据距离大小选择合适的单位
        if (distNum >= 1000) {
            var kmValue = distNum / 1000;
            // 如果转换为公里后是整数或小数点后两位非零，则显示公里
            if (kmValue % 1 === 0) {
                return kmValue.toFixed(0) + " km";
            } else {
                return kmValue.toFixed(2) + " km";
            }
        } else {
            return Math.round(distNum) + " m";
        }
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
                    // 使用统一的单位进行比较
                    var distA = extractDistanceValue(a.distance);
                    var distB = extractDistanceValue(b.distance);
                    if (isNaN(distA)) distA = Infinity;
                    if (isNaN(distB)) distB = Infinity;
                    return distB - distA; // 大距离在前
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

    function selectRouteForExport(index) {
        var flightPath = flightPathModel.get(index);
        if (!flightPath || !flightPath.filePath) {
            console.log("无法选择航线用于导出：缺少文件路径");
            return;
        }
        
        console.log("加载航线到exportController: " + flightPath.filePath);
        
        // 加载航线到exportController
        try {
            exportController.loadFromFile(flightPath.filePath);
            console.log("航线成功加载到exportController");
        } catch (error) {
            console.log("加载航线到exportController失败: " + error.message);
        }
    }
}