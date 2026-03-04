import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services
import qs.modules.functions

ContentMenu {
    title: "Notifications & Overlays"
    description: "Adjust notification and overlay settings."

    function indexFromPosition(pos, model) {
        pos = pos.toLowerCase()
        for (let i = 0; i < model.length; i++) {
            if (model[i].toLowerCase().replace(" ", "-") === pos)
                return i
        }
        return 0
    }

    ContentCard {

        StyledText {
            text: "Notifications"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Enabled"
            description: "Enable or disable built-in notification daemon."
            prefField: "notifications.enabled"
        }

        StyledSwitchOption {
            title: "Do not disturb enabled"
            description: "Enable or disable dnd."
            prefField: "notifications.doNotDisturb"
        }

        RowLayout {

            ColumnLayout {
                StyledText {
                    text: "Notification Position"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Select where notification will be shown."
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item { Layout.fillWidth: true }

            StyledDropDown {
                id: notificationDropdown
                label: "Position"

                property var positions: ["Top Left", "Top Right", "Top"]

                model: positions

                currentIndex:
                    indexFromPosition(
                        Config.runtime.notifications.position,
                        positions
                    )

                onSelectedIndexChanged: function(index) {
                    Config.updateKey(
                        "notifications.position",
                        positions[index].toLowerCase().replace(" ", "-")
                    )
                }
            }
        }

        RowLayout {

            ColumnLayout {
                StyledText {
                    text: "Test Notifications"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Run a test notification."
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item { Layout.fillWidth: true }

            StyledButton {
                text: "Test"
                icon: "chat"

                onClicked:
                    Quickshell.execDetached([
                        "notify-send",
                        "Quickshell",
                        "This is a test notification"
                    ])
            }
        }
    }

    ContentCard {

        StyledText {
            text: "Overlays / OSDs"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Enabled"
            description: "Enable or disable built-in osd daemon."
            prefField: "overlays.enabled"
        }

        StyledSwitchOption {
            title: "Volume OSD enabled"
            description: "Enable or disable volume osd."
            prefField: "overlays.volumeOverlayEnabled"
        }

        StyledSwitchOption {
            title: "Brightness OSD enabled"
            description: "Enable or disable brightness osd."
            prefField: "overlays.brightnessOverlayEnabled"
        }

        RowLayout {

            ColumnLayout {
                StyledText {
                    text: "Brightness OSD Position"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Choose where brightness OSD is shown."
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item { Layout.fillWidth: true }

            StyledDropDown {

                property var positions:
                    ["Top Left","Top Right","Bottom Left","Bottom Right","Top","Bottom"]

                model: positions

                currentIndex:
                    indexFromPosition(
                        Config.runtime.overlays.brightnessOverlayPosition,
                        positions
                    )

                onSelectedIndexChanged: function(index) {
                    Config.updateKey(
                        "overlays.brightnessOverlayPosition",
                        positions[index].toLowerCase().replace(" ", "-")
                    )
                }
            }
        }

        RowLayout {

            ColumnLayout {
                StyledText {
                    text: "Volume OSD Position"
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: "Choose where volume OSD is shown."
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item { Layout.fillWidth: true }

            StyledDropDown {

                property var positions:
                    ["Top Left","Top Right","Bottom Left","Bottom Right","Top","Bottom"]

                model: positions

                currentIndex:
                    indexFromPosition(
                        Config.runtime.overlays.volumeOverlayPosition,
                        positions
                    )

                onSelectedIndexChanged: function(index) {
                    Config.updateKey(
                        "overlays.volumeOverlayPosition",
                        positions[index].toLowerCase().replace(" ", "-")
                    )
                }
            }
        }
    }
}
