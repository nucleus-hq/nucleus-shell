import qs.config
import qs.modules.components
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

Rectangle {
    id: root

    property string title: "No Title"
    property string body: "No content"
    property var rawNotif: null
    property bool tracked: false
    property bool isHistory: false
    property string image: ""
    property string appName: "notify-send"
    property string timestamp: Qt.formatTime(new Date(), "hh:mm")
    property int urgency: 1
    property var buttons: [
        { label: "Okay!", onClick: () => console.log("Okay") }
    ]

    property bool isCritical: urgency === 2
    property real animProgress: tracked ? 1.0 : 0.0

    opacity: animProgress

    transform: [
        Translate {
            y: (1.0 - root.animProgress) * -30
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.height / 2
            xScale: 0.85 + (root.animProgress * 0.15)
            yScale: 0.85 + (root.animProgress * 0.15)
        }
    ]

    Behavior on animProgress {
        enabled: Config.runtime.appearance.animations.enabled
        NumberAnimation {
            duration: Metrics.chronoDuration("normal")
            easing.type: Easing.OutExpo
        }
    }

    Layout.fillWidth: true
    radius: Metrics.radius("large")

    property bool hovered: mouseHandler.containsMouse
    property bool clicked: mouseHandler.containsPress

    color: {
        if (isCritical) return Appearance.m3colors.m3error
        if (hovered) return clicked
            ? Appearance.m3colors.m3surfaceContainerHigh
            : Appearance.m3colors.m3surfaceContainerLow
        return Appearance.m3colors.m3surface
    }

    Behavior on color {
        enabled: Config.runtime.appearance.animations.enabled
        ColorAnimation {
            duration: Metrics.chronoDuration("small")
            easing.type: Easing.InOutExpo
        }
    }

    implicitHeight: mainColumn.implicitHeight + Metrics.margin(16) * 2
    implicitWidth: 360

    ColumnLayout {
        id: mainColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Metrics.margin(14)
        }
        spacing: Metrics.spacing(4)

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.spacing(6)

            ClippingRectangle {
                width: 18
                height: 18
                radius: Metrics.radius("small")
                clip: true
                color: "transparent"

                IconImage {
                    id: appIconImage
                    anchors.fill: parent
                    source: root.image
                    smooth: true
                    visible: root.image !== ""
                }
                MaterialSymbol {
                    icon: root.isCritical ? "warning" : "chat"
                    color: root.isCritical
                        ? Appearance.m3colors.m3onError
                        : Appearance.m3colors.m3onSurfaceVariant
                    anchors.centerIn: parent
                    visible: root.image === ""
                    iconSize: Metrics.iconSize(14)
                }
            }

            StyledText {
                text: root.appName
                font.pixelSize: Metrics.fontSize(12)
                color: root.isCritical
                    ? Appearance.m3colors.m3onError
                    : Appearance.m3colors.m3onSurfaceVariant
            }

            StyledText {
                text: "·"
                font.pixelSize: Metrics.fontSize(12)
                color: root.isCritical
                    ? Appearance.m3colors.m3onError
                    : Appearance.m3colors.m3onSurfaceVariant
            }

            StyledText {
                text: root.timestamp
                font.pixelSize: Metrics.fontSize(12)
                color: root.isCritical
                    ? Appearance.m3colors.m3onError
                    : Appearance.m3colors.m3onSurfaceVariant
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 20
                height: 20
                radius: width / 2
                color: closeHover.containsMouse
                    ? Appearance.m3colors.m3surfaceContainerHigh
                    : "transparent"
                visible: root.buttons.length === 0 || root.buttons.length === 1

                Behavior on color {
                    enabled: Config.runtime.appearance.animations.enabled
                    ColorAnimation { duration: Metrics.chronoDuration("small") }
                }

                MaterialSymbol {
                    icon: "close"
                    color: root.isCritical
                        ? Appearance.m3colors.m3onError
                        : Appearance.m3colors.m3onSurfaceVariant
                    anchors.centerIn: parent
                    iconSize: Metrics.iconSize(14)
                }

                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        mouse.accepted = true
                        if (root.rawNotif) {
                            root.rawNotif.popup = false
                            if (root.isHistory)
                                root.rawNotif.notification.dismiss()
                        }
                    }
                }
            }
        }

        StyledText {
            text: root.title
            font.bold: true
            font.pixelSize: Metrics.fontSize(14)
            wrapMode: Text.Wrap
            color: root.isCritical
                ? Appearance.m3colors.m3onError
                : Appearance.m3colors.m3onSurface
            Layout.fillWidth: true
            Layout.topMargin: Metrics.margin(2)
        }

        StyledText {
            text: root.body.length > 123 ? root.body.substr(0, 120) + "..." : root.body
            visible: root.body.length > 0
            font.pixelSize: Metrics.fontSize(12)
            color: root.isCritical
                ? Appearance.m3colors.m3onError
                : Appearance.m3colors.m3onSurfaceVariant
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        RowLayout {
            visible: root.buttons.length > 1
            Layout.preferredHeight: 40
            Layout.fillWidth: true
            Layout.topMargin: Metrics.margin(4)
            spacing: Metrics.spacing(10)

            Repeater {
                model: buttons

                StyledButton {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    implicitWidth: 0
                    text: modelData.label
                    base_bg: index !== 0
                        ? Appearance.m3colors.m3secondaryContainer
                        : Appearance.m3colors.m3primary
                    base_fg: index !== 0
                        ? Appearance.m3colors.m3onSecondaryContainer
                        : Appearance.m3colors.m3onPrimary
                    onClicked: modelData.onClick()
                }
            }
        }
    }

    MouseArea {
        id: mouseHandler
        anchors.fill: parent
        hoverEnabled: true
        visible: root.buttons.length === 0 || root.buttons.length === 1
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            mouse.accepted = true
            if (root.buttons.length === 1 && root.buttons[0].onClick) {
                root.buttons[0].onClick()
            }
            if (root.rawNotif) {
                root.rawNotif.popup = false
                if (root.isHistory)
                    root.rawNotif.notification.dismiss()
            }
        }
    }

    Component.onCompleted: {
        animProgress = 1.0
    }
}