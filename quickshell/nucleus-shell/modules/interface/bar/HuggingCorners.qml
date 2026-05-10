import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.config
import qs.modules.components

PanelWindow {
    id: root

    property int opacity: 0

    color: "transparent"
    visible: Config.initialized
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    Item {
        id: container

        anchors.fill: parent

        StyledRect {
            anchors.fill: parent
            color: "#000000"
            layer.enabled: true
            opacity: root.opacity

            layer.effect: MultiEffect {
                maskSource: mask
                maskEnabled: true
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
            id: mask

            anchors.fill: parent
            layer.enabled: true
            visible: false

            StyledRect {
                anchors.fill: parent
                anchors.topMargin: Config.runtime.misc.enableScreenBorders ? 0 : ConfigResolver.bar(screen.name).position === "bottom" ? -15 : 0
                anchors.bottomMargin: Config.runtime.misc.enableScreenBorders ? 0 : ConfigResolver.bar(screen.name).position === "top" ? -15 : 0
                anchors.leftMargin: Config.runtime.misc.enableScreenBorders ? 0 : ConfigResolver.bar(screen.name).position === "right" ? -15 : 0
                anchors.rightMargin: Config.runtime.misc.enableScreenBorders ? 0 : ConfigResolver.bar(screen.name).position === "left" ? -15 : 0
                radius: Metrics.radius("verylarge")
            }

        }

    }

    mask: Region {
        item: container
        intersection: Intersection.Xor
    }

}
