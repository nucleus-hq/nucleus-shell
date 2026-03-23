pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config

Scope {
    id: root

    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.runtime.dock?.screenList ?? [];
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }

        PanelWindow {
            id: dockWindow

            required property ShellScreen modelData
            screen: modelData

            readonly property alias reveal: dockContent.reveal

            anchors {
                top: dockContent.isTop
                bottom: dockContent.isBottom
                // Horizontal docks span full screen width so margins can shift the dock
                left: dockContent.isLeft || !dockContent.isVertical
                right: dockContent.isRight || !dockContent.isVertical
            }

            // Animated margins so the dock slides away from open sidebars
            property int targetMarginLeft: dockContent.sidebarMarginLeft
            property int targetMarginRight: dockContent.sidebarMarginRight

            Behavior on targetMarginLeft  { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            Behavior on targetMarginRight { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            WlrLayershell.margins {
                left: targetMarginLeft
                right: targetMarginRight
            }

            exclusiveZone: (dockContent.pinned && !dockContent.activeWindowFullscreen) && targetMarginLeft === 0 && targetMarginRight === 0 ? dockContent.dockSize + dockContent.dockMargin : 0

            implicitWidth: dockContent.implicitWidth
            implicitHeight: dockContent.implicitHeight

            WlrLayershell.namespace: "nucleus:dock"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"

            mask: Region {
                item: dockContent.dockHitbox
            }

            DockContent {
                id: dockContent
                anchors.fill: parent
                screen: dockWindow.screen
            }
        }
    }
}
