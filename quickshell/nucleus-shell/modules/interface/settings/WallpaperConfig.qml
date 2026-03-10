import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {

    property string displayName: root.screen?.name ?? ""

    property var intervalOptions: [{
        "value": 5, "label": "5 minutes"
    },{
        "value": 15, "label": "15 minutes"
    },{
        "value": 30, "label": "30 minutes"
    },{
        "value": 60, "label": "1 hour"
    },{
        "value": 120, "label": "2 hours"
    },{
        "value": 360, "label": "6 hours"
    }]

    function getIntervalIndex(minutes) {
        for (let i = 0; i < intervalOptions.length; i++) {
            if (intervalOptions[i].value === minutes)
                return i
        }
        return 0
    }

    title: "Wallpaper"
    description: "Manage your wallpapers"

    ContentCard {

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            StyledText {
                text: "Current Wallpaper"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            ClippingRectangle {
                id: wpContainer

                Layout.fillWidth: true
                Layout.preferredHeight: width * 9 / 16
                Layout.alignment: Qt.AlignHCenter

                radius: Metrics.radius("unsharpenmore")
                color: Appearance.m3colors.m3surfaceContainer
                clip: true

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    cache: true

                    property string previewImg: {
                        const displays = Config.runtime.monitors
                        const fallback = Config.runtime.appearance.background.defaultPath

                        if (!displays)
                            return fallback

                        const monitor = displays?.[displayName]
                        return monitor?.wallpaper ?? fallback
                    }

                    source: previewImg + "?t=" + Date.now()
                    opacity: Config.runtime.appearance.background.enabled ? 1 : 0

                    Behavior on opacity { Anim {} }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "Wallpaper Manager Disabled"
                    font.pixelSize: Metrics.fontSize("title")

                    opacity: !Config.runtime.appearance.background.enabled ? 1 : 0

                    Behavior on opacity { Anim {} }
                }
            }

            StyledButton {
                icon: "wallpaper"
                text: "Change Wallpaper"
                Layout.fillWidth: true

                onClicked: {
                    Quickshell.execDetached([
                        "nucleus","ipc","call","background","change"
                    ])
                }
            }

            StyledSwitchOption {
                title: "Enabled"
                description: "Enable or disable the wallpaper daemon."
                prefField: "appearance.background.enabled"
            }
        }
    }

    ContentCard {

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            StyledText {
                text: "Parallax Effect"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            StyledSwitchOption {
                title: "Enabled"
                description: "Enable or disable wallpaper parallax effect."
                prefField: "appearance.background.parallax.enabled"
            }

            StyledSwitchOption {
                title: "Enabled for Sidebar Left"
                description: "Show parallax when sidebarLeft opens."
                prefField: "appearance.background.parallax.enableSidebarLeft"
            }

            StyledSwitchOption {
                title: "Enabled for Sidebar Right"
                description: "Show parallax when sidebarRight opens."
                prefField: "appearance.background.parallax.enableSidebarRight"
            }

            NumberStepper {
                label: "Zoom Amount"
                description: "Adjust the zoom of the parallax effect."
                prefField: "appearance.background.parallax.zoom"
                step: 0.1
                minimum: 1.10
                maximum: 2
            }
        }
    }

    ContentCard {

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(16)

            StyledText {
                text: "Wallpaper Slideshow"
                font.pixelSize: Metrics.fontSize("big")
                font.bold: true
            }

            StyledSwitchOption {
                title: "Enable Slideshow"
                description: "Automatically rotate wallpapers."
                prefField: "appearance.background.slideshow.enabled"
            }

            StyledSwitchOption {
                title: "Include Subfolders"
                description: "Search wallpapers in subfolders."
                prefField: "appearance.background.slideshow.includeSubfolders"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(12)

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Wallpaper Folder"
                        font.pixelSize: Metrics.fontSize("normal")
                    }

                    StyledText {
                        text: Config.runtime.appearance.background.slideshow.folder || "No folder selected"
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }

                StyledButton {
                    icon: "folder_open"
                    text: "Browse"
                    onClicked: folderPickerProc.running = true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(12)

                ColumnLayout {

                    StyledText {
                        text: "Skip To Next Wallpaper"
                        font.pixelSize: Metrics.fontSize("normal")
                    }

                    StyledText {
                        text: "Skip to the next wallpaper in the directory."
                        font.pixelSize: Metrics.fontSize("small")
                    }
                }

                Item { Layout.fillWidth: true }

                StyledButton {
                    icon: "skip_next"
                    text: "Skip"
                    enabled: WallpaperSlideshow.wallpapers.length > 0

                    onClicked: {
                        Quickshell.execDetached([
                            "nucleus","ipc","call","background","next"
                        ])
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Metrics.spacing(12)

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Change Interval"
                        font.pixelSize: Metrics.fontSize("normal")
                    }

                    StyledText {
                        text: "How often the wallpaper changes."
                        font.pixelSize: Metrics.fontSize("small")
                        color: Appearance.m3colors.m3onSurfaceVariant
                    }
                }

                StyledDropDown {
                    label: "Interval"
                    model: intervalOptions.map(opt => opt.label)
                    currentIndex: getIntervalIndex(Config.runtime.appearance.background.slideshow.interval)

                    onSelectedIndexChanged: (index) => {
                        Config.updateKey(
                            "appearance.background.slideshow.interval",
                            intervalOptions[index].value
                        )
                    }
                }
            }
        }
    }

    Process {
        id: folderPickerProc

        command: [
            "bash",
            Directories.scriptsPath + "/interface/selectfolder.sh",
            Config.runtime.appearance.background.slideshow.folder || Directories.pictures
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                if (out !== "null" && out.length > 0)
                    Config.updateKey("appearance.background.slideshow.folder", out)
            }
        }
    }

    component Anim: NumberAnimation {
        duration: Metrics.chronoDuration(400)
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animation.curves.standard
    }
}
