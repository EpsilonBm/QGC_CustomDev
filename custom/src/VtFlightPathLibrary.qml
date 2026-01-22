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
import QGroundControl.Mavlink 1.0
import QGroundControl.Utils 1.0
import QGroundControl.Location 1.0

Item {
    id: root
    anchors.fill: parent

    // 定义关闭信号，用于通知父级隐藏自身
    signal closeRequested()

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
                        importFileDialog.open();
                    }
                }

                QGCButton {
                    text: qsTr("导出")
                    onClicked: {
                        // 导出选中的航线
                        if (flightPathList.currentIndex >= 0) {
                            console.log("准备导出航线: " + flightPathModel.get(flightPathList.currentIndex).name);
                            exportFileDialog.open();
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

                QGCTextField {
                    id: searchField
                    placeholderText: qsTr("搜索航线...")
                    Layout.fillWidth: true
                    onTextChanged: {
                        filterFlightPaths(text);
                    }
                }

                QGCComboBox {
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

    // 文件对话框 - 导入
    LabsPlatform.FileDialog {
        id: importFileDialog
        title: qsTr("选择要导入的航线文件")
        folder: LabsPlatform.StandardPaths.writableLocation(LabsPlatform.StandardPaths.DocumentsLocation)
        nameFilters: ["Mission files (*.mission)", "All files (*)"]
        onAccepted: {
            console.log("选择了导入文件: " + file);
            importFlightPath(file);
        }
        onRejected: {
            console.log("取消导入");
        }
    }

    // 文件对话框 - 导出
    LabsPlatform.FileDialog {
        id: exportFileDialog
        title: qsTr("导出航线到文件")
        folder: LabsPlatform.StandardPaths.writableLocation(LabsPlatform.StandardPaths.DocumentsLocation)
        nameFilters: ["Mission files (*.mission)", "All files (*)"]
        fileMode: LabsPlatform.FileDialog.SaveFile
        onAccepted: {
            console.log("选择了导出文件: " + file);
            if (flightPathList.currentIndex >= 0) {
                exportFlightPath(flightPathList.currentIndex, file);
            }
        }
        onRejected: {
            console.log("取消导出");
        }
    }

    // 初始化时加载航线数据
    Component.onCompleted: {
        console.log("航线库界面已加载");
        // 复制原始数据到过滤模型
        copyModelData(flightPathModel, filteredFlightPathModel);
        // 这里可以添加从文件系统加载航线数据的逻辑
    }

    // JavaScript 函数实现实际功能
    function createNewFlightPath() {
        // 创建新航线的逻辑
        console.log("创建新航线功能待实现");
    }

    function loadFlightPath(index) {
        // 加载航线到地图的逻辑
        console.log("加载航线到地图: " + flightPathModel.get(index).name);
        // 这里可以调用QGC的航线加载功能
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
        // 这里需要解析文件并添加到模型中
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
                filteredFlightPathModel.append(item);
            }
        }
    }

    function sortFlightPaths(sortIndex) {
        // 排序航线的逻辑
        console.log("排序航线，索引: " + sortIndex);
        // 根据不同的索引进行排序
        updateFilteredModel(); // 简单实现，重载模型
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
        filterFlightPaths(searchField.text);
    }
}