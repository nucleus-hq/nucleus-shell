import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import qs.services

Item {
    id: root
    implicitHeight: topSection.implicitHeight + separator.height + Metrics.margin("large") * 2

    ColumnLayout {
        anchors.fill: parent
        spacing: Metrics.margin("large")

        RowLayout {
            id: topSection
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Metrics.margin(10)
                Layout.alignment: Qt.AlignVCenter
                spacing: Metrics.spacing(2)

                RowLayout {
                    spacing: Metrics.spacing(8)

                    StyledText {
                        text: SystemDetails.osIcon
                        font.pixelSize: Metrics.fontSize("hugeass") + 6
                    }

                    StyledText {
                        text: SystemDetails.uptime
                        font.pixelSize: Metrics.fontSize("large")
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: Metrics.margin(5)
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Row {
                spacing: Metrics.spacing(6)
                Layout.leftMargin: Metrics.margin(25)
                Layout.alignment: Qt.AlignVCenter

                StyledRect {
                    color: "transparent"
                    radius: Metrics.radius("large")
                    implicitHeight: screenshotButton.height + Metrics.margin("tiny")
                    implicitWidth:  screenshotButton.width + Metrics.margin("small")

                    MaterialSymbolButton {
                        id: screenshotButton
                        icon: "edit"
                        anchors.centerIn: parent
                        iconSize: Metrics.iconSize("hugeass") + 2
                        tooltipText: "Take a screenshot"
                        onButtonClicked: {
                            Quickshell.execDetached(["nucleus", "ipc", "call", "screen", "capture"])
                            Globals.visiblility.sidebarRight = false
                        }
                    }
                }

                StyledRect {
                    color: "transparent"
                    radius: Metrics.radius("large")
                    implicitHeight: reloadButton.height + Metrics.margin("tiny")
                    implicitWidth:  reloadButton.width + Metrics.margin("small")

                    MaterialSymbolButton {
                        id: reloadButton
                        icon: "refresh"
                        anchors.centerIn: parent
                        iconSize: Metrics.iconSize("hugeass") + 4
                        tooltipText: "Reload Nucleus Shell"
                        onButtonClicked: {
                            Quickshell.execDetached(["nucleus", "run", "--reload"])
                        }
                    }
                }

                StyledRect {
                    color: "transparent"
                    radius: Metrics.radius("large")
                    implicitHeight: settingsButton.height + Metrics.margin("tiny")
                    implicitWidth:  settingsButton.width + Metrics.margin("small")

                    MaterialSymbolButton {
                        id: settingsButton
                        icon: "settings"
                        anchors.centerIn: parent
                        iconSize: Metrics.iconSize("hugeass") + 2
                        tooltipText: "Open Settings"
                        onButtonClicked: {
                            Globals.visiblility.sidebarRight = false
                            Globals.states.settingsOpen = true
                        }
                    }
                }

                StyledRect {
                    color: "transparent"
                    radius: Metrics.radius("large")
                    implicitHeight: powerButton.height + Metrics.margin("tiny")
                    implicitWidth:  powerButton.width + Metrics.margin("small")

                    MaterialSymbolButton {
                        id: powerButton
                        icon: "power_settings_new"
                        anchors.centerIn: parent
                        iconSize: Metrics.iconSize("hugeass") + 2
                        tooltipText: "Open PowerMenu"
                        onButtonClicked: {
                            Globals.visiblility.sidebarRight = false
                            Globals.visiblility.powermenu = true
                        }
                    }
                }
            }
        }

        Rectangle {
            id: separator
            Layout.fillWidth: true
            height: 1
            color: Appearance.m3colors.m3outlineVariant
            radius: Metrics.radius(1)
        }
    }
}