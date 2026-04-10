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

    // Header with folder path
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 75
        height: 72
        color: "transparent"
        z: 10

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            StyledText {
                text: "Wallpapers"
                font.pixelSize: Appearance.font.size.larger
                font.weight: Font.Medium
                color: Appearance.m3colors.m3onSurface
            }

            RowLayout {
                spacing: 8
                
                StyledText {
                    text: wallpaperModel.count + " items"
                    font.pixelSize: Appearance.font.size.small
                    color: Appearance.m3colors.m3onSurfaceVariant
                    visible: wallpaperModel.count > 0
                }

                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    color: Appearance.m3colors.m3outline
                    visible: wallpaperModel.count > 0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: wallpapersPage.rawFolder !== "" 
                        ? wallpapersPage.rawFolder.split("/").pop() || wallpapersPage.rawFolder
                        : "~/Pictures/Wallpapers"
                    font.pixelSize: Appearance.font.size.small
                    color: Appearance.m3colors.m3onSurfaceVariant
                    elide: Text.ElideMiddle
                }
            }
        }

        // Bottom divider
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.bottomMargin: -10
            color: Appearance.m3colors.m3outlineVariant
            opacity: 0.5
        }
    }

    // Empty state
    Item {
        visible: wallpaperModel.count === 0
        anchors.fill: parent
        anchors.topMargin: header.height

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: Math.min(parent.width - 48, 320)

            // Icon container
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 88
                height: 88
                radius: 44
                color: Appearance.m3colors.m3surfaceContainerHighest

                StyledText {
                    anchors.centerIn: parent
                    text: "🖼️"
                    font.pixelSize: 36
                }
            }

            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "No wallpapers found"
                color: Appearance.m3colors.m3onSurface
                font.pixelSize: Appearance.font.size.large
                font.weight: Font.Medium
            }

            StyledText {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: wallpapersPage.rawFolder !== ""
                    ? "The folder appears to be empty or contains unsupported formats"
                    : "Select a wallpaper folder in Settings to get started"
                color: Appearance.m3colors.m3onSurfaceVariant
                font.pixelSize: Appearance.font.size.normal
                wrapMode: Text.WordWrap
                lineHeight: 1.4
            }

            // Action button
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: openFolderRow.width + 32
                height: 40
                radius: 20
                color: Appearance.m3colors.m3secondaryContainer

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Row {
                    id: openFolderRow
                    anchors.centerIn: parent
                    spacing: 8

                    StyledText {
                        text: "📁"
                        font.pixelSize: Appearance.font.size.normal
                    }

                    StyledText {
                        text: "Open Settings"
                        color: Appearance.m3colors.m3onSecondaryContainer
                        font.pixelSize: Appearance.font.size.normal
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.color = Appearance.m3colors.m3secondaryContainerHover ?? Qt.darker(Appearance.m3colors.m3secondaryContainer, 1.1)
                    onExited: parent.color = Appearance.m3colors.m3secondaryContainer
                    onClicked: {
                        // Navigate to settings - adjust this to your navigation system
                        console.log("Open settings clicked")
                    }
                }
            }
        }
    }

    // Wallpaper grid
    GridView {
        id: wallpaperGrid
        visible: wallpaperModel.count > 0
        anchors.fill: parent
        anchors.topMargin: header.height + 16 + 75
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 16

        model: wallpaperModel
        cellWidth: {
            const minWidth = 280
            const maxColumns = Math.floor((width) / minWidth)
            const columns = Math.max(1, maxColumns)
            return width / columns
        }
        cellHeight: cellWidth * 0.6 + 16

        clip: true
        cacheBuffer: 400

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 8

            contentItem: Rectangle {
                radius: 4
                color: Appearance.m3colors.m3outline
                opacity: parent.active ? 0.8 : 0.4

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }
        }

        delegate: Item {
            id: delegateRoot
            width: wallpaperGrid.cellWidth
            height: wallpaperGrid.cellHeight

            required property string fileName
            required property url fileUrl
            required property int index

            property bool isActive:
                Config.runtime.monitors?.[wallpapersPage.displayName]?.wallpaper === fileUrl
            property bool isHovered: false
            property bool isPressed: false

            // Card container
            Rectangle {
                id: card
                anchors.fill: parent
                anchors.margins: 8
                radius: Appearance.rounding.normal
                color: delegateRoot.isActive
                    ? Appearance.m3colors.m3secondaryContainer
                    : Appearance.m3colors.m3surfaceContainerLow

                border.width: delegateRoot.isActive ? 2 : 0
                border.color: Appearance.m3colors.m3primary

                // Elevation shadow
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: delegateRoot.isHovered ? 4 : 2
                    radius: delegateRoot.isHovered ? 12 : 6
                    samples: 25
                    color: Qt.rgba(0, 0, 0, delegateRoot.isHovered ? 0.15 : 0.1)

                    Behavior on verticalOffset {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on radius {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Behavior on border.width {
                    NumberAnimation { duration: 200 }
                }

                // Scale animation on hover
                transform: Scale {
                    origin.x: card.width / 2
                    origin.y: card.height / 2
                    xScale: delegateRoot.isPressed ? 0.98 : (delegateRoot.isHovered ? 1.02 : 1.0)
                    yScale: delegateRoot.isPressed ? 0.98 : (delegateRoot.isHovered ? 1.02 : 1.0)

                    Behavior on xScale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on yScale {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                // Image container with clipping
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true

                    Rectangle {
                        id: imageMask
                        anchors.fill: parent
                        radius: Appearance.rounding.normal - 2
                        visible: false
                    }

                    Image {
                        id: wallImg
                        anchors.fill: parent
                        source: delegateRoot.fileUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 600
                        sourceSize.height: 400

                        // Smooth fade-in
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: imageMask
                        }
                    }

                    // Loading placeholder
                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.normal - 2
                        color: Appearance.m3colors.m3surfaceContainerHighest
                        visible: wallImg.status === Image.Loading

                        // Shimmer effect
                        Rectangle {
                            id: shimmer
                            width: parent.width * 0.5
                            height: parent.height
                            color: Qt.rgba(1, 1, 1, 0.1)
                            visible: wallImg.status === Image.Loading

                            SequentialAnimation on x {
                                loops: Animation.Infinite
                                running: wallImg.status === Image.Loading
                                NumberAnimation {
                                    from: -shimmer.width
                                    to: shimmer.parent.width
                                    duration: 1200
                                    easing.type: Easing.InOutQuad
                                }
                                PauseAnimation { duration: 400 }
                            }
                        }
                    }

                    // Error state
                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.normal - 2
                        color: Appearance.m3colors.m3errorContainer
                        visible: wallImg.status === Image.Error

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "⚠️"
                                font.pixelSize: 24
                            }

                            StyledText {
                                text: "Unable to load"
                                color: Appearance.m3colors.m3onErrorContainer
                                font.pixelSize: Appearance.font.size.small
                            }
                        }
                    }

                    // Gradient overlay for filename
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 56
                        visible: wallImg.status === Image.Ready

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.3) }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: imageContainer.width
                                height: 56
                                radius: Appearance.rounding.normal - 2

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: parent.radius
                                    color: parent.color
                                }
                            }
                        }
                    }

                    StyledText {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        text: delegateRoot.fileName
                        color: "#ffffff"
                        font.pixelSize: Appearance.font.size.small
                        font.weight: Font.Medium
                        elide: Text.ElideMiddle
                        visible: wallImg.status === Image.Ready
                    }

                    Rectangle {
                        visible: delegateRoot.isActive
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 12
                        height: 28
                        width: activeRow.width + 16
                        radius: 14
                        color: Appearance.m3colors.m3primary

                        Row {
                            id: activeRow
                            anchors.centerIn: parent
                            spacing: 4

                            StyledText {
                                text: "✓"
                                color: Appearance.m3colors.m3onPrimary
                                font.pixelSize: Appearance.font.size.small
                                font.weight: Font.Bold
                            }

                            StyledText {
                                text: "Active"
                                color: Appearance.m3colors.m3onPrimary
                                font.pixelSize: Appearance.font.size.small
                                font.weight: Font.Medium
                            }
                        }

                        scale: delegateRoot.isActive ? 1 : 0
                        Behavior on scale {
                            NumberAnimation { 
                                duration: 300
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.5
                            }
                        }
                    }


                    Rectangle {
                        anchors.fill: parent
                        radius: Appearance.rounding.normal - 2
                        color: delegateRoot.isPressed 
                            ? Qt.rgba(0, 0, 0, 0.15)
                            : (delegateRoot.isHovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onEntered: delegateRoot.isHovered = true
                    onExited: {
                        delegateRoot.isHovered = false
                        delegateRoot.isPressed = false
                    }
                    onPressed: delegateRoot.isPressed = true
                    onReleased: delegateRoot.isPressed = false
                    onCanceled: delegateRoot.isPressed = false

                    onClicked: {
                        Config.updateKey(
                            "monitors." + wallpapersPage.displayName + ".wallpaper",
                            delegateRoot.fileUrl
                        )
                        if (Config.runtime.appearance.colors.autogenerated) {
                            Quickshell.execDetached([
                                "nucleus", "ipc", "call", "global", "regenColors"
                            ])
                        }
                    }
                }
            }
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1; duration: 300; easing.type: Easing.OutCubic }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.OutCubic }
        }
    }
}
