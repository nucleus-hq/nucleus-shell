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

            exclusiveZone: {
                // Wait for config to load — defaults may differ from saved values and would
                // cause Hyprland to tile windows in the wrong size before config is applied
                if (!Config.initialized) return 0
                // Never reserve space when sidebars are animating/open
                if (targetMarginLeft !== 0 || targetMarginRight !== 0) return 0
                // Never reserve space when fullscreen
                if (dockContent.activeWindowFullscreen) return 0
                // In hover-to-reveal or keep-hidden modes the dock overlays content — no space reserved
                if (dockContent.keepHidden || (Config.runtime.dock?.hoverToReveal ?? false)) return 0
                // Reserve space only when dock is permanently visible
                return dockContent.pinned ? dockContent.dockSize + dockContent.dockMargin : 0
            }

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
