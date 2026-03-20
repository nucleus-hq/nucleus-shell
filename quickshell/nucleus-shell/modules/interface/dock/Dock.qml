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
                left: dockContent.isLeft
                right: dockContent.isRight
            }

            exclusiveZone: (dockContent.pinned && !dockContent.activeWindowFullscreen) ? dockContent.dockSize + dockContent.dockMargin : 0

            implicitWidth: dockContent.implicitWidth
            implicitHeight: dockContent.implicitHeight

            WlrLayershell.namespace: "nucleus:dock"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

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
