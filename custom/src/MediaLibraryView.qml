import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.platform as Labs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Controllers
import QGroundControl.Palette

Item {
    id: root
    anchors.fill: parent

    // 定义关闭信号，用于通知父级隐藏自身
    signal closeRequested()

    property var mediaList: []
    property var filteredList: []
    property string currentFilter: "all"
    property var selectedFiles: []

    QGCPalette { id: qgcPal }

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
        width: Math.min(parent.width * 0.9, 1000)  // 最大宽度1000px，占父级90%
        height: Math.min(parent.height * 0.9, 700)  // 最大高度700px，占父级90%
        color: qgcPal.window
        radius: 10
        border.color: qgcPal.windowText
        border.width: 1

        // 主布局
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                QGCLabel {
                    text: qsTr("媒体库")
                    font.pixelSize: 20
                    color: qgcPal.text
                }

                Item { Layout.fillWidth: true }

                // 左侧筛选按钮组
                QGCButton {
                    text: qsTr("全部")
                    checkable: true
                    checked: currentFilter === "all"
                    onClicked: setFilter("all")
                }
                QGCButton {
                    text: qsTr("视频")
                    checkable: true
                    checked: currentFilter === "video"
                    onClicked: setFilter("video")
                }
                QGCButton {
                    text: qsTr("图片")
                    checkable: true
                    checked: currentFilter === "image"
                    onClicked: setFilter("image")
                }

                Item { Layout.fillWidth: true }

                // 右侧操作按钮
                QGCButton {
                    text: qsTr("导出")
                    enabled: selectedFiles.length > 0
                    onClicked: exportSelectedFiles()
                }
                QGCButton {
                    text: qsTr("刷新")
                    onClicked: refreshMedia()
                }
                QGCButton {
                    text: qsTr("关闭")
                    onClicked: {
                        // 发送关闭信号给父级
                        root.closeRequested()
                    }
                }
            }

            // 媒体网格显示
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: mediaGrid
                    cellWidth: 140
                    cellHeight: 160
                    model: filteredList

                    delegate: Rectangle {
                        width: mediaGrid.cellWidth - 4
                        height: mediaGrid.cellHeight - 4
                        color: selectedFiles.includes(modelData.filePath) ? qgcPal.colorBlue : qgcPal.window
                        border.color: selectedFiles.includes(modelData.filePath) ? qgcPal.colorBlue : qgcPal.text
                        border.width: selectedFiles.includes(modelData.filePath) ? 3 : 1
                        radius: 5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 2

                            // 缩略图显示
                            Item {
                                Layout.preferredWidth: parent.width - 4
                                Layout.preferredHeight: parent.width - 4
                                Layout.alignment: Qt.AlignHCenter

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: modelData.isVideo ? "qrc:/qmlimages/video.svg" : modelData.filePath
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: 120
                                    sourceSize.height: 120
                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            // 如果图片加载失败，显示默认图标
                                            source = modelData.isVideo ? "qrc:/qmlimages/video.svg" : "qrc:/qmlimages/image.svg"
                                        }
                                    }
                                }

                                // 视频标识
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "red"
                                    visible: modelData.isVideo

                                    Text {
                                        anchors.centerIn: parent
                                        text: "V"
                                        color: "white"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            // 文件名显示
                            QGCLabel {
                                Layout.fillWidth: true
                                text: modelData.fileName
                                font.pixelSize: ScreenTools.smallFontPointSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: toggleSelection(modelData)
                            onDoubleClicked: openPreview(modelData)
                        }
                    }
                }
            }

            // 底部状态栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                QGCLabel {
                    id: statusLabel
                    text: qsTr("共 %1 个媒体文件 (%2 个已选)").arg(filteredList.length).arg(selectedFiles.length)
                    color: qgcPal.text
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    // 文件对话框 - 用于导出
    Labs.FolderDialog {
        id: exportFolderDialog
        title: qsTr("选择导出目录")
        onAccepted: performExport(exportFolderDialog.folder)
    }

    // 功能函数
    function setFilter(filter) {
        currentFilter = filter
        updateFilteredList()
    }

    function updateFilteredList() {
        filteredList = mediaList.filter(function(item) {
            if (currentFilter === "all") return true
            if (currentFilter === "video") return item.isVideo
            if (currentFilter === "image") return !item.isVideo
            return false
        })
        statusLabel.text = qsTr("共 %1 个媒体文件 (%2 个已选)").arg(filteredList.length).arg(selectedFiles.length)
    }

    function refreshMedia() {
        mediaList = []
        selectedFiles = []

        // 扫描本地媒体
        scanLocalMedia()

        // 请求飞行器媒体（如果连接了车辆）
        requestVehicleMedia()

        updateFilteredList()
    }

    function scanLocalMedia() {
        try {
            // 获取用户文档目录中的图片和视频文件
            var pictureDir = QGroundControl.settingsManager.appSettings.picturesPath
            var moviesDir = QGroundControl.settingsManager.appSettings.moviesPath

            // 使用QGC的文件对话框控制器来访问文件
            var fileDialogController = Qt.createQmlObject("import QGroundControl.Controllers 1.0; QGCFileDialogController {}", root, "fileDialogController");
            
            if (fileDialogController) {
                // 扫描图片文件
                var imageExtensions = ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
                var imageFiles = []
                
                // 尝试从多个路径获取图片
                var picPaths = [pictureDir, QGroundControl.settingsManager.appSettings.logsSavePath]
                
                for (var j = 0; j < picPaths.length; j++) {
                    if (picPaths[j] && picPaths[j] !== "") {
                        var foundImages = fileDialogController.getFiles(picPaths[j], imageExtensions)
                        for (var k = 0; k < foundImages.length; k++) {
                            imageFiles.push(foundImages[k])
                        }
                    }
                }

                // 添加图片文件到媒体列表
                for (var i = 0; i < imageFiles.length; i++) {
                    var fileName = imageFiles[i].split('/').pop()
                    mediaList.push({
                        filePath: imageFiles[i],
                        fileName: fileName,
                        isVideo: false,
                        isLocal: true
                    })
                }

                // 扫描视频文件
                var videoExtensions = ["*.mp4", "*.mov", "*.avi", "*.mkv", "*.wmv", "*.flv", "*.webm"]
                var videoFiles = []
                
                // 尝试从多个路径获取视频
                var vidPaths = [moviesDir, QGroundControl.settingsManager.appSettings.logsSavePath]
                
                for (var m = 0; m < vidPaths.length; m++) {
                    if (vidPaths[m] && vidPaths[m] !== "") {
                        var foundVideos = fileDialogController.getFiles(vidPaths[m], videoExtensions)
                        for (var n = 0; n < foundVideos.length; n++) {
                            videoFiles.push(foundVideos[n])
                        }
                    }
                }

                // 添加视频文件到媒体列表
                for (var l = 0; l < videoFiles.length; l++) {
                    var videoFileName = videoFiles[l].split('/').pop()
                    mediaList.push({
                        filePath: videoFiles[l],
                        fileName: videoFileName,
                        isVideo: true,
                        isLocal: true
                    })
                }
            }
        } catch (e) {
            console.log("扫描本地媒体时出错: " + e.message)
        }
    }

    function requestVehicleMedia() {
        try {
            if (QGroundControl.multiVehicleManager && QGroundControl.multiVehicleManager.activeVehicle) {
                var vehicle = QGroundControl.multiVehicleManager.activeVehicle;
                if (vehicle && vehicle.cameraManager) {
                    console.log("请求飞行器媒体列表...");
                    
                    // 由于QGCCameraManager没有直接提供媒体列表，我们需要使用其他方式
                    // 这里只是占位符，实际需要根据MAVLink协议实现
                    // 或者依赖于飞行器提供的存储信息
                } else {
                    console.log("当前车辆没有相机管理器");
                }
            } else {
                console.log("没有活动车辆");
            }
        } catch (e) {
            console.log("请求飞行器媒体时出错: " + e.message)
        }
    }

    function toggleSelection(item) {
        var index = selectedFiles.indexOf(item.filePath)
        if (index >= 0) {
            selectedFiles.splice(index, 1)
        } else {
            selectedFiles.push(item.filePath)
        }
        updateFilteredList() // 更新状态标签
    }

    function exportSelectedFiles() {
        if (selectedFiles.length === 0) {
            console.log("没有选中任何文件")
            return
        }
        exportFolderDialog.open()
    }

    function performExport(folder) {
        if (!folder) {
            console.log("未选择导出目录")
            return
        }

        try {
            var fileDialogController = Qt.createQmlObject("import QGroundControl.Controllers 1.0; QGCFileDialogController {}", root, "fileDialogController");
            
            if (fileDialogController) {
                for (var i = 0; i < selectedFiles.length; i++) {
                    var sourceFile = selectedFiles[i]
                    var fileName = sourceFile.split('/').pop()
                    var destFile = folder.path + "/" + fileName

                    // 尝试复制文件
                    if (fileDialogController.copyFile(sourceFile, destFile)) {
                        console.log("成功导出文件:", destFile)
                    } else {
                        console.log("导出文件失败:", sourceFile, "到", destFile)
                    }
                }
            }
        } catch (e) {
            console.log("导出文件时出错: " + e.message)
        }
        
        selectedFiles = []
        updateFilteredList() // 更新状态标签
    }

    function openPreview(item) {
        console.log("预览文件:", item.filePath)
        // 这里可以实现媒体预览功能
        // 对于图片，可以使用Image组件
        // 对于视频，可以使用Video组件
        // 由于这是一个独立的QML文件，我们可以实现完整的预览功能
        if (item.isVideo) {
            // 播放视频（如果QGC支持的话）
            console.log("视频文件，支持预览")
        } else {
            // 显示图片
            console.log("图片文件，支持预览")
        }
    }

    Component.onCompleted: {
        // 初始化时加载媒体数据
        refreshMedia()
    }
}