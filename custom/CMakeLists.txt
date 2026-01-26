message(STATUS "QGC: Adding Custom Plugin")

# Enable custom build
set_property(DIRECTORY ${CMAKE_SOURCE_DIR}
    APPEND PROPERTY COMPILE_DEFINITIONS
    QGC_CUSTOM_BUILD
    CUSTOMHEADER="CustomPlugin.h"
    CUSTOMCLASS=CustomPlugin
)

if(ANDROID)
    set(CUSTOM_ANDROID_DIR "${CMAKE_SOURCE_DIR}/custom/android")
    if(EXISTS "${CUSTOM_ANDROID_DIR}")
        file(GLOB CUSTOM_ANDROID_FILES "${CUSTOM_ANDROID_DIR}/*")
        if(CUSTOM_ANDROID_FILES)
            message(STATUS "QGC: Custom Android package template found. Overlaying custom files...")
            set(DEFAULT_ANDROID_DIR "${CMAKE_SOURCE_DIR}/android")
            set(FINAL_ANDROID_DIR "${CMAKE_BINARY_DIR}/custom/android")
            file(COPY "${DEFAULT_ANDROID_DIR}/." DESTINATION "${FINAL_ANDROID_DIR}")
            file(COPY "${CUSTOM_ANDROID_DIR}/." DESTINATION "${FINAL_ANDROID_DIR}")
            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                            "${DEFAULT_ANDROID_DIR}/"
                            "${CUSTOM_ANDROID_DIR}/"
                        )
            set(QGC_ANDROID_PACKAGE_SOURCE_DIR "${FINAL_ANDROID_DIR}" CACHE PATH "Path to a custom Android package template" FORCE)
            message(STATUS "QGC: Android package template path will be set to: ${QGC_ANDROID_PACKAGE_SOURCE_DIR}")
        else()
            message(STATUS "QGC: Custom Android package template empty. Using default.")
        endif()
    else()
        message(STATUS "QGC: No custom Android package template found. Using default.")
    endif()
endif()

# Our own, custom resources
list(APPEND CUSTOM_RESOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/custom.qrc
)
set(QGC_RESOURCES ${QGC_RESOURCES} ${CUSTOM_RESOURCES} CACHE STRING "Paths to .qrc Resources" FORCE)

set(QML_IMPORT_PATH ${QML_IMPORT_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/res" CACHE STRING "Extra qml import paths" FORCE)

qt_add_library(CustomModule STATIC)

set_source_files_properties(res/Custom/Widgets/CustomArtificialHorizon.qml PROPERTIES QT_RESOURCE_ALIAS CustomArtificialHorizon.qml)
set_source_files_properties(res/Custom/Widgets/CustomAttitudeWidget.qml PROPERTIES QT_RESOURCE_ALIAS CustomAttitudeWidget.qml)
set_source_files_properties(res/Custom/Widgets/CustomIconButton.qml PROPERTIES QT_RESOURCE_ALIAS CustomIconButton.qml)
set_source_files_properties(res/Custom/Widgets/CustomOnOffSwitch.qml PROPERTIES QT_RESOURCE_ALIAS CustomOnOffSwitch.qml)
set_source_files_properties(res/Custom/Widgets/CustomQuickButton.qml PROPERTIES QT_RESOURCE_ALIAS CustomQuickButton.qml)
set_source_files_properties(res/Custom/Widgets/CustomSignalStrength.qml PROPERTIES QT_RESOURCE_ALIAS CustomSignalStrength.qml)
set_source_files_properties(res/Custom/Widgets/CustomToolBarButton.qml PROPERTIES QT_RESOURCE_ALIAS CustomToolBarButton.qml)
set_source_files_properties(res/Custom/Widgets/CustomVehicleButton.qml PROPERTIES QT_RESOURCE_ALIAS CustomVehicleButton.qml)
set_source_files_properties(res/Custom/Widgets/CustomToolBarButton2.qml PROPERTIES QT_RESOURCE_ALIAS CustomToolBarButton2.qml)

qt_add_qml_module(CustomModule
    URI Custom.Widgets
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        res/Custom/Widgets/CustomArtificialHorizon.qml
        res/Custom/Widgets/CustomAttitudeWidget.qml
        res/Custom/Widgets/CustomIconButton.qml
        res/Custom/Widgets/CustomOnOffSwitch.qml
        res/Custom/Widgets/CustomQuickButton.qml
        res/Custom/Widgets/CustomSignalStrength.qml
        res/Custom/Widgets/CustomToolBarButton.qml
        res/Custom/Widgets/CustomVehicleButton.qml
        res/Custom/Widgets/CustomToolBarButton2.qml
    NO_PLUGIN
)

qt_add_library(CustomQmlControlsModule STATIC)

set_source_files_properties(src/CustomQmlControls/CustomToolbarIndicator.qml PROPERTIES QT_RESOURCE_ALIAS CustomToolbarIndicator.qml)
set_source_files_properties(src/CustomQmlControls/RCRSSIIndicator.qml PROPERTIES QT_RESOURCE_ALIAS RCRSSIIndicator.qml)
set_source_files_properties(src/CustomQmlControls/GPSIndicator.qml PROPERTIES QT_RESOURCE_ALIAS GPSIndicator.qml)
set_source_files_properties(src/CustomQmlControls/MessageIndicator.qml PROPERTIES QT_RESOURCE_ALIAS MessageIndicator)
set_source_files_properties(src/CustomQmlControls/FuelCellIndicator.qml PROPERTIES QT_RESOURCE_ALIAS FuelCellIndicator)

qt_add_qml_module(CustomQmlControlsModule
    URI Custom.QmlControls
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        src/CustomQmlControls/CustomToolbarIndicator.qml
        src/CustomQmlControls/RCRSSIIndicator.qml
        src/CustomQmlControls/GPSIndicator.qml
        src/CustomQmlControls/MessageIndicator.qml
        src/CustomQmlControls/FuelCellIndicator.qml
    NO_PLUGIN
)

qt_add_library(CustomToolStripModule STATIC)

set_source_files_properties(src/CustomToolStrip/CameraSwitch.qml PROPERTIES QT_RESOURCE_ALIAS CameraSwitch.qml)
set_source_files_properties(src/CustomToolStrip/LoadControl.qml PROPERTIES QT_RESOURCE_ALIAS LoadControl.qml)


qt_add_qml_module(CustomToolStripModule
    URI Custom.ToolStrip
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        src/CustomToolStrip/CameraSwitch.qml
        src/CustomToolStrip/LoadControl.qml
    NO_PLUGIN
)

qt_add_library(CustomFlyViewModule STATIC)

set_source_files_properties(src/CustomFlyView/CustomPanel.qml PROPERTIES QT_RESOURCE_ALIAS CustomPanel.qml)
set_source_files_properties(src/CustomFlyView/ValuesBar.qml PROPERTIES QT_RESOURCE_ALIAS ValuesBar.qml)

qt_add_qml_module(CustomFlyViewModule
    URI Custom.FlyView
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        src/CustomFlyView/CustomPanel.qml
        src/CustomFlyView/ValuesBar.qml
    NO_PLUGIN
)

set(CUSTOM_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomPlugin.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/CustomPlugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AutoPilotPlugin/CustomAutoPilotPlugin.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AutoPilotPlugin/CustomAutoPilotPlugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin/CustomFirmwarePlugin.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin/CustomFirmwarePlugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin/CustomFirmwarePluginFactory.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin/CustomFirmwarePluginFactory.h
        CACHE INTERNAL "" FORCE
)

set(CUSTOM_LIBRARIES
    CustomModule # Explicitly link QML module, needed by Qt 6.6.3, TODO: Remove when support for this version is dropped
    CustomQmlControlsModule
    CustomToolStripModule
    CustomFlyViewModule
    CACHE INTERNAL "" FORCE
)

set(CUSTOM_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AutoPilotPlugin
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FirmwarePlugin
    CACHE INTERNAL "" FORCE
)

# 在custom/CMakeLists.txt中，移除对common目录的包含
list(APPEND CUSTOM_INCLUDE_DIRECTORIES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/mavlink/generated/custom_messages  # 只包含自定义消息
    CACHE INTERNAL "" FORCE
)
