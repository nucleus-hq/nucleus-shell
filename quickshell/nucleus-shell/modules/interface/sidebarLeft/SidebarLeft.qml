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

    property real sidebarLeftWidth: 480

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
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    visible: Config.initialized
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: Compositor.require("niri", "hyprland") && Globals.visiblility.sidebarLeft

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

    property var barConfig: ConfigResolver.bar(screen.name)
    property string barPosition: barConfig.position
    property int barSize: barConfig.density
    property int floatingMargin: Config.runtime.bar.margins
    property int sideMargin: Metrics.margin("small")

    margins {
        top:
            (floatingLayout ? floatingMargin : 0) +
            (barPosition === "top" ? barSize : 0)

        bottom:
            (floatingLayout ? floatingMargin : 0) +
            (barPosition === "bottom" ? barSize : 0)

        left:
            (floatingLayout ? sideMargin : 0) +
            (barPosition === "left" ? barSize : 0)

        right:
            (floatingLayout ? sideMargin : 0) +
            (barPosition === "right" ? barSize : 0)
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
            ? sidebarLeft.sidebarLeftWidth + 20
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
}