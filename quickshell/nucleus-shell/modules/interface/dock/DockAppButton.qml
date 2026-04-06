pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.components
import qs.config

Button {
    id: root

    required property var appToplevel
    property int lastFocused: -1
    property real iconSize: Config.runtime.dock?.iconSize ?? 40
    property real countDotWidth: 10
    property real countDotHeight: 4
    property string dockPosition: "bottom"

    readonly property bool isBottom: dockPosition === "bottom"
    readonly property bool isLeft: dockPosition === "left"
    readonly property bool isRight: dockPosition === "right"
    readonly property bool isVertical: isLeft || isRight

    readonly property bool isSeparator: appToplevel?.appId === "SEPARATOR"
    readonly property var desktopEntry: {
        if (isSeparator || !appToplevel) return null
        // Reading .values creates a reactive dependency so this re-evaluates when DesktopEntries finishes loading
        void DesktopEntries.applications.values.length
        return DesktopEntries.heuristicLookup(appToplevel.appId)
    }
    readonly property bool appIsActive: !isSeparator && (appToplevel?.toplevels?.some(t => t.activated === true) ?? false)
    readonly property bool appIsRunning: !isSeparator && (appToplevel?.toplevelCount ?? 0) > 0

    readonly property bool showIndicators: !isSeparator && (Config.runtime.dock?.showRunningIndicators ?? true) && appIsRunning
    readonly property int instanceCount: (isSeparator || !appToplevel) ? 0 : appToplevel.toplevelCount

    enabled: !isSeparator
    implicitWidth:  isSeparator ? (isVertical ? iconSize * 0.6 : 2) : iconSize + 8
    implicitHeight: isSeparator ? (isVertical ? 2 : iconSize * 0.6) : iconSize + 8

    padding: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    background: Item {
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: Metrics.radius(8)
            color: Appearance.m3colors.m3surfaceContainerHigh
            visible: !root.isSeparator && (root.hovered || root.pressed)
            opacity: root.pressed ? 1 : 0.7
            Behavior on opacity { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(150) } }
        }
    }

    contentItem: Item {
        // Separator
        Loader {
            active: root.isSeparator
            anchors.centerIn: parent
            sourceComponent: Rectangle {
                implicitWidth:  root.isVertical ? root.iconSize * 0.6 : 2
                implicitHeight: root.isVertical ? 2 : root.iconSize * 0.6
                color: Appearance.m3colors.m3outlineVariant
                radius: 1
            }
        }

        // App icon and indicators
        Loader {
            active: !root.isSeparator
            anchors.fill: parent
            sourceComponent: Item {
                anchors.fill: parent

                Item {
                    id: appIconContainer
                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize

                    readonly property string iconSource: {
                        if (root.desktopEntry && root.desktopEntry.icon)
                            return AppRegistry.iconForDesktopIcon(root.desktopEntry.icon)
                        return AppRegistry.iconForClass(root.appToplevel?.appId ?? "")
                    }

                    Image {
                        id: appIcon
                        anchors.fill: parent
                        source: appIconContainer.iconSource || Quickshell.iconPath("application-x-executable")
                        sourceSize.width: root.iconSize * 2
                        sourceSize.height: root.iconSize * 2
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }

                }

                // Running indicators - horizontal (bottom dock)
                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -2
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 3
                    visible: root.showIndicators && !root.isVertical

                    Repeater {
                        model: Math.min(root.instanceCount, 3)
                        delegate: Rectangle {
                            required property int index
                            width: root.instanceCount <= 3 ? root.countDotWidth : root.countDotHeight
                            height: root.countDotHeight
                            radius: height / 2
                            color: root.appIsActive ? Appearance.m3colors.m3primary : Qt.rgba(Appearance.m3colors.m3onSurface.r, Appearance.m3colors.m3onSurface.g, Appearance.m3colors.m3onSurface.b, 0.4)
                            Behavior on color { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation { duration: Metrics.chronoDuration(150) } }
                        }
                    }
                }

                // Running indicators - vertical (left/right dock)
                Column {
                    anchors.left: root.isLeft ? parent.left : undefined
                    anchors.leftMargin: -2
                    anchors.right: root.isRight ? parent.right : undefined
                    anchors.rightMargin: -2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    visible: root.showIndicators && root.isVertical

                    Repeater {
                        model: Math.min(root.instanceCount, 3)
                        delegate: Rectangle {
                            required property int index
                            width: root.countDotHeight
                            height: root.instanceCount <= 3 ? root.countDotWidth : root.countDotHeight
                            radius: width / 2
                            color: root.appIsActive ? Appearance.m3colors.m3primary : Qt.rgba(Appearance.m3colors.m3onSurface.r, Appearance.m3colors.m3onSurface.g, Appearance.m3colors.m3onSurface.b, 0.4)
                            Behavior on color { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation { duration: Metrics.chronoDuration(150) } }
                        }
                    }
                }
            }
        }
    }

    onClicked: {
        if (isSeparator) return;
        if (appToplevel.toplevelCount === 0) {
            const id = desktopEntry ? desktopEntry.id : root.appToplevel.appId;
            Quickshell.execDetached(["sh", "-c", `gtk-launch "${id}" 2>/dev/null || ${id}`]);
            return;
        }
        lastFocused = (lastFocused + 1) % appToplevel.toplevelCount;
        appToplevel.toplevels[lastFocused].activate();
    }

    readonly property bool isPinned: TaskbarApps.pinnedAppIds.includes(root.appToplevel?.appId ?? "")

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.RightButton
        onClicked: mouse => {
            if (root.isSeparator) return;
            if (mouse.button === Qt.MiddleButton) {
                const id = root.desktopEntry ? root.desktopEntry.id : root.appToplevel.appId;
                Quickshell.execDetached(["sh", "-c", `gtk-launch "${id}" 2>/dev/null || ${id}`]);
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.open();
            }
        }
    }

    Popup {
        id: contextMenu
        parent: root
        x: (root.width - width) / 2
        y: -height - 8
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Appearance.m3colors.m3surfaceContainer
            radius: Metrics.radius(10)
            border.color: Appearance.m3colors.m3outlineVariant
            border.width: 1
        }

        contentItem: Column {
            spacing: 0
            width: 180

            // App name header
            Item {
                width: parent.width
                height: 36
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Image {
                        width: 16; height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        source: root.appToplevel ? (root.desktopEntry?.icon ? AppRegistry.iconForDesktopIcon(root.desktopEntry.icon) : AppRegistry.iconForClass(root.appToplevel.appId)) : ""
                        sourceSize.width: 32; sourceSize.height: 32
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.desktopEntry?.name ?? root.appToplevel?.appId ?? ""
                        color: Appearance.m3colors.m3onSurface
                        font.pixelSize: Metrics.fontSize("small")
                        font.family: Metrics.fontFamily("main")
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width; height: 1
                color: Appearance.m3colors.m3outlineVariant
            }

            // Pin/Unpin row
            Rectangle {
                id: pinRow
                width: parent.width
                height: 40
                radius: Metrics.radius(10)
                color: pinRowMa.containsMouse ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"
                Behavior on color { ColorAnimation { duration: Metrics.chronoDuration(100) } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    spacing: 10

                    MaterialSymbol {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "push_pin"
                        fill: root.isPinned ? 1 : 0
                        iconSize: Metrics.iconSize(16)
                        color: root.isPinned ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurface
                        Behavior on color { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation { duration: Metrics.chronoDuration(150) } }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.isPinned ? "Unpin from dock" : "Pin to dock"
                        color: Appearance.m3colors.m3onSurface
                        font.pixelSize: Metrics.fontSize("small")
                        font.family: Metrics.fontFamily("main")
                    }
                }

                MouseArea {
                    id: pinRowMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        TaskbarApps.togglePin(root.appToplevel?.appId ?? "");
                        contextMenu.close();
                    }
                }
            }
        }
    }

    // Tooltip
    ToolTip {
        visible: root.hovered && !root.isSeparator && !contextMenu.visible
        text: root.desktopEntry?.name ?? root.appToplevel?.appId ?? ""
        delay: 500
    }
}
