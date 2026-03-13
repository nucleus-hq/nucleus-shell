import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
property string barKey: "bar"
title: "Bar"
description: "Adjust the bar's look."

ContentCard {
    id: monitorSelectorCard
    
    StyledText { 
        text: "Monitor Bar Configuration"
        font.pixelSize: Metrics.fontSize(20)
        font.bold: true
    }

    StyledText {
        text: (Config.runtime.monitors?.[monitorSelector.model[monitorSelector.currentIndex]]?.bar)
            ? "This monitor has its own bar configuration."
            : "This monitor currently uses the global bar."
        wrapMode: Text.WordWrap
    }

    RowLayout {
        spacing: Metrics.spacing("normal")

        StyledDropDown {
            id: monitorSelector
            Layout.preferredWidth: 220
            model: Xrandr.monitors.map(m => m.name)
            currentIndex: 0
            onCurrentIndexChanged: monitorSelectorCard.updateMonitorProperties()
        }

        Item { Layout.fillWidth: true }

        StyledButton {
            id: createButton
            icon: "add"
            text: "Override Bar: (" + monitorSelector.model[monitorSelector.currentIndex] + ")"
            Layout.preferredWidth: 280
            onClicked: {
                const monitorName = monitorSelector.model[monitorSelector.currentIndex]
                if (!monitorName) return
                if (!Config.runtime.monitors) Config.runtime.monitors = {}
                if (!Config.runtime.monitors[monitorName])
                    Config.runtime.monitors[monitorName] = {}

                const defaultBar = {
                    density: 50,
                    enabled: true,
                    floating: false,
                    gothCorners: true,
                    pill: false,
                    margins: 16,
                    merged: false,
                    modules: {
                        height: 34,
                        paddingColor: "#1f1f1f",
                        radius: 17,
                        statusIcons: { 
                            bluetoothStatusEnabled: true, 
                            enabled: true, 
                            networkStatusEnabled: true 
                        },
                        systemUsage: { 
                            cpuStatsEnabled: true, 
                            enabled: true, 
                            memoryStatsEnabled: true, 
                            tempStatsEnabled: true 
                        },
                        workspaces: { 
                            enabled: true, 
                            showAppIcons: true, 
                            showJapaneseNumbers: false, 
                            workspaceIndicators: 8 
                        }
                    },
                    position: "top",
                    radius: 23
                }

                Config.updateKey("monitors." + monitorName + ".bar", defaultBar)
                monitorSelectorCard.updateMonitorProperties()
            }
        }

        StyledButton {
            id: deleteButton
            icon: "delete"
            text: "Use Global Bar: (" + monitorSelector.model[monitorSelector.currentIndex] + ")"
            secondary: true
            Layout.preferredWidth: 280
            onClicked: {
                const monitorName = monitorSelector.model[monitorSelector.currentIndex]
                if (!monitorName) return
                Config.updateKey("monitors." + monitorName + ".bar", undefined)
                monitorSelectorCard.updateMonitorProperties()
            }
        }
    }

    function updateMonitorProperties() {
        const monitorName = monitorSelector.model[monitorSelector.currentIndex]
        const monitorBar = Config.runtime.monitors?.[monitorName]?.bar
        barKey = monitorBar ? "monitors." + monitorName + ".bar" : "bar"

        createButton.enabled = !monitorBar
        deleteButton.enabled = !!monitorBar

        monitorSelector.model = Xrandr.monitors.map(m => m.name)
        monitorSelector.currentIndex = Xrandr.monitors.findIndex(m => m.name === monitorName)
    }
}

ContentCard {
    StyledText { 
        text: "Bar"
        font.pixelSize: Metrics.fontSize(20)
        font.bold: true
    }

    ColumnLayout {
        StyledText { 
            text: "Position"
            font.pixelSize: Metrics.fontSize(16)
        }
        
        RowLayout {
            spacing: Metrics.spacing(8)
            Repeater {
                model: ["Top", "Bottom", "Left", "Right"]
                delegate: StyledButton {
                    property string pos: modelData.toLowerCase()
                    text: modelData
                    Layout.fillWidth: true
                    checked: ConfigResolver.bar(monitorSelector.model[monitorSelector.currentIndex]).position === pos
                    onClicked: Config.updateKey(barKey + ".position", pos)
                }
            }
        }
    }

    StyledSwitchOption { 
        title: "Enabled"
        description: "Toggle the bar visibility on/off"
        prefField: barKey + ".enabled" 
    }

    StyledSwitchOption { 
        title: "Floating Bar"
        description: "Make the bar float above other windows instead of being part of the desktop"
        prefField: barKey + ".floating" 
    }

    StyledSwitchOption { 
        title: "Goth Corners"
        description: "Apply gothic-style corner cutouts to the bar"
        prefField: barKey + ".gothCorners" 
    }

    StyledSwitchOption { 
        title: "Merged Layout"
        description: "Merge all modules into a single continuous layout"
        prefField: barKey + ".merged" 
    }

    StyledSwitchOption {
        title: "Pill Bar"
        description: "Strip the bar background and render modules in a pill-style layout"
        prefField: barKey + ".pill"
    }
}

ContentCard {
    StyledText { 
        text: "Bar Rounding & Size"
        font.pixelSize: Metrics.fontSize(20)
        font.bold: true
    }

    NumberStepper { 
        label: "Bar Density"
        prefField: barKey + ".density"
        description: "Modify the bar's density"
        minimum: 40
        maximum: 128
    }

    NumberStepper { 
        label: "Bar Radius"
        prefField: barKey + ".radius"
        description: "Modify the bar's radius"
        minimum: 10
        maximum: 128
    }

    NumberStepper { 
        label: "Module Container Radius"
        prefField: barKey + ".modules.radius"
        description: "Modify the bar's module.radius"
        minimum: 10
        maximum: 128
    }

    NumberStepper { 
        label: "Module Height"
        prefField: barKey + ".modules.height"
        description: "Modify the bar's module.height"
        minimum: 10
        maximum: 128
    }

    NumberStepper { 
        label: "Workspace Indicators"
        prefField: barKey + ".modules.workspaces.workspaceIndicators"
        description: "Adjust how many workspace indicators to show."
        minimum: 1
        maximum: 10
    }
}

ContentCard {
    StyledText { 
        text: "Bar Modules"
        font.pixelSize: Metrics.fontSize(20)
        font.bold: true
    }

    StyledText { text: "Workspaces"; font.pixelSize: Metrics.fontSize(18); font.bold: true }

    StyledSwitchOption { 
        title: "Enabled"
        description: "Show workspace indicator module"
        prefField: barKey + ".modules.workspaces.enabled" 
    }

    StyledSwitchOption { 
        title: "Show App Icons"
        description: "Display application icons in workspace indicators"
        prefField: barKey + ".modules.workspaces.showAppIcons"
    }

    StyledSwitchOption { 
        title: "Show Japanese Numbers"
        description: "Use Japanese-style numbers instead of standard numerals"
        prefField: barKey + ".modules.workspaces.showJapaneseNumbers"
    }

    StyledSwitchOption { 
        title: "Dynamic Workspaces"
        description: "Hide empty workspaces and only show occupied ones"
        prefField: barKey + ".modules.workspaces.dynamic"
    }

    StyledText { text: "Status Icons"; font.pixelSize: Metrics.fontSize(18); font.bold: true }

    StyledSwitchOption { 
        title: "Enabled"
        description: "Show status icons module"
        prefField: barKey + ".modules.statusIcons.enabled" 
    }

    StyledSwitchOption { 
        title: "Show Wifi Status"
        description: "Display wifi connection status"
        prefField: barKey + ".modules.statusIcons.networkStatusEnabled" 
    }

    StyledSwitchOption { 
        title: "Show Bluetooth Status"
        description: "Display bluetooth connection status"
        prefField: barKey + ".modules.statusIcons.bluetoothStatusEnabled" 
    }

    StyledText { text: "System Stats"; font.pixelSize: Metrics.fontSize(18); font.bold: true }

    StyledSwitchOption { 
        title: "Enabled"
        description: "Show system monitoring module"
        prefField: barKey + ".modules.systemUsage.enabled" 
    }

    StyledSwitchOption { 
        title: "Show Cpu Usage Stats"
        prefField: barKey + ".modules.systemUsage.cpuStatsEnabled" 
    }

    StyledSwitchOption { 
        title: "Show Memory Usage Stats"
        prefField: barKey + ".modules.systemUsage.memoryStatsEnabled" 
    }

    StyledSwitchOption { 
        title: "Show Cpu Temperature Stats"
        prefField: barKey + ".modules.systemUsage.tempStatsEnabled" 
    }
}
}
