import QtQuick
import QtQuick.Layouts
import qs.modules.functions
import qs.config
import qs.modules.components
import qs.services

ContentMenu {
    id: root

    title: "Network"
    description: "Manage network connections."

    ContentCard {
        ContentRowCard {
            cardSpacing: 0
            cardMargin: 0

            StyledText {
                text: powerSwitch.checked ? "Wi-Fi: On" : "Wi-Fi: Off"
                font.pixelSize: Metrics.fontSize(16)
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                id: powerSwitch
                checked: Network.wifiEnabled
                onToggled: Network.enableWifi(checked)
            }
        }

        ContentRowCard {
            visible: Network.wifiEnabled
            cardSpacing: 0
            cardMargin: 0

            ColumnLayout {
                spacing: 2

                StyledText {
                    text: "Scanning"
                    font.pixelSize: Metrics.fontSize(15)
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Search for nearby Wi-Fi networks"
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                checked: Network.scanning
                onToggled: if (checked) Network.rescan()
            }
        }
    }

    InfoCard {
        visible: Network.message !== "" && Network.message !== "ok"
        icon: "error"
        containerColor: Appearance.m3colors.m3errorContainer
        contentColor: Appearance.m3colors.m3onErrorContainer
        title: "Failed to connect to " + (Network.lastNetworkAttempt || "")
        description: Network.message
    }

    ContentCard {
        visible: Network.active !== null

        StyledText {
            text: "Active Connection"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        NetworkCard {
            connection: Network.active
            isActive: true
            showDisconnect: Network.active && Network.active.type === "wifi"
        }
    }

    ContentCard {
        visible: (Network.connections || []).filter(c => c && c.type === "ethernet").length > 0

        StyledText {
            text: "Ethernet"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Repeater {
            model: (Network.connections || []).filter(c => c && c.type === "ethernet" && !c.active)

            delegate: NetworkCard {
                connection: modelData
                showConnect: true
            }
        }
    }

    ContentCard {
        visible: Network.wifiEnabled

        StyledText {
            text: "Available Wi-Fi Networks"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Item {
            visible: (Network.connections || []).filter(c => c && c.type === "wifi").length === 0 && !Network.scanning
            width: parent.width
            height: 40

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "No networks found"
                font.pixelSize: Metrics.fontSize(14)
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        Repeater {
            model: (Network.connections || []).filter(c => c && c.type === "wifi" && !c.active)

            delegate: NetworkCard {
                connection: modelData
                showConnect: true
            }
        }
    }

    ContentCard {
        visible: (Network.savedNetworks || []).length > 0

        StyledText {
            text: "Remembered Networks"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Item {
            visible: (Network.savedNetworks || []).length === 0
            width: parent.width
            height: 40

            StyledText {
                text: "No remembered networks"
                font.pixelSize: Metrics.fontSize(14)
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        Repeater {
            model: (Network.connections || []).filter(c => c && c.type === "wifi" && c.saved && !c.active)

            delegate: NetworkCard {
                connection: modelData
                showConnect: false
                showDisconnect: false
            }
        }
    }
}