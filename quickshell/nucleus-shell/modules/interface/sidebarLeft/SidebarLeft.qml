import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.functions
import qs.modules.components

PanelWindow {
    id: sidebarLeft

    property real sidebarLeftWidth: 500

    function togglesidebarLeft() {
        Globals.visiblility.sidebarLeft = !Globals.visiblility.sidebarLeft;
    }

    WlrLayershell.namespace: "nucleus:sidebarLeft"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized && Globals.visiblility.sidebarLeft
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.sidebarLeft

    HyprlandFocusGrab {
        id: grab

        active: Compositor.require("hyprland")
        windows: [sidebarLeft]
    }

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    margins {
        top: Metrics.margin("small")
        bottom: Metrics.margin("small")
        right: Metrics.margin("small")
        left: Metrics.margin("small")
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        onPressed: Globals.visiblility.sidebarLeft = false
    }

    StyledRect {
        id: container

        color: Appearance.m3colors.m3background
        radius: Metrics.radius("normal")
        width: sidebarLeft.sidebarLeftWidth
        clip: true

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        FocusScope {
            focus: true 
            anchors.fill: parent

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    Globals.visiblility.sidebarLeft = false;
                }
            }

            SidebarLeftContent {
            }
        }
    }

    IpcHandler {
        function toggle() {
            togglesidebarLeft();
        }

        target: "sidebarLeft"
    }
}
