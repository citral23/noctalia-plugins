import QtQuick
import QtQuick.Layouts

import qs.Commons
import qs.Widgets

import "./advanced"

ColumnLayout {
    id: root
    spacing: Style.marginM
    Layout.fillWidth: true


    /***************************
    * PROPERTIES
    ***************************/
    required property var pluginApi
    required property string activeBackend
    required property bool enabled

    property string fillMode: pluginApi?.pluginSettings?.fillMode || pluginApi?.manifest?.metadata?.defaultSettings?.fill_mode || ""

    readonly property list<string> backends: ["qt6-multimedia", "mpvpaper"]

    /***************************
    * COMPONENTS
    ***************************/
    // Fill Mode
    NComboBox {
        enabled: root.enabled
        Layout.fillWidth: true
        label: root.pluginApi?.tr("settings.advanced.fill_mode.label") || "Fill Mode"
        description: root.pluginApi?.tr("settings.advanced.fill_mode.description") || "The mode that the wallpaper is fitted into the background."
        defaultValue: "fit"
        model: [
            {
                "key": "fit",
                "name": root.pluginApi?.tr("settings.advanced.fill_mode.fit") || "Fit"
            },
            {
                "key": "crop",
                "name": root.pluginApi?.tr("settings.advanced.fill_mode.crop") || "Crop"
            },
            {
                "key": "stretch",
                "name": root.pluginApi?.tr("settings.advanced.fill_mode.stretch") || "Stretch"
            }
        ]
        currentKey: root.fillMode
        onSelected: key => root.fillMode = key
    }

    NTabView {
        currentIndex: root.backends.indexOf(root.activeBackend)

        VideoWallpaper {
            id: videoWallpaper
            pluginApi: root.pluginApi
            enabled: root.enabled
        }

        Mpvpaper {
            id: mpvpaper
            pluginApi: root.pluginApi
            enabled: root.enabled
        }

        NoBackend {
            pluginApi: root.pluginApi
            enabled: root.enabled
        }
    }

    Connections {
        target: root.pluginApi
        function onPluginSettingsChanged() {
            // Update the local properties on change
            root.fillMode = root.pluginApi?.pluginSettings?.fillMode || root.pluginApi?.manifest?.metadata?.defaultSettings?.fillMode || ""
        }
    }


    /********************************
    * Save settings functionality
    ********************************/
    function saveSettings() {
        if(pluginApi == null) {
            Logger.e("mpvpaper", "Cannot save: pluginApi is null");
            return;
        }

        videoWallpaper.saveSettings();
        mpvpaper.saveSettings();

        pluginApi.pluginSettings.fillMode = fillMode;
    }
}
