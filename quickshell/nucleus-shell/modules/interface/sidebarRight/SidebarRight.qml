import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: sidebarRight
    WlrLayershell.namespace: "nucleus:sidebarRight"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized && Globals.visiblility.sidebarRight
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.sidebarRight
    
    property real sidebarRightWidth: 500

    HyprlandFocusGrab {
        id: grab
        active: Compositor.require("hyprland")
        windows: [sidebarRight]
    }

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    margins {
        top: Config.runtime.bar.margins
        bottom: Config.runtime.bar.margins
        left: Metrics.margin("small")
        right: Metrics.margin("small")
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink?.audio


    MouseArea {
        anchors.fill: parent
        z: 0
        onPressed: Globals.visiblility.sidebarRight = false
    }

    StyledRect {
        id: container
        z: 1
        color: Appearance.m3colors.m3background
        radius: Metrics.radius("large")
        width: sidebarRight.sidebarRightWidth

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
        }

        FocusScope {
            focus: true 
            anchors.fill: parent

            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) {
                    Globals.visiblility.sidebarRight = false
                }
            }

            SidebarRightContent { }
        }
    }

    function togglesidebarRight() {
        Globals.visiblility.sidebarRight = !Globals.visiblility.sidebarRight
    }

    IpcHandler {
        target: "sidebarRight"
        function toggle() {
            togglesidebarRight()
        }
    }
}
