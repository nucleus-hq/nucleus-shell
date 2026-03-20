pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.modules.components
import qs.config

Item {
    id: root

    required property ShellScreen screen
    property bool unifiedEffectActive: false

    readonly property bool keepHidden: Config.runtime.dock?.keepHidden ?? false
    readonly property bool pinned: Config.runtime.dock?.pinnedOnStartup ?? false

    readonly property string theme: Config.runtime.dock?.theme ?? "floating"
    readonly property bool isDefault: theme === "default"
    readonly property bool isFloating: theme === "floating"

    readonly property string userPosition: Config.runtime.dock?.position ?? "bottom"
    readonly property string barPosition: Config.runtime.bar?.position ?? "top"

    readonly property string position: {
        if (userPosition !== barPosition)
            return userPosition;
        switch (userPosition) {
        case "bottom": return "left";
        case "left":   return "right";
        case "right":  return "left";
        case "top":    return "bottom";
        default:       return "bottom";
        }
    }

    readonly property bool isBottom: position === "bottom"
    readonly property bool isTop: position === "top"
    readonly property bool isLeft: position === "left"
    readonly property bool isRight: position === "right"
    readonly property bool isVertical: isLeft || isRight

    readonly property int dockMargin: Config.runtime.dock?.margin ?? 8
    readonly property int shadowSpace: 20
    readonly property int dockSize: Config.runtime.dock?.height ?? 56

    readonly property int activeWorkspaceId: {
        if (Compositor.require("hyprland")) {
            const mon = Hyprland.monitorsInfo.find(m => m.name === screen.name)
            return mon ? mon.activeWorkspace.id : Compositor.focusedWorkspaceId
        }
        if (Compositor.require("niri")) {
            const ws = Niri.workspaces.find(w => w.output === screen.name && w.isActive)
            return ws ? ws.id : 1
        }
        return Compositor.focusedWorkspaceId
    }

    readonly property var screenWindows: {
        if (Compositor.require("hyprland"))
            return Hyprland.windowList.filter(c => c.workspace.id === activeWorkspaceId)
        if (Compositor.require("niri"))
            return Niri.windows.filter(w => w.workspaceId === activeWorkspaceId)
        return []
    }

    readonly property bool hasWindows: screenWindows.length > 0
    readonly property bool activeWindowFullscreen: screenWindows.some(w => w.fullscreen == true)

    readonly property var activeApp: TaskbarApps.apps.find(a => a.toplevels && a.toplevels.some(t => t.activated === true)) ?? null
    readonly property bool activeAppIsPinned: activeApp ? TaskbarApps.pinnedAppIds.includes(activeApp.appId) : false

    property bool reveal: {
        if (activeWindowFullscreen)
            return (Config.runtime.dock?.availableOnFullscreen ?? false) && (Config.runtime.dock?.hoverToReveal && dockMouseArea.containsMouse);
        if (keepHidden)
            return (Config.runtime.dock?.hoverToReveal && dockMouseArea.containsMouse);
        return root.pinned || (Config.runtime.dock?.hoverToReveal && dockMouseArea.containsMouse) || !hasWindows
    }

    readonly property int hoverRegionHeight: Config.runtime.dock?.hoverRegionHeight ?? 4

    implicitWidth:  isVertical ? dockSize + dockMargin + shadowSpace * 2 : dockInner.implicitWidth + shadowSpace * 2
    implicitHeight: isVertical ? dockInner.implicitHeight + shadowSpace * 2 : dockSize + dockMargin + shadowSpace * 2

    readonly property Item dockHitbox: dockMouseArea

    // Content size helper
    Item {
        id: dockInner
        implicitWidth:  isVertical ? root.dockSize : dockLayoutH.implicitWidth + 16
        implicitHeight: isVertical ? dockLayoutV.implicitHeight + 16 : root.dockSize
    }

    MouseArea {
        id: dockMouseArea
        hoverEnabled: true

        width:  isVertical ? (root.reveal ? root.dockSize + root.dockMargin + root.shadowSpace : root.hoverRegionHeight) : dockInner.implicitWidth + 20
        height: isVertical ? dockInner.implicitHeight + 20 : (root.reveal ? root.dockSize + root.dockMargin + root.shadowSpace : root.hoverRegionHeight)

        x: (root.isBottom || root.isTop) ? (parent.width - width) / 2 : (root.isLeft ? 0 : parent.width - width)
        y: root.isVertical ? (parent.height - height) / 2 : (root.isTop ? 0 : parent.height - height)

        Behavior on x { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }
        Behavior on y { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }
        Behavior on width  { enabled: Config.runtime.appearance.animations.enabled && root.isVertical;  NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }
        Behavior on height { enabled: Config.runtime.appearance.animations.enabled && !root.isVertical; NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }

        // Dock container
        Item {
            id: dockContainer

            width:  dockInner.implicitWidth
            height: dockInner.implicitHeight

            x: (root.isBottom || root.isTop) ? (parent.width - width) / 2 : (root.isLeft ? (root.isDefault ? 0 : root.dockMargin) : parent.width - width - (root.isDefault ? 0 : root.dockMargin))
            y: root.isVertical ? (parent.height - height) / 2 : (root.isTop ? (root.isDefault ? 0 : root.dockMargin) : parent.height - height - (root.isDefault ? 0 : root.dockMargin))

            Behavior on x { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }
            Behavior on y { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(100); easing.type: Easing.OutCubic } }

            opacity: root.reveal ? 1 : 0
            Behavior on opacity { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(200); easing.type: Easing.OutCubic } }

            transform: Translate {
                x: root.isVertical ? (root.reveal ? 0 : (root.isLeft ? -(dockContainer.width + root.dockMargin) : (dockContainer.width + root.dockMargin))) : 0
                y: root.isBottom ? (root.reveal ? 0 : (dockContainer.height + root.dockMargin))
                 : root.isTop    ? (root.reveal ? 0 : -(dockContainer.height + root.dockMargin))
                 : 0
                Behavior on x { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(200); easing.type: Easing.OutCubic } }
                Behavior on y { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation { duration: Metrics.chronoDuration(200); easing.type: Easing.OutCubic } }
            }

            // Default theme: edge-flush background with goth corners
            Item {
                anchors.fill: parent
                visible: root.isDefault
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    color: Appearance.m3colors.m3surfaceContainer
                    topLeftRadius:     (root.isBottom || root.isRight) ? Metrics.radius(14) : 0
                    topRightRadius:    (root.isBottom || root.isLeft)  ? Metrics.radius(14) : 0
                    bottomLeftRadius:  (root.isTop    || root.isRight) ? Metrics.radius(14) : 0
                    bottomRightRadius: (root.isTop    || root.isLeft)  ? Metrics.radius(14) : 0
                }

                Canvas {
                    id: gothCanvas
                    anchors.fill: parent
                    readonly property real r: Metrics.radius(14)
                    onRChanged: requestPaint()
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.globalCompositeOperation = "destination-out"
                        ctx.fillStyle = "rgba(0,0,0,1)"
                        const r = gothCanvas.r, w = width, h = height
                        if (root.isBottom) {
                            ctx.beginPath(); ctx.moveTo(0,0); ctx.lineTo(r,0); ctx.arc(0,0,r,0,Math.PI/2,false); ctx.closePath(); ctx.fill()
                            ctx.beginPath(); ctx.moveTo(w,0); ctx.lineTo(w-r,0); ctx.arc(w,0,r,Math.PI,Math.PI/2,true); ctx.closePath(); ctx.fill()
                        } else if (root.isTop) {
                            ctx.beginPath(); ctx.moveTo(0,h); ctx.lineTo(r,h); ctx.arc(0,h,r,0,-Math.PI/2,true); ctx.closePath(); ctx.fill()
                            ctx.beginPath(); ctx.moveTo(w,h); ctx.lineTo(w-r,h); ctx.arc(w,h,r,Math.PI,3*Math.PI/2,false); ctx.closePath(); ctx.fill()
                        } else if (root.isLeft) {
                            ctx.beginPath(); ctx.moveTo(w,0); ctx.lineTo(w-r,0); ctx.arc(w,0,r,Math.PI,Math.PI/2,true); ctx.closePath(); ctx.fill()
                            ctx.beginPath(); ctx.moveTo(w,h); ctx.lineTo(w-r,h); ctx.arc(w,h,r,Math.PI,3*Math.PI/2,false); ctx.closePath(); ctx.fill()
                        } else if (root.isRight) {
                            ctx.beginPath(); ctx.moveTo(0,0); ctx.lineTo(r,0); ctx.arc(0,0,r,0,Math.PI/2,false); ctx.closePath(); ctx.fill()
                            ctx.beginPath(); ctx.moveTo(0,h); ctx.lineTo(r,h); ctx.arc(0,h,r,0,-Math.PI/2,true); ctx.closePath(); ctx.fill()
                        }
                    }
                    Connections { target: root; function onPositionChanged() { gothCanvas.requestPaint() } }
                    Connections { target: Metrics; function onRoundingScaleChanged() { gothCanvas.requestPaint() } }
                }
            }

            // Floating theme: pill with border
            Rectangle {
                anchors.fill: parent
                visible: root.isFloating
                color: Appearance.m3colors.m3surfaceContainer
                radius: Metrics.radius(14)
                border.color: Appearance.m3colors.m3outlineVariant
                border.width: 1
            }

            // Horizontal layout
            RowLayout {
                id: dockLayoutH
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: (dockInner.implicitHeight - implicitHeight) / 2
                spacing: Config.runtime.dock?.spacing ?? 4
                visible: !root.isVertical

                // Pin button (pins/unpins the active app)
                Rectangle {
                    id: pinBtnH
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Metrics.radius(6)
                    color: pinBtnHMa.containsMouse ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"
                    opacity: root.activeApp ? 1 : 0.35
                    Layout.alignment: Qt.AlignVCenter
                    Behavior on color   { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation    { duration: Metrics.chronoDuration(200) } }
                    Behavior on opacity { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation   { duration: Metrics.chronoDuration(200) } }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "push_pin"
                        fill: root.activeAppIsPinned ? 1 : 0
                        iconSize: Metrics.iconSize(16)
                        color: root.activeAppIsPinned ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurface
                        Behavior on color { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation { duration: Metrics.chronoDuration(200) } }
                    }
                    MouseArea {
                        id: pinBtnHMa
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.activeApp !== null
                        onClicked: TaskbarApps.togglePin(root.activeApp.appId)
                    }
                }

                Rectangle {
                    implicitWidth: 2
                    implicitHeight: (Config.runtime.dock?.iconSize ?? 40) * 0.6
                    color: Appearance.m3colors.m3outlineVariant
                    radius: 1
                    Layout.alignment: Qt.AlignVCenter
                }

                Repeater {
                    model: TaskbarApps.apps
                    DockAppButton {
                        required property var modelData
                        appToplevel: modelData
                        Layout.alignment: Qt.AlignVCenter
                        dockPosition: "bottom"
                    }
                }

                Loader {
                    active: Config.runtime.dock?.showOverviewButton ?? true
                    visible: active
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: Rectangle {
                        implicitWidth: 2
                        implicitHeight: (Config.runtime.dock?.iconSize ?? 40) * 0.6
                        color: Appearance.m3colors.m3outlineVariant
                        radius: 1
                    }
                }

                Loader {
                    active: Config.runtime.dock?.showOverviewButton ?? true
                    visible: active
                    Layout.alignment: Qt.AlignVCenter
                    sourceComponent: Rectangle {
                        id: ovBtn
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: Metrics.radius(6)
                        color: ovBtnMa.containsMouse ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"

                        MaterialSymbol {
                            anchors.centerIn: parent
                            icon: "apps"
                            iconSize: Metrics.iconSize(18)
                            color: Appearance.m3colors.m3onSurface
                        }
                        MouseArea {
                            id: ovBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Globals.visiblility.launcher = !Globals.visiblility.launcher
                        }
                    }
                }
            }

            // Vertical layout
            ColumnLayout {
                id: dockLayoutV
                anchors.horizontalCenter: parent.horizontalCenter
                y: (dockInner.implicitHeight - implicitHeight) / 2
                spacing: Config.runtime.dock?.spacing ?? 4
                visible: root.isVertical

                // Pin button (pins/unpins the active app)
                Rectangle {
                    id: pinBtnV
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Metrics.radius(6)
                    color: pinBtnVMa.containsMouse ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"
                    opacity: root.activeApp ? 1 : 0.35
                    Layout.alignment: Qt.AlignHCenter
                    Behavior on color   { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation    { duration: Metrics.chronoDuration(200) } }
                    Behavior on opacity { enabled: Config.runtime.appearance.animations.enabled; NumberAnimation   { duration: Metrics.chronoDuration(200) } }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "push_pin"
                        fill: root.activeAppIsPinned ? 1 : 0
                        iconSize: Metrics.iconSize(16)
                        color: root.activeAppIsPinned ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurface
                        Behavior on color { enabled: Config.runtime.appearance.animations.enabled; ColorAnimation { duration: Metrics.chronoDuration(200) } }
                    }
                    MouseArea {
                        id: pinBtnVMa
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.activeApp !== null
                        onClicked: TaskbarApps.togglePin(root.activeApp.appId)
                    }
                }

                Rectangle {
                    implicitWidth: (Config.runtime.dock?.iconSize ?? 40) * 0.6
                    implicitHeight: 2
                    color: Appearance.m3colors.m3outlineVariant
                    radius: 1
                    Layout.alignment: Qt.AlignHCenter
                }

                Repeater {
                    model: TaskbarApps.apps
                    DockAppButton {
                        required property var modelData
                        appToplevel: modelData
                        Layout.alignment: Qt.AlignHCenter
                        dockPosition: root.position
                    }
                }

                Loader {
                    active: Config.runtime.dock?.showOverviewButton ?? true
                    visible: active
                    Layout.alignment: Qt.AlignHCenter
                    sourceComponent: Rectangle {
                        implicitWidth: (Config.runtime.dock?.iconSize ?? 40) * 0.6
                        implicitHeight: 2
                        color: Appearance.m3colors.m3outlineVariant
                        radius: 1
                    }
                }

                Loader {
                    active: Config.runtime.dock?.showOverviewButton ?? true
                    visible: active
                    Layout.alignment: Qt.AlignHCenter
                    sourceComponent: Rectangle {
                        id: ovBtnV
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: Metrics.radius(6)
                        color: ovBtnVMa.containsMouse ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"

                        MaterialSymbol {
                            anchors.centerIn: parent
                            icon: "apps"
                            iconSize: Metrics.iconSize(18)
                            color: Appearance.m3colors.m3onSurface
                        }
                        MouseArea {
                            id: ovBtnVMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Globals.visiblility.launcher = !Globals.visiblility.launcher
                        }
                    }
                }
            }
        }
    }
}
