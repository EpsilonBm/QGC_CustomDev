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
    property int selectionUpdateCounter: 0
    
    // 存储视频缩略图生成器实例，避免重复创建
    property var thumbnailGenerators: ({})
    property int exportProgress: 0
    property bool isExporting: false

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
                    text: isExporting ? qsTr("导出中 %1%").arg(exportProgress) : qsTr("导出")
                    enabled: selectedFiles.length > 0 && !isExporting
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

                    delegate: Item {
                        width: mediaGrid.cellWidth
                        height: mediaGrid.cellHeight
                        
                        // 内容矩形
                        Rectangle {
                            id: contentRect
                            anchors.centerIn: parent
                            width: mediaGrid.cellWidth - 8  // 更小一点，让边框更明显
                            height: mediaGrid.cellHeight - 8
                            color: selectedFiles.includes(modelData.filePath) ? Qt.rgba(0.5, 0.5, 1.0, 0.3) : qgcPal.window  // 使用固定颜色避免undefined问题
                            radius: 4  // 略小于边框半径，确保不会覆盖边框圆角
                            border.color: "transparent"  // 移除内容矩形边框，只在外层边框矩形显示边框
                            border.width: 0  // 移除内容矩形边框，只在外层边框矩形显示边框

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
                                        // 使用更精确的条件处理空路径
                                        source: {
                                            if (modelData.isVideo) {
                                                if (modelData.thumbnailPath && modelData.thumbnailPath !== "" && modelData.thumbnailPath !== "qrc:/qmlimages/camera_video.svg") {
                                                    return modelData.thumbnailPath
                                                } else {
                                                    return "qrc:/qmlimages/camera_video.svg"
                                                }
                                            } else {
                                                return modelData.filePath
                                            }
                                        }
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
                                                    source = "qrc:/qmlimages/camera_video.svg"
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
                        }
                        
                        // 外层边框矩形 - 用于显示选中状态（放在最后以确保在最上层）
                        Rectangle {
                            id: borderRect
                            anchors.centerIn: parent
                            width: mediaGrid.cellWidth - 2
                            height: mediaGrid.cellHeight - 2
                            color: "transparent"
                            border.color: selectedFiles.includes(modelData.filePath) ? "white" : "#CCCCCC"
                            border.width: selectedFiles.includes(modelData.filePath) ? 3 : 1
                            radius: 5
                        }

                        // 内容矩形上的鼠标区域
                        MouseArea {
                            anchors.fill: contentRect
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
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width * 0.9, 1000)  // 与主界面相同宽度
        height: Math.min(parent.height * 0.9, 700)  // 与主界面相同高度
        
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
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(parent.width * 0.9, 1000)  // 与主界面相同宽度
        height: Math.min(parent.height * 0.9, 700)  // 与主界面相同高度
        
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

    // 隐藏的Video组件用于生成缩略图
    Video {
        id: thumbnailVideo
        visible: false
        autoPlay: false
          
        onPlaybackStateChanged: {
            if (playbackState === Video.PlayingState) {
                console.log("视频播放中，准备跳转到第1秒")
                Qt.callLater(function() {
                    thumbnailVideo.seek(1000) // 跳转到第1秒
                }, 1000) // 延迟1秒再seek，确保视频已准备好
            } else if (playbackState === Video.StoppedState) {
                console.log("视频已停止")
            } else if (playbackState === Video.PausedState) {
                console.log("视频已暂停")
            }
        }
        
        onPositionChanged: {
            // 当位置达到或超过1000ms时，说明seek已完成
            if (position >= 1000 && playbackState === Video.PlayingState) {
                console.log("跳转完成，准备截图，当前位置:", position)
                if (thumbnailVideo.seekable) {
                    thumbnailVideo.pause()
                    // 截取当前帧作为缩略图
                    thumbnailVideo.grabToImage(function(result) {
                        console.log("grabToImage 回调执行，结果:", !!result)
                        if (result) {
                            if (result.saveToFile(thumbnailVideo.thumbnailPath)) {
                                console.log("缩略图保存成功:", thumbnailVideo.thumbnailPath)
                                updateVideoThumbnail(thumbnailVideo.currentVideoPath, "file:///" + thumbnailVideo.thumbnailPath)
                            } else {
                                console.log("缩略图保存失败，使用默认图标")
                                // 只有在保存失败时才设置默认图标
                                updateVideoThumbnail(thumbnailVideo.currentVideoPath, "qrc:/qmlimages/camera_video.svg")
                            }
                        } else {
                            console.log("无法获取视频帧，使用默认图标")
                            // 只有在保存失败时才设置默认图标
                            updateVideoThumbnail(thumbnailVideo.currentVideoPath, "qrc:/qmlimages/camera_video.svg")
                        }
                        thumbnailVideo.source = "" // 清空源
                    })
                } else {
                    console.log("视频不支持跳转，使用默认图标")
                    updateVideoThumbnail(thumbnailVideo.currentVideoPath, "qrc:/qmlimages/camera_video.svg")
                }
            }
        }
        
        property string thumbnailPath: ""
        property string currentVideoPath: ""
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

    // 生成视频缩略图的函数
    function generateVideoThumbnail(videoPath) {
        console.log("开始生成视频缩略图:", videoPath)
        
        var localPath = videoPath.replace("file:///", "")
        var thumbnailPath = localPath.replace(/\.[^/.]+$/, "_thumb.jpg")
        
        console.log("缩略图路径:", thumbnailPath)
        
        thumbnailVideo.thumbnailPath = thumbnailPath
        thumbnailVideo.currentVideoPath = videoPath
        thumbnailVideo.source = videoPath
    }
    
    function updateVideoThumbnail(videoPath, thumbnailPath) {
        console.log("更新视频缩略图:", videoPath, "->", thumbnailPath)
        for (var i = 0; i < mediaList.length; i++) {
            if (mediaList[i].filePath === videoPath && mediaList[i].isVideo) {
                mediaList[i].thumbnailPath = thumbnailPath  // 直接使用传入的路径
                console.log("缩略图路径已更新:", mediaList[i].thumbnailPath)
                break
            }
        }
        console.log("准备刷新过滤列表")
        updateFilteredList() // 刷新显示
        console.log("过滤列表已刷新")
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
                    
                    // 生成缩略图路径
                    var fileNameWithoutExt = videoFiles[i].replace(/\.[^/.]+$/, "")
                    var thumbnailPath = videoPath
                    if (!thumbnailPath.endsWith('/') && !thumbnailPath.endsWith('\\')) {
                        thumbnailPath += "/"
                    }
                    thumbnailPath += fileNameWithoutExt + "_thumb.jpg"
                    
                    // 检查缩略图是否存在
                    var thumbnailExists = fileDialogController.fileExists(thumbnailPath)
                    
                    console.log("缩略图路径:", thumbnailPath, "存在:", thumbnailExists)
                    
                    // 重要：不要立即设置默认图标，先设置为空字符串
                    mediaList.push({
                        filePath: "file:///" + fullVideoPath,
                        fileName: videoFiles[i],
                        isVideo: true,
                        isLocal: true,
                        thumbnailPath: thumbnailExists ? "file:///" + thumbnailPath : ""  // 空字符串而不是默认图标
                    })
                    
                    // 只有当缩略图不存在时才生成
                    if (!thumbnailExists) {
                        console.log("缩略图不存在，开始生成:", fullVideoPath)
                        generateVideoThumbnail("file:///" + fullVideoPath)
                    } else {
                        console.log("缩略图已存在，使用现有缩略图:", thumbnailPath)
                    }
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
        
        // 通过重新分配数组来强制绑定更新
        selectedFiles = selectedFiles.slice()
    }

    function exportSelectedFiles() {
        if (selectedFiles.length === 0) {
            console.log("没有选中任何文件")
            return
        }
        exportFolderDialog.open()
    }

    // 跨平台文件复制函数  
    function copyFileNative(source, destination) {  
        // 使用QGC扩展的QGCFileDialogController.copyFile方法
        return QGCFileDialogController.copyFile(source, destination);
    }

    function performExport(folder) {
        if (!folder) {
            console.log("未选择导出目录");
            return;
        }
        
        if (isExporting) {
            console.log("正在导出中，请等待");
            return;
        }
        
        // 移动端路径处理
        if (ScreenTools.isMobile) {
            folder = QGCFileDialogController.fullFolderPathToShortMobilePath(folder)
        }
        
        isExporting = true;
        exportProgress = 0;
        
        console.log("开始导出", selectedFiles.length, "个文件到:", folder);
        
        for (var i = 0; i < selectedFiles.length; i++) {
            var sourceFile = selectedFiles[i].replace("file:///", "");
            var fileName = sourceFile.split('/').pop();
            var destFile = folder + "/" + fileName;
            
            console.log("导出进度:", (i + 1) + "/" + selectedFiles.length);
            
            if (QGCFileDialogController.copyFile(sourceFile, destFile)) {
                console.log("成功导出文件:", destFile);
            } else {
                console.log("导出文件失败:", sourceFile);
            }
            
            exportProgress = Math.round(((i + 1) / selectedFiles.length) * 100);
        }
        
        selectedFiles = [];
        isExporting = false;
        exportProgress = 0;
        updateFilteredList();
        
        console.log("导出完成");
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