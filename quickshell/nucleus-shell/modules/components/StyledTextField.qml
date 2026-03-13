import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.config
import qs.modules.functions

TextField {
    id: control

    property string icon: ""
    property color iconColor: Appearance.m3colors.m3onSurfaceVariant
    property string placeholder: ""

    property real iconSize: Metrics.iconSize(22)

    property bool filled: true
    property bool outline: true
    property bool highlight: true

    property color backgroundColor:
        filled ? Appearance.m3colors.m3surfaceContainerHigh : "transparent"

    property int fieldPadding: Metrics.padding(16)
    property int iconSpacing: Metrics.spacing(12)
    property int iconMargin: Metrics.margin(16)

    property alias radius: bg.radius
    property alias topLeftRadius: bg.topLeftRadius
    property alias topRightRadius: bg.topRightRadius
    property alias bottomLeftRadius: bg.bottomLeftRadius
    property alias bottomRightRadius: bg.bottomRightRadius

    width: parent ? parent.width - Metrics.margin(40) : 320

    placeholderText: placeholder
    placeholderTextColor: Appearance.m3colors.m3onSurfaceVariant

    color: Appearance.m3colors.m3onSurface

    font.family: "Outfit"
    font.pixelSize: Metrics.fontSize(14)

    padding: fieldPadding
    verticalAlignment: TextInput.AlignVCenter

    leftPadding:
        icon !== ""
        ? iconSize + iconSpacing + iconMargin
        : fieldPadding

    cursorVisible: focus

    MaterialSymbol {
        visible: control.icon !== ""

        icon: control.icon

        anchors.left: parent.left
        anchors.leftMargin: control.iconMargin
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: control.iconSize
        color: control.iconColor

        Behavior on color {
            ColorAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Appearance.animation.easing
            }
        }
    }

    cursorDelegate: Rectangle {
        width: 2
        color: Appearance.m3colors.m3primary
        visible: control.focus

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: control.focus && Config.runtime.appearance.animations.enabled

            NumberAnimation {
                from: 1
                to: 0
                duration: Metrics.chronoDuration("large") * 2
            }

            NumberAnimation {
                from: 0
                to: 1
                duration: Metrics.chronoDuration("large") * 2
            }
        }
    }

    background: Item {

        Rectangle {
            id: bg

            anchors.fill: parent
            radius: Metrics.radius(18)
            color: control.backgroundColor
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: parent.radius

                color: {
                    if (control.activeFocus && control.highlight)
                        return ColorUtils.transparentize(
                            Appearance.m3colors.m3primary, 0.88)

                    if (control.hovered && control.highlight)
                        return ColorUtils.transparentize(
                            Appearance.m3colors.m3onSurface, 0.93)

                    return "transparent"
                }

                Behavior on color {
                    enabled: Config.runtime.appearance.animations.enabled
                    ColorAnimation {
                        duration: Metrics.chronoDuration("small")
                        easing.type: Appearance.animation.easing
                    }
                }
            }
        }

        Rectangle {
            id: outlineRect

            visible: control.outline

            anchors.fill: parent
            radius: bg.radius
            color: "transparent"

            border.width: control.activeFocus ? 2 : 1

            border.color: {
                if (control.activeFocus)
                    return Appearance.m3colors.m3primary

                if (control.hovered)
                    return Appearance.m3colors.m3onSurface

                return Appearance.m3colors.m3outline
            }

            Behavior on border.width {
                enabled: Config.runtime.appearance.animations.enabled
                NumberAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }

            Behavior on border.color {
                enabled: Config.runtime.appearance.animations.enabled
                ColorAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }
        }
    }
}
