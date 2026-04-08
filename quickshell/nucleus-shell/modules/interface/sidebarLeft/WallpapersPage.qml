import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.functions
import qs.services
import qs.config
import qs.modules.components

Item {
    id: wallpapersPage
    property string displayName: screen?.name ?? ""

    readonly property string rawFolder:
        Config.runtime.appearance.background.slideshow.folder ?? ""

    readonly property string wallpaperFolder: {
        if (rawFolder === "")
            return StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/Wallpapers"
        if (rawFolder.startsWith("file://"))
            return rawFolder
        return "file://" + rawFolder
    }

    FolderListModel {
        id: wallpaperModel
        folder: wallpapersPage.wallpaperFolder
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.mp4", "*.mkv", "*.webm", "*.avi", "*.mov", "*.flv", "*.wmv", "*.m4v"]
        showDirs: false
        showDotAndDotDot: false
        showHidden: false
    }

    // DEBUG: uncomment if still not working to see what path is being used
    // Component.onCompleted: console.log("Wallpaper folder:", wallpaperFolder, "Count:", wallpaperModel.count)

    // EMPTY STATE
    Column {
        visible: wallpaperModel.count === 0
        anchors.centerIn: parent
        spacing: 8

        StyledText {
            horizontalAlignment: Text.AlignHCenter
            text: "No wallpapers found"
            color: Appearance.m3colors.m3onSurfaceVariant
            font.pixelSize: Appearance.font.size.large
        }
        StyledText {
            horizontalAlignment: Text.AlignHCenter
            text: wallpapersPage.rawFolder !== ""
                ? "Folder: " + wallpapersPage.rawFolder
                : "Select a wallpaper folder in Settings"
            color: Appearance.m3colors.m3onSurfaceVariant
            font.pixelSize: Appearance.font.size.small
        }
    }

    // WALLPAPER LIST
    ListView {
        anchors.topMargin: 90
        visible: wallpaperModel.count > 0
        anchors.fill: parent
        model: wallpaperModel
        spacing: Appearance.margin.normal
        clip: true
        delegate: Item {
            width: ListView.view.width
            height: 240

            StyledRect {
                id: imgContainer

                property bool activeWallpaper:
                    Config.runtime.monitors?.[wallpapersPage.displayName]?.wallpaper === fileUrl

                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                radius: Appearance.rounding.normal
                color: activeWallpaper
                    ? Appearance.m3colors.m3secondaryContainer
                    : Appearance.m3colors.m3surfaceContainerLow

                layer.enabled: true

                Image {
                    id: wallImg
                    anchors.fill: parent
                    source: fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    clip: true
                }

                // Active indicator badge
                Rectangle {
                    visible: imgContainer.activeWallpaper
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 10
                    width: 28
                    height: 28
                    radius: 14
                    color: Appearance.m3colors.m3primary

                    StyledText {
                        anchors.centerIn: parent
                        text: "✓"
                        color: Appearance.m3colors.m3onPrimary
                        font.pixelSize: Appearance.font.size.small
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "Unsupported / Corrupted Image"
                    visible: wallImg.status === Image.Error
                }

                // Filename label at bottom
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 32
                    color: Qt.rgba(0, 0, 0, 0.45)
                    visible: wallImg.status === Image.Ready

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: fileName
                        color: "#ffffff"
                        font.pixelSize: Appearance.font.size.small
                        elide: Text.ElideMiddle
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Config.updateKey(
                            "monitors." + wallpapersPage.displayName + ".wallpaper",
                            fileUrl
                        )
                        if (Config.runtime.appearance.colors.autogenerated) {
                            Quickshell.execDetached([
                                "nucleus", "ipc", "call", "global", "regenColors"
                            ])
                        }
                    }
                }

                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: imgContainer.width
                        height: imgContainer.height
                        radius: imgContainer.radius
                    }
                }
            }
        }
    }
}
