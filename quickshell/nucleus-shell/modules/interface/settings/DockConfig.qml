import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components

ContentMenu {
    title: "Dock"
    description: "Configure dock visibility and appearance."

    ContentCard {
        StyledText {
            text: "Visibility"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Always visible"
            description: "Keep the dock visible even when windows are open."
            prefField: "dock.pinnedOnStartup"
            enabled: !(Config.runtime.dock?.keepHidden ?? false)
            opacity: enabled ? 1 : 0.45
        }

        StyledSwitchOption {
            title: "Reveal on hover"
            description: "Show the dock when moving the cursor to the edge."
            prefField: "dock.hoverToReveal"
        }

        StyledSwitchOption {
            title: "Keep hidden"
            description: "Only show the dock on hover, regardless of open windows."
            prefField: "dock.keepHidden"
            enabled: !(Config.runtime.dock?.pinnedOnStartup ?? false)
            opacity: enabled ? 1 : 0.45
        }

        StyledSwitchOption {
            title: "Available in fullscreen"
            description: "Allow the dock to appear when an app is fullscreen."
            prefField: "dock.availableOnFullscreen"
        }
    }

    ContentCard {
        StyledText {
            text: "Position"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        RowLayout {
            spacing: Metrics.spacing(8)

            Repeater {
                model: [
                    { label: "Bottom", value: "bottom", icon: "south"  },
                    { label: "Left",   value: "left",   icon: "west"   },
                    { label: "Right",  value: "right",  icon: "east"   },
                    { label: "Top",    value: "top",    icon: "north"  }
                ]

                StyledButton {
                    required property var modelData
                    readonly property bool conflictsWithBar: modelData.value === (Config.runtime.bar?.position ?? "top")
                    text: modelData.label
                    icon: modelData.icon
                    checked: Config.runtime.dock?.position === modelData.value
                    enabled: !conflictsWithBar
                    opacity: conflictsWithBar ? 0.45 : 1
                    tooltipText: conflictsWithBar ? "Same position as the bar" : ""
                    onClicked: Config.updateKey("dock.position", modelData.value)
                }
            }
        }
    }

    ContentCard {
        StyledText {
            text: "Appearance"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        RowLayout {
            spacing: Metrics.spacing(8)

            Repeater {
                model: [
                    { label: "Default",  value: "default"  },
                    { label: "Floating", value: "floating" }
                ]

                StyledButton {
                    required property var modelData
                    text: modelData.label
                    checked: Config.runtime.dock?.theme === modelData.value
                    onClicked: Config.updateKey("dock.theme", modelData.value)
                }
            }
        }

        NumberStepper {
            label: "Dock height"
            description: "Height of the dock in pixels."
            prefField: "dock.height"
            minimum: 32
            maximum: 120
            step: 4
        }

        NumberStepper {
            label: "Icon size"
            description: "Size of application icons in the dock."
            prefField: "dock.iconSize"
            minimum: 24
            maximum: 96
            step: 4
        }

        NumberStepper {
            label: "Edge margin"
            description: "Distance between the dock and the screen edge."
            prefField: "dock.margin"
            minimum: 0
            maximum: 64
            step: 2
        }

        NumberStepper {
            label: "Icon spacing"
            description: "Space between each icon in the dock."
            prefField: "dock.spacing"
            minimum: 0
            maximum: 32
            step: 2
        }
    }

    ContentCard {
        StyledText {
            text: "Buttons"
            font.pixelSize: Metrics.fontSize(20)
            font.bold: true
        }

        StyledSwitchOption {
            title: "Launcher button"
            description: "Show the launcher button in the dock."
            prefField: "dock.showOverviewButton"
        }
    }
}
