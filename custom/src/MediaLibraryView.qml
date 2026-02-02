import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.platform as Labs
import QtMultimedia

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

    QGCPalette { 
        id: qgcPal 
        colorGroupEnabled: enabled  // 确保启用颜色组
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
                    text: qsTr("测试")
                    onClicked: {
                        console.log("=== 开始媒体库功能测试 ===")
                        refreshMedia()
                        testFiltering()
                        console.log("=== 测试完成 ===")
                    }
                }
                QGCButton {
                    text: qsTr("关闭")
                    onClicked: {
                        // 发送关闭信号给父级
                        root.closeRequested()
                    }
                }
            }

            // 状态栏 - 显示调试信息
            Rectangle {
                id: statusBar
                height: ScreenTools.defaultFontPixelHeight * 1.5
                color: qgcPal.windowShade
                Layout.fillWidth: true
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: ScreenTools.defaultFontPixelHeight / 4
                    
                    QGCLabel {
                        text: qsTr("本地文件: %1").arg(statusBar.localFileCount)
                    }
                    QGCLabel {
                        text: qsTr("飞行器文件: %1").arg(statusBar.vehicleFileCount)
                    }
                    QGCLabel {
                        text: qsTr("当前筛选: %1").arg(currentFilter)
                    }
                    QGCLabel {
                        text: qsTr("选中: %1").arg(selectedFiles.length)
                    }
                }
                
                property int localFileCount: 0
                property int vehicleFileCount: 0
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
                        color: selectedFiles.includes(modelData.filePath) ? qgcPal.highlight : qgcPal.window
                        border.color: selectedFiles.includes(modelData.filePath) ? qgcPal.highlight : qgcPal.windowText
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
                                    id: mediaImage
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    // 使用thumbnailPath而不是直接使用filePath
                                    source: modelData.thumbnailPath
                                    fillMode: modelData.isVideo ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: 120
                                    sourceSize.height: 120
                                    
                                    // 添加状态监控
                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            console.log("缩略图加载失败:", source)
                                            // 视频文件显示默认图标
                                            if (modelData.isVideo) {
                                                source = "qrc:/qmlimages/video.svg"
                                            } else {
                                                source = "qrc:/qmlimages/image.svg"
                                            }
                                        } else if (status === Image.Ready) {
                                            console.log("缩略图加载成功:", source)
                                        }
                                    }
                                }

                                // 添加加载占位符
                                Rectangle {
                                    anchors.fill: parent
                                    color: qgcPal.windowShade
                                    visible: mediaImage.status !== Image.Ready && !modelData.isVideo
                                    
                                    QGCLabel {
                                        anchors.centerIn: parent
                                        text: modelData.isVideo ? "视频" : "图片"
                                        color: qgcPal.text
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

    // 视频预览对话框
    Dialog {
        id: videoPreviewDialog
        title: qsTr("视频预览")
        x: (mediaGrid.width - width) / 2
        y: (mediaGrid.height - height) / 2
        width: Math.min(ScreenTools.defaultFontPixelWidth * 40, parent.width * 0.8)
        height: Math.min(ScreenTools.defaultFontPixelHeight * 30, parent.height * 0.8)
        
        modal: true
        standardButtons: Dialog.Close
        
        property string source
        
        Video {
            id: videoPlayer
            anchors.fill: parent
            anchors.margins: 10
            source: videoPreviewDialog.source
            autoPlay: true
            focus: true
            
            Keys.onEscapePressed: videoPreviewDialog.close()
            Keys.onBackPressed: videoPreviewDialog.close()
            
            // 修复：使用正确的Video组件信号
            onPlaying: {
                console.log("视频正在播放:", source)
            }
            
            onPaused: {
                console.log("视频已暂停:", source)
            }
            
            onStopped: {
                console.log("视频已停止:", source)
            }
            
            onPlaybackStateChanged: {
                if(playbackState === Video.StoppedState) {
                    console.log("视频停止播放");
                } else if(playbackState === Video.PlayingState) {
                    console.log("视频正在播放");
                } else if(playbackState === Video.PausedState) {
                    console.log("视频暂停播放");
                }
            }
        }
    }

    // 图片预览对话框
    Dialog {
        id: imagePreviewDialog
        title: qsTr("图片预览")
        x: (mediaGrid.width - width) / 2
        y: (mediaGrid.height - height) / 2
        width: Math.min(ScreenTools.defaultFontPixelWidth * 40, parent.width * 0.8)
        height: Math.min(ScreenTools.defaultFontPixelHeight * 30, parent.height * 0.8)
        
        modal: true
        standardButtons: Dialog.Close
        
        property string source
        
        Image {
            id: previewImage
            anchors.fill: parent
            anchors.margins: 10
            source: imagePreviewDialog.source
            fillMode: Image.PreserveAspectFit
            smooth: true
            cache: false
            
            Keys.onEscapePressed: imagePreviewDialog.close()
            Keys.onBackPressed: imagePreviewDialog.close()
            
            onStatusChanged: {
                if (status === Image.Ready) {
                    console.log("图片预览加载成功:", source)
                } else if (status === Image.Error) {
                    console.log("图片预览加载失败:", source)
                }
            }
        }
    }

    // 文件对话框 - 用于导出
    Labs.FolderDialog {
        id: exportFolderDialog
        title: qsTr("选择导出目录")
        onAccepted: performExport(folder)
    }

    // 超时检测定时器
    Timer {
        id: vehicleMediaTimer
        interval: 10000 // 10秒超时
        onTriggered: {
            console.log("警告: 飞行器媒体请求超时")
            statusBar.vehicleFileCount = 0
        }
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

    function validatePaths() {
        console.log("=== 验证关键路径 ===")
        
        // 检查应用保存路径
        var savePath = QGroundControl.settingsManager.appSettings.savePath.rawValue
        console.log("应用保存路径:", savePath)
        
        // 尝试多种可能的路径属性名称
        var picturesPath = undefined;
        var moviesPath = undefined;
        var logsSavePath = undefined;
        
        // 检查 settingsManager 结构
        if (QGroundControl.settingsManager && QGroundControl.settingsManager.appSettings) {
            var appSettings = QGroundControl.settingsManager.appSettings;
            
            // 尝试不同的可能属性名
            if ('picturesPath' in appSettings) {
                picturesPath = appSettings.picturesPath;
            } else if ('picturesLocation' in appSettings) {
                picturesPath = appSettings.picturesLocation;
            } else if ('photoSavePath' in appSettings) {
                picturesPath = appSettings.photoSavePath;
            } else if ('photoPath' in appSettings) {
                picturesPath = appSettings.photoPath;
            }
            
            if ('moviesPath' in appSettings) {
                moviesPath = appSettings.moviesPath;
            } else if ('videosPath' in appSettings) {
                moviesPath = appSettings.videosPath;
            } else if ('videoSavePath' in appSettings) {
                moviesPath = appSettings.videoSavePath;
            } else if ('videoPath' in appSettings) {
                moviesPath = appSettings.videoPath;
            }
            
            if ('logsSavePath' in appSettings) {
                logsSavePath = appSettings.logsSavePath;
            } else if ('logSavePath' in appSettings) {
                logsSavePath = appSettings.logSavePath;
            } else if ('missionSavePath' in appSettings) {
                logsSavePath = appSettings.missionSavePath;
            }
        }
        
        console.log("图片路径:", picturesPath)
        console.log("视频路径:", moviesPath)
        console.log("日志保存路径:", logsSavePath)
        
        return {
            savePath: savePath,
            picturesPath: picturesPath,
            moviesPath: moviesPath,
            logsSavePath: logsSavePath
        }
    }

    function validateImagePath(filePath) {
        console.log("验证图片路径:", filePath)
        
        // 检查路径格式
        if (!filePath.startsWith("file://") && !filePath.startsWith("qrc://")) {
            console.log("路径格式错误，需要添加file://前缀")
            // Windows路径需要特殊处理
            if (filePath.startsWith("/")) {
                return "file://" + filePath
            } else {
                return "file:///" + filePath
            }
        }
        
        return filePath
    }

    function validateFilePath(filePath, fileDialogController) {
        console.log("验证文件路径:", filePath)
        
        // 移除file://前缀进行文件存在性检查
        var localPath = filePath.replace("file:///", "")
        
        // 通过实例调用fileExists方法
        if (fileDialogController && typeof fileDialogController.fileExists === 'function') {
            var exists = fileDialogController.fileExists(localPath)
            console.log("文件是否存在:", exists)
            
            if (!exists) {
                console.log("错误: 文件不存在 -", localPath)
            }
            
            return exists
        } else {
            console.log("fileDialogController.fileExists方法不可用")
            // 如果方法不可用，则假设文件存在
            return true
        }
    }

    // 修复视频文件路径 - 确保视频文件路径构建正确
    function scanLocalMedia() {
        console.log("=== 开始扫描本地媒体文件 ===")
        
        try {
            // 获取正确的媒体保存路径 - 使用QGC的设置
            var videoPath = QGroundControl.settingsManager.appSettings.videoSavePath
            var imagePath = QGroundControl.settingsManager.appSettings.photoSavePath
            
            console.log("视频路径:", videoPath)
            console.log("图片路径:", imagePath)
            
            // 使用QGC的文件对话框控制器来访问文件
            var fileDialogController = Qt.createQmlObject("import QGroundControl.Controllers 1.0; QGCFileDialogController {}", root, "fileDialogController");
            
            if (fileDialogController) {
                // 扫描视频文件
                var videoExtensions = ["*.mp4", "*.mov", "*.avi", "*.mkv", "*.wmv", "*.flv", "*.webm"]
                var videoFiles = fileDialogController.getFiles(videoPath, videoExtensions)
                
                console.log("在视频路径找到", videoFiles.length, "个视频文件")
                
                // 处理视频文件 - 使用fullyQualifiedFilename构建完整路径
                for (var i = 0; i < videoFiles.length; i++) {
                    // 使用fullyQualifiedFilename构建完整路径
                    var fullVideoPath = fileDialogController.fullyQualifiedFilename(videoPath, videoFiles[i], videoExtensions)
                    
                    console.log("视频文件完整路径:", fullVideoPath)
                    
                    mediaList.push({
                        filePath: "file:///" + fullVideoPath,
                        fileName: videoFiles[i],
                        isVideo: true,
                        isLocal: true,
                        thumbnailPath: "qrc:/qmlimages/video.svg"  // 使用默认视频图标
                    })
                }

                // 扫描图片文件
                var imageExtensions = ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.webp"]
                var imageFiles = fileDialogController.getFiles(imagePath, imageExtensions)
                
                console.log("在图片路径找到", imageFiles.length, "个图片文件")
                
                // 处理图片文件 - 使用fullyQualifiedFilename构建完整路径
                for (var j = 0; j < imageFiles.length; j++) {
                    // 使用fullyQualifiedFilename构建完整路径
                    var fullImagePath = fileDialogController.fullyQualifiedFilename(imagePath, imageFiles[j], imageExtensions)
                    
                    console.log("图片文件完整路径:", fullImagePath)
                    
                    mediaList.push({
                        filePath: "file:///" + fullImagePath,
                        fileName: imageFiles[j],
                        isVideo: false,
                        isLocal: true,
                        thumbnailPath: "file:///" + fullImagePath  // 图片直接显示
                    })
                }
                
                // 更新状态计数
                statusBar.localFileCount = imageFiles.length + videoFiles.length
                console.log("本地文件总数:", imageFiles.length + videoFiles.length)
            } else {
                console.log("错误: 无法创建QGCFileDialogController实例")
            }
        } catch (e) {
            console.log("扫描本地媒体时出错: " + e.message)
            console.log("错误堆栈:", e.stack)
        }
        
        console.log("=== 本地媒体扫描完成 ===")
    }

    function requestVehicleMedia() {
        console.log("=== 请求飞行器媒体 ===")
        
        try {
            if (QGroundControl.multiVehicleManager && QGroundControl.multiVehicleManager.activeVehicle) {
                var vehicle = QGroundControl.multiVehicleManager.activeVehicle;
                console.log("飞行器已连接:", !vehicle.communicationLost)
                
                if (vehicle && vehicle.cameraManager) {
                    console.log("相机管理器可用:", vehicle.cameraManager !== null)
                    console.log("相机数量:", vehicle.cameraManager.cameras.count)
                    
                    // 由于QGCCameraManager没有直接提供媒体列表，我们需要使用其他方式
                    // 这里只是占位符，实际需要根据MAVLink协议实现
                    // 或者依赖于飞行器提供的存储信息
                } else {
                    console.log("错误: 飞行器没有相机管理器")
                }
            } else {
                console.log("错误: 没有活跃的飞行器")
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
                    var fileName = sourceFile.split('/').pop().split('\\').pop() // 处理Windows和Unix路径
                    var destFile = folder.toString() + "/" + fileName

                    console.log("正在导出文件:", sourceFile, "到", destFile)
                    
                    // 尝试复制文件 - 使用QGC的文件操作接口
                    if (fileDialogController.copyFile(sourceFile.replace("file:///", ""), destFile.replace("file:///", ""))) {
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

    // 添加视频预览功能 - 实现视频预览功能，当双击视频时使用QGC的视频播放器
    function openPreview(item) {
        console.log("预览文件:", item.filePath)
        
        if (item.isVideo) {
            // 播放视频 - 使用Video组件
            console.log("播放视频:", item.filePath)
            
            // 打开视频播放器对话框
            videoPreviewDialog.source = item.filePath
            videoPreviewDialog.open()
        } else {
            // 图片预览
            console.log("预览图片:", item.filePath)
            
            // 打开图片预览对话框
            imagePreviewDialog.source = item.filePath
            imagePreviewDialog.open()
        }
    }

    function testFiltering() {
        console.log("=== 测试文件过滤功能 ===")
        
        var allCount = mediaList.length
        var videoCount = mediaList.filter(function(item) { return item.isVideo }).length
        var imageCount = mediaList.filter(function(item) { return !item.isVideo }).length
        
        console.log("总文件数:", allCount)
        console.log("视频文件数:", videoCount)
        console.log("图片文件数:", imageCount)
        
        // 测试各种过滤模式
        setFilter("all")
        console.log("全部模式显示数量:", filteredList.length)
        
        setFilter("video")
        console.log("视频模式显示数量:", filteredList.length)
        
        setFilter("image")
        console.log("图片模式显示数量:", filteredList.length)
        
        // 恢复到全部模式
        setFilter("all")
    }

    Component.onCompleted: {
        console.log("=== 媒体库初始化检测开始 ===")
        
        // 验证路径
        var paths = validatePaths()
        
        // 检查VideoManager状态
        console.log("VideoManager可用:", QGroundControl.videoManager !== null)
        
        // 刷新媒体
        refreshMedia()
        
        // 测试过滤
        testFiltering()
        
        console.log("=== 媒体库初始化检测完成 ===")
    }
}