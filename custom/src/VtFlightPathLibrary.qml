import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.4
import QtLocation 5.9
import QtPositioning 5.5
import Qt.labs.platform 1.1 as LabsPlatform

import QGroundControl.Palette 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.Vehicle 1.0
import QGroundControl.MultiVehicleManager 1.0


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
                    // 根据是否为当前选中项设置颜色
                    color: {
                        if (index === ListView.view.currentIndex) {
                            return qgcPal.highlight;
                        } else {
                            return index % 2 ? qgcPal.window : qgcPal.windowShade;
                        }
                    }
                    // 边框颜色根据选中状态设置
                    border.color: {
                        if (mouseArea.containsMouse && index !== ListView.view.currentIndex) {
                            return "lightblue";  // 悬停但未选中
                        } else if (index === ListView.view.currentIndex) {
                            return "white";  // 选中时为白色边框
                        } else {
                            return qgcPal.windowText || "#000000";  // 默认状态
                        }
                    }
                    // 边框宽度根据选中状态设置
                    border.width: (index === ListView.view.currentIndex) ? 2 : 1
                    radius: 5

                    // 添加一个状态属性来帮助跟踪
                    property bool isSelected: index === ListView.view.currentIndex

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
                                    // 实现加载航线到地图的逻辑
                                    loadFlightPath(index);
                                }
                            }

                            QGCButton {
                                text: qsTr("编辑")
                                onClicked: {
                                    console.log("编辑航线: " + name);
                                    ListView.view.currentIndex = index;
                                    // 实现编辑航线的逻辑
                                    editFlightPath(index);
                                }
                            }

                            QGCButton {
                                text: qsTr("删除")
                                onClicked: {
                                    console.log("删除航线: " + name);
                                    ListView.view.currentIndex = index;
                                    // 实现删除航线的逻辑
                                    deleteFlightPath(index);
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            ListView.view.currentIndex = index;
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
            rightPanelOpen = false;
            
            console.log("已设置全局文件路径: " + flightPath.filePath);
            
            // 关闭航线库界面，返回到计划视图
            root.closeRequested();
        }
    }

    function editFlightPath(index) {
        // 编辑航线的逻辑
        console.log("编辑航线: " + flightPathModel.get(index).name);
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
        var fileName = filePath.split('\\\\').pop().split('/').pop();
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
            
            // 构造简单的.plan文件内容
            var planContent = {
                "version": 1,
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
            
            // 将planContent转换为JSON字符串
            var jsonString = JSON.stringify(planContent, null, 4);
            
            // 尝试使用QGCFileDialogController写入文件
            try {
                // 检查fileDialogController是否支持writeFile方法
                if (fileDialogController && typeof fileDialogController.writeFile === 'function') {
                    var success = fileDialogController.writeFile(filePath, jsonString);
                    if (success) {
                        console.log("航线文件导出成功: " + filePath);
                    } else {
                        console.log("航线文件导出失败: " + filePath);
                    }
                } else {
                    console.log("fileDialogController.writeFile方法不可用");
                    
                    // 尝试其他可能的文件写入方法
                    if (fileDialogController && typeof fileDialogController.writeFileContent === 'function') {
                        var success = fileDialogController.writeFileContent(filePath, jsonString);
                        if (success) {
                            console.log("航线文件导出成功: " + filePath);
                        } else {
                            console.log("航线文件导出失败: " + filePath);
                        }
                    } else {
                        console.log("fileDialogController.writeFileContent方法也不可用");
                        
                        // 作为最后的手段，显示提示信息给用户
                        console.log("无法导出文件到: " + filePath);
                        console.log("可能需要通过QGC的内置功能来保存任务");
                        
                        // 输出文件内容到控制台，供用户参考
                        console.log("文件内容:\n", jsonString);
                    }
                }
            } catch (writeErr) {
                console.log("写入文件时发生错误: " + writeErr.message);
            }
            
        } catch (e) {
            console.log("导出过程中发生错误: " + e.message);
            console.log("错误详情: ", e);
        }
    }

    function loadFlightPathsFromStorage() {
        console.log("从存储加载航线 - 开始");
        
        var missionDir = QGroundControl.settingsManager.appSettings.missionSavePath;
        console.log("扫描目录: " + missionDir);
        
        if (!missionDir || missionDir === "") {
            console.log("任务保存路径未设置或为空");
            return;
        }
        
        // 使用 QGC 的文件系统 API
        try {
            // 使用 QML 的 FolderListModel 扫描文件
            var folderModel = Qt.createQmlObject('import Qt.labs.folderlistmodel 2.1; FolderListModel {}',
                                               root, "folderModel");
            folderModel.folder = missionDir;
            folderModel.nameFilters = ["*.plan"];
            
            var planFiles = [];
            for (var i = 0; i < folderModel.count; i++) {
                var fileName = folderModel.get(i).fileName;
                if (fileName.endsWith(".plan")) {
                    var filePath = missionDir + "/" + fileName;
                    planFiles.push(filePath);
                }
            }
            
            console.log("找到 " + planFiles.length + " 个.plan文件: ", planFiles);
            
            // 更新航线模型
            flightPathModel.clear();
            for (var j = 0; j < planFiles.length; j++) {
                var fileName = planFiles[j].split('/').pop().replace('.plan', '');
                flightPathModel.append({
                    "name": fileName,
                    "filePath": planFiles[j],
                    "date": new Date().toISOString().split('T')[0],
                    "distance": "未知",
                    "waypoints": 0
                });
            }
            
            folderModel.destroy();
            
        } catch (e) {
            console.log("扫描文件失败: " + e.message);
            
            // 备用方案：如果FolderListModel不可用，则保留原有逻辑
            console.log("使用备用方案扫描文件...");
            
            // 保留示例数据
            flightPathModel.clear();
            flightPathModel.append({
                name: "测试航线1",
                date: "2024-01-15",
                distance: "15.2 km",
                waypoints: 8,
                filePath: ""
            });
            flightPathModel.append({
                name: "测试航线2",
                date: "2024-01-10",
                distance: "8.7 km",
                waypoints: 5,
                filePath: ""
            });
            flightPathModel.append({
                name: "测试航线3",
                date: "2024-01-05",
                distance: "22.3 km",
                waypoints: 12,
                filePath: ""
            });
        }
        
        // 更新过滤模型
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

    function copyModelData(source, target) {
        // 复制模型数据的辅助函数
        target.clear();
        for (let i = 0; i < source.count; i++) {
            target.append(source.get(i));
        }
    }

    function updateFilteredModel() {
        // 更新过滤模型
        filterFlightPaths(searchInput.text);
        // 应用当前排序
        sortFlightPaths(sortComboBox.currentIndex);
    }
    
    function selectRouteForExport(index) {
        // 选择航线用于导出
        if (index >= 0 && index < flightPathModel.count) {
            var routeData = flightPathModel.get(index);
            console.log("选择航线用于导出: " + routeData.name);
            selectedRouteForExport = routeData;
            
            // 如果航线有关联的文件路径，尝试从文件加载任务数据到exportController
            if (routeData.filePath && routeData.filePath !== "") {
                console.log("从文件加载任务数据: " + routeData.filePath);
                exportController.loadFromFile(routeData.filePath);
            } else {
                console.log("航线没有关联的文件路径，使用当前PlanView中的数据");
            }
        }
    }
}