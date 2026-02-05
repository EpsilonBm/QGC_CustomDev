/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models

import QGroundControl
import QGroundControl.Controls

// 工具栏动作列表 - 包含飞行相关的各种控制按钮
ToolStripActionList {
    id: _root

    // 定义显示预检查清单的信号
    signal displayPreFlightChecklist

    // 定义工具栏上的各个动作项
    model: [
        // 3D视图切换按钮 - 根据3D窗口状态动态改变图标和文字
        ToolStripAction {
            property bool _is3DViewOpen:            viewer3DWindow.isOpen      // 检查3D视图是否打开
            property bool   _viewer3DEnabled:       QGroundControl.settingsManager.viewer3DSettings.enabled.rawValue // 检查3D视图功能是否启用

            id: view3DIcon
            visible: _viewer3DEnabled               // 根据设置决定是否显示此按钮
            text:           qsTr("3D View")         // 默认显示"3D视图"
            iconSource:     "/qmlimages/Viewer3D/City3DMapIcon.svg"  // 默认图标为城市3D地图图标
            onTriggered:{
                // 点击时根据当前3D视图状态进行开关切换
                if(_is3DViewOpen === false){
                    viewer3DWindow.open()
                }else{
                    viewer3DWindow.close()
                }
            }

            // 监听3D视图状态变化，动态更新按钮图标和文本
            on_Is3DViewOpenChanged: {
                if(_is3DViewOpen === true){
                    view3DIcon.iconSource =     "/qmlimages/PaperPlane.svg"  // 打开状态下显示纸飞机图标
                    text=           qsTr("Fly")                               // 打开状态下显示"飞行"文字
                }else{
                    iconSource =     "/qmlimages/Viewer3D/City3DMapIcon.svg" // 关闭状态下恢复3D视图图标
                    text =           qsTr("3D View")                         // 关闭状态下显示"3D视图"文字
                }
            }
        },
        // 预飞行检查清单显示动作 - 触发时发出显示预检查清单信号
        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        // 引导模式下的起飞动作
        GuidedActionTakeoff { },
        // 引导模式下的降落动作
        GuidedActionLand { },
        // 引导模式下的返航着陆(RTL)动作
        GuidedActionRTL { },
        // 引导模式下的暂停动作
        GuidedActionPause { },
        // 飞行视图附加动作按钮
        FlyViewAdditionalActionsButton { },
        // 引导模式下的机械臂夹爪控制动作(如适用)
        GuidedActionGripper { }
    ]
}
