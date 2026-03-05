import qs.config
import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 60
    height: 34

    property bool checked: false
    signal toggled(bool checked)

    // Colors
    property color trackOn: Appearance.colors.colPrimary
    property color trackOff: Appearance.colors.colLayer2
    property color outline: Appearance.colors.colOutline

    property color thumbOn: Appearance.colors.colOnPrimary
    property color thumbOff: Appearance.colors.colOnLayer2

    property color iconOn: Appearance.colors.colPrimary
    property color iconOff: Appearance.colors.colOnLayer2

    // Dimensions
    property int trackRadius: (height / 2) * Config.runtime.appearance.rounding.factor
    property int thumbSize: height - (checked ? 10 : 14)

    Behavior on thumbSize {
        enabled: Config.runtime.appearance.animations.enabled
        NumberAnimation {
            duration: Metrics.chronoDuration("normal")
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animation.curves.expressiveEffects
        }
    }

    // TRACK
    Rectangle {
        id: track
        anchors.fill: parent
        radius: trackRadius

        color: root.checked ? trackOn : trackOff
        border.width: root.checked ? 0 : 2
        border.color: outline

        Behavior on color {
            enabled: Config.runtime.appearance.animations.enabled
            ColorAnimation {
                duration: Metrics.chronoDuration("normal")
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.curves.expressiveEffects
            }
        }
    }

    // THUMB
    Rectangle {
        id: thumb
        width: thumbSize
        height: thumbSize
        radius: (thumbSize / 2) * Config.runtime.appearance.rounding.factor

        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 6 : 6

        color: root.checked ? thumbOn : thumbOff

        Behavior on x {
            enabled: Config.runtime.appearance.animations.enabled
            NumberAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.curves.expressiveEffects
            }
        }

        Behavior on color {
            enabled: Config.runtime.appearance.animations.enabled
            ColorAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animation.curves.expressiveEffects
            }
        }

        // ✓ CHECK ICON
        MaterialSymbol {
            anchors.centerIn: parent
            icon: "check"
            iconSize: parent.width * 0.7
            color: iconOn

            opacity: root.checked ? 1 : 0
            scale: root.checked ? 1 : 0.6

            Behavior on opacity { NumberAnimation { duration: 120 } }

            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutBack
                }
            }
        }

        // ✕ CROSS ICON (more visible)
        MaterialSymbol {
            anchors.centerIn: parent
            icon: "close"
            iconSize: parent.width * 0.72
            color: iconOff

            opacity: root.checked ? 0 : 1
            scale: root.checked ? 0.6 : 1

            Behavior on opacity { NumberAnimation { duration: 120 } }

            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutBack
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
