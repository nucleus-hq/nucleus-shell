import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

Item {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    property int logoOffset: -30

    Column {
        anchors.centerIn: parent
        width: 460
        spacing: Metrics.spacing(14)

        Item {
            width: parent.width
            height: Metrics.fontSize(200)

            StyledText {
                text: SystemDetails.osIcon
                anchors.centerIn: parent
                x: root.logoOffset
                font.pixelSize: Metrics.fontSize(200)
            }
        }

        StyledText {
            text: "Nucleus Shell"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.family: "Outfit ExtraBold"
            font.pixelSize: Metrics.fontSize(26)
        }

        StyledText {
            text: "A shell built to get things done."
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Metrics.fontSize(14)
            color: Appearance.m3colors.m3onSurfaceVariant
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Metrics.spacing(12)

            StyledButton {
                text: "View on GitHub"
                icon: "code"
                secondary: true
                onClicked: Qt.openUrlExternally("https://github.com/xZepyx/nucleus-shell")
            }

            StyledButton {
                text: "Report Issue"
                icon: "bug_report"
                secondary: true
                onClicked: Qt.openUrlExternally("https://github.com/xZepyx/nucleus-shell/issues")
            }
        }
    }

    StyledText {
        text: "Nucleus-Shell v" + Config.runtime.shell.version
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Metrics.margin(24)
        font.pixelSize: Metrics.fontSize(12)
        color: Appearance.m3colors.m3onSurfaceVariant
    }

    Rectangle {
        id: updateButton

        width: 52
        height: 52
        radius: Appearance.rounding.small

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Metrics.margin(24)

        color: Appearance.m3colors.m3surfaceContainer

        Behavior on color {
            ColorAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Easing.InOutCubic
            }
        }

        MaterialSymbol {
            icon: "refresh"
            anchors.centerIn: parent
            iconSize: Metrics.iconSize(22)
            color: Appearance.m3colors.m3onSurface
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPressed: updateButton.color = Appearance.m3colors.m3surfaceContainerHighest
            onReleased: updateButton.color = Appearance.m3colors.m3surfaceContainer
            onEntered: updateButton.color = Appearance.m3colors.m3surfaceContainerHigh
            onExited: updateButton.color = Appearance.m3colors.m3surfaceContainer

            onClicked: {
                Globals.states.settingsOpen = false

                Quickshell.execDetached(["notify-send", "Updating Nucleus Shell"])

                Quickshell.execDetached([
                    "kitty",
                    "--hold",
                    "bash",
                    "-c",
                    Directories.scriptsPath + "/system/update.sh"
                ])
            }
        }
    }
}
