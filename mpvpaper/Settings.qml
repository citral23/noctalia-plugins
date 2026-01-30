import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null

    property bool active:
        pluginApi?.pluginSettings?.active ||
        false

    property string wallpapersFolder: 
        pluginApi?.pluginSettings?.wallpapersFolder ||
        pluginApi?.manifest?.metadata?.defaultSettings?.wallpapersFolder ||
        "~/Pictures/Wallpapers"

    property string currentWallpaper: 
        pluginApi?.pluginSettings?.currentWallpaper || 
        ""

    property string mpvSocket: 
        pluginApi?.pluginSettings?.mpvSocket || 
        pluginApi?.manifest?.metadata?.defaultSettings?.mpvSocket || 
        "/tmp/mpv-socket"

    spacing: Style.marginM
    
    // Active toggle
    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.toggle.label") || "Enable mpvpaper"
        description: pluginApi?.tr("settings.toggle.description") || "Enable the mpvpaper integration"
        checked: root.active
        onToggled: checked => root.active = checked
    }
    
    // Wallpaper Folder
    ColumnLayout {
        NLabel {
            enabled: root.active
            label: pluginApi?.tr("settings.wallpapers_folder.title_label") || "Wallpapers Folder"
            description: pluginApi?.tr("settings.wallpapers_folder.title_description") || "The folder that contains all the wallpapers, useful when using random wallpaper"
        }

        RowLayout {
            NTextInput {
                enabled: root.active
                Layout.fillWidth: true
                placeholderText: pluginApi?.tr("settings.wallpapers_folder.input_placeholder") || "/path/to/folder/with/wallpapers"
                text: root.wallpapersFolder
                onTextChanged: root.wallpapersFolder = text
            }

            NIconButton {
                enabled: root.active
                icon: "wallpaper-selector"
                tooltipText: pluginApi?.tr("settings.wallpapers_folder.icon_tooltip") || "Select wallpapers folder"
                onClicked: wallpapersFolderPicker.openFilePicker()
            }

            NFilePicker {
                id: wallpapersFolderPicker
                title: pluginApi?.tr("settings.wallpapers_folder.file_picker_title") || "Choose wallpapers folder"
                initialPath: root.wallpapersFolder
                selectionMode: "folders"

                onAccepted: paths => {
                    if (paths.length > 0) {
                        Logger.d("mpvpaper", "Selected the following wallpaper folder:", paths[0]);
                        root.wallpapersFolder = paths[0];
                    }
                }
            }
        }
    }

    // Current Wallpaper
    ColumnLayout {
        NLabel {
            enabled: root.active
            label: pluginApi?.tr("settings.current_wallpaper.title_label") || "Current Wallpaper"
            description: pluginApi?.tr("settings.current_wallpaper.title_description") || "The current wallpaper that is shown"
        }

        RowLayout {
            NTextInput {
                enabled: root.active
                Layout.fillWidth: true
                placeholderText: pluginApi?.tr("settings.current_wallpaper.input_placeholder") || "/path/to/wallpaper"
                text: root.currentWallpaper
                onTextChanged: root.currentWallpaper = text
            }

            NIconButton {
                enabled: root.active
                icon: "wallpaper-selector"
                tooltipText: pluginApi?.tr("settings.current_wallpaper.icon_tooltip") || "Select current wallpaper"
                onClicked: currentWallpaperPicker.openFilePicker()
            }

            NFilePicker {
                id: currentWallpaperPicker
                title: pluginApi?.tr("settings.current_wallpaper.file_picker_title") || "Choose current wallpaper"
                initialPath: root.wallpapersFolder
                selectionMode: "files"

                onAccepted: paths => {
                    if (paths.length > 0) {
                        Logger.d("mpvpaper", "Selected the following current wallpaper:", paths[0]);
                        root.currentWallpaper = paths[0];
                    }
                }
            }
        }
    }
    
    // MPV Socket path
    ColumnLayout {
        NLabel {
            enabled: root.active
            label: pluginApi?.tr("settings.mpv_socket.title_label") || "Mpvpaper socket"
            description: pluginApi?.tr("settings.mpv_socket.title_description") || "The mpvpaper socket that noctalia connects to"
        }

        NTextInput {
            enabled: root.active
            Layout.fillWidth: true
            placeholderText: pluginApi?.tr("settings.mpv_socket.input_placeholder") || "Example: /tmp/mpv-socket"
            text: root.mpvSocket
            onTextChanged: root.mpvSocket = text
        }
    }


    RowLayout {
        NButton {
            enabled: root.active
            text: pluginApi?.tr("settings.actions.random") || "Random"
            onClicked: root.random()
        }

        NButton {
            enabled: root.active
            text: pluginApi?.tr("settings.actions.clear") || "Clear"
            onClicked: root.clear()
        }
    }

    function random() {
        if(pluginApi?.mainInstance == null) {
            Logger.e("mpvpaper", "Main instance isn't loaded");
            return;
        }

        pluginApi.mainInstance.random();
        root.currentWallpaper = pluginApi.pluginSettings.currentWallpaper;
    }

    function clear() {
        if(pluginApi?.mainInstance == null) {
            Logger.e("mpvpaper", "Main instance isn't loaded");
            return;
        }

        pluginApi.mainInstance.clear();
        root.currentWallpaper = pluginApi.pluginSettings.currentWallpaper;
    }

    function saveSettings() {
        if(!pluginApi) {
            Logger.e("mpvpaper", "Cannot save: pluginApi is null");
            return;
        }

        pluginApi.pluginSettings.active = active;
        pluginApi.pluginSettings.wallpapersFolder = wallpapersFolder;
        pluginApi.pluginSettings.currentWallpaper = currentWallpaper;
        pluginApi.pluginSettings.mpvSocket = mpvSocket;

        pluginApi.saveSettings();

        Logger.d("mpvpaper", "Settings saved");
    }
}
