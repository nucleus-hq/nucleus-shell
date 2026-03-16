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

    property real sidebarLeftWidth: 520

    property bool useMergedSidebarLayout: Config.runtime.misc.useMergedSidebarLayout

    property bool floatingLayout: !useMergedSidebarLayout ||
        !(ConfigResolver.bar(screen.name).gothCorners &&
          !ConfigResolver.bar(screen.name).floating &&
          ConfigResolver.bar(screen.name).enabled &&
          !ConfigResolver.bar(screen.name).merged)

    function togglesidebarLeft() {
        Globals.visiblility.sidebarLeft = !Globals.visiblility.sidebarLeft
    }

    WlrLayershell.namespace: "nucleus:sidebarLeft"
    WlrLayershell.layer: WlrLayer.Top
    visible: Config.initialized
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
        top: floatingLayout ? Config.runtime.bar.margins : 0
        bottom: floatingLayout ? Config.runtime.bar.margins : 0
        right: floatingLayout ? Metrics.margin("small") : 0
        left: floatingLayout ? Metrics.margin("small") : 0
    }

    component Anim: NumberAnimation {
        duration: 300
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animation.curves.standard
    }

    mask: Region {
        item: overlay
        intersection: Globals.visiblility.sidebarLeft ? Intersection.Combine : Intersection.Xor
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "black"
        opacity: 0   // FIX: removed transparency that caused blur

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: Globals.visiblility.sidebarLeft
            onClicked: {
                Globals.visiblility.sidebarLeft = false
            }
        }
    }

    StyledRect {
        id: floatingContainer
        z: 1
        color: Appearance.m3colors.m3background
        radius: Metrics.radius("large")

        width: Globals.visiblility.sidebarLeft
            ? sidebarLeft.sidebarLeftWidth
            : 0

        visible: floatingLayout
        clip: true

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
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
                    Globals.visiblility.sidebarLeft = false
                }
            }

            SidebarLeftContent { anchors.rightMargin: Metrics.margin("normal") }
        }
    }

    MergedEdgeRect {
        id: container
        visible: implicitWidth > 0 && !floatingLayout

        implicitWidth: Globals.visiblility.sidebarLeft
            ? sidebarLeft.sidebarLeftWidth
            : 0

        implicitHeight: parent.height

        color: Appearance.m3colors.m3background
        cornerRadius: Metrics.radius("large")

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        Behavior on implicitWidth {
            Anim {}
        }

        layer.enabled: true

        MouseArea {
            anchors.fill: parent
            onPressed: mouse.accepted = true
        }

        Item { // prevents bleeding
            anchors.fill: parent
            clip: true

            FocusScope {
                focus: true
                anchors.fill: parent

                Keys.onPressed: {
                    if (event.key === Qt.Key_Escape) {
                        Globals.visiblility.sidebarLeft = false
                    }
                }

                SidebarLeftContent {}
            }
        }
    }

    IpcHandler {
        target: "sidebarLeft"
        function toggle() {
            togglesidebarLeft()
        }
    }
}