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
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    visible: Config.initialized
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.keyboardFocus: Compositor.require("niri") && Globals.visiblility.sidebarRight

    property bool useMergedSidebarLayout: Config.runtime.misc.useMergedSidebarLayout

    property bool floatingLayout: !useMergedSidebarLayout ||
        !(ConfigResolver.bar(screen.name).gothCorners &&
          !ConfigResolver.bar(screen.name).floating &&
          ConfigResolver.bar(screen.name).enabled &&
          !ConfigResolver.bar(screen.name).merged)

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

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property var sink: Pipewire.defaultAudioSink?.audio

    component Anim: NumberAnimation {
        duration: 300
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animation.curves.standard
    }

    mask: Region { 
        item: overlay
        intersection: Globals.visiblility.sidebarRight ? Intersection.Combine : Intersection.Xor
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
            enabled: Globals.visiblility.sidebarRight
            onClicked: {
                Globals.visiblility.sidebarRight = false
            }
        }
    }

    StyledRect {
        id: floatingContainer
        z: 1
        color: Appearance.m3colors.m3background
        radius: Metrics.radius("large")

        width: Globals.visiblility.sidebarRight
            ? sidebarRight.sidebarRightWidth
            : 0

        visible: floatingLayout
        clip: true

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

            SidebarRightContent { anchors.leftMargin: Metrics.margin("normal") }
        }
    }

    MergedEdgeRect {
        id: container
        visible: implicitWidth > 0 && !floatingLayout

        implicitWidth: Globals.visiblility.sidebarRight
            ? sidebarRight.sidebarRightWidth
            : 0

        implicitHeight: parent.height

        color: Appearance.m3colors.m3background
        cornerRadius: Metrics.radius("large")

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        Behavior on implicitWidth {
            Anim {}
        }

        clip: true

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

            SidebarRightContent {}
        }
    }

    function togglesidebarRight() {
        Globals.visiblility.sidebarRight = !Globals.visiblility.sidebarRight
    }

}