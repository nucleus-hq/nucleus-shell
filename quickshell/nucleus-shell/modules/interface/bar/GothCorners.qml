import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.components

PanelWindow {
    id: root

    // opacity must be real
    property real opacity: 0.0

    color: "transparent"
    visible: Config.initialized

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "nucleus:gothcorners"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Item {
        id: container
        anchors.fill: parent

        StyledRect {
            id: background
            anchors.fill: parent

            color: Appearance.m3colors.m3background
            opacity: root.opacity

            layer.enabled: true

            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskItem
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }

            Behavior on opacity {
                enabled: Config.runtime.appearance.animations.enabled

                NumberAnimation {
                    duration: Metrics.chronoDuration("large")
                    easing.type: Easing.InOutExpo
                    easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                }
            }
        }

        Item {
            id: maskItem
            anchors.fill: parent
            visible: false
            layer.enabled: true

            StyledRect {
                anchors.fill: parent

                anchors.topMargin: Config.runtime.bar.position === "bottom" ? -15 : 0
                anchors.bottomMargin: Config.runtime.bar.position === "top" ? -15 : 0
                anchors.leftMargin: Config.runtime.bar.position === "right" ? -15 : 0
                anchors.rightMargin: Config.runtime.bar.position === "left" ? -15 : 0

                radius: Metrics.radius("normal")
            }
        }
    }

    mask: Region {
        item: container
        intersection: Intersection.Xor
    }
}