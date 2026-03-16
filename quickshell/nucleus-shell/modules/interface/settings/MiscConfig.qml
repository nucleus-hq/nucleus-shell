import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    title: "Miscellaneous"
    description: "Configure misc settings."

    ContentCard {
        StyledText {
            text: "Versions"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        RowLayout {
            id: releaseChannelSelector

            property string title: "Release Channel"
            property string description: "Choose the release channel for updates."
            property string prefField: ''

            ColumnLayout {
                StyledText {
                    text: releaseChannelSelector.title
                    font.pixelSize: Metrics.fontSize(16)
                }

                StyledText {
                    text: releaseChannelSelector.description
                    font.pixelSize: Metrics.fontSize(12)
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledDropDown {
                label: "Type"
                model: ["Stable", "Edge (indev)"]
                currentIndex: Config.runtime.shell.releaseChannel === "edge" ? 1 : 0
                onSelectedIndexChanged: (index) => {
                    Config.updateKey("shell.releaseChannel", index === 1 ? "edge" : "stable");
                    UpdateNotifier.notified = false;
                }
            }
        }
    }

    ContentCard {
        StyledText {
            text: "Sidebar Layout"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Merged Layout"
            description: "Use merged layout for sidebars when bar is merged."
            prefField: "misc.useMergedSidebarLayout"
        }
    }

    ContentCard {
        StyledText {
            text: "Intelligence"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Enabled"
            description: "Enable or disable intelligence."
            prefField: "misc.intelligence.enabled"
        }
    }

    ContentCard {
        StyledText {
            text: "Intelligence Bearer/API"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledTextField {
            id: apiKeyTextField

            clip: true
            horizontalAlignment: Text.AlignLeft
            placeholderText: Config.runtime.misc.intelligence.apiKey !== "" ? Config.runtime.misc.intelligence.apiKey : "Bearer Key"
            Layout.fillWidth: true

            Keys.onPressed: (event) => {
                if ((event.key === Qt.Key_S && (event.modifiers & Qt.ControlModifier)) ||
                    event.key === Qt.Key_Return ||
                    event.key === Qt.Key_Enter) {

                    event.accepted = true;
                    Config.updateKey("misc.intelligence.apiKey", apiKeyTextField.text);
                    Quickshell.execDetached(["notify-send", "Saved Bearer/API Key"])
                }
            }

            font.pixelSize: Metrics.fontSize(16)
        }

        Item {
            width: 20
        }

        InfoCard {
            title: "How to save the api key"
            description: "In order to save the api key press Enter/Return and it will save the api key to the config."
        }
    }
}