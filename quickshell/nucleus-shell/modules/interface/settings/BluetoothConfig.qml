import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services
import Quickshell.Bluetooth as QsBluetooth

ContentMenu {
    id: root

    title: "Bluetooth"
    description: "Manage Bluetooth devices and connections."

    readonly property var adapter: Bluetooth.defaultAdapter

    ContentCard {
        ContentRowCard {
            cardSpacing: 0
            cardMargin: 0

            StyledText {
                text: powerSwitch.checked ? "Power: On" : "Power: Off"
                font.pixelSize: Metrics.fontSize(16)
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                id: powerSwitch
                checked: root.adapter ? root.adapter.enabled : false
                onToggled: if (root.adapter) root.adapter.enabled = checked
            }
        }

        ContentRowCard {
            visible: root.adapter && root.adapter.enabled
            cardSpacing: 0
            cardMargin: 0

            ColumnLayout {
                spacing: 2

                StyledText {
                    text: "Discoverable"
                    font.pixelSize: Metrics.fontSize(15)
                    font.weight: Font.Medium
                }

                StyledText {
                    text: "Allow other devices to find this computer"
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                checked: root.adapter ? root.adapter.discoverable : false
                onToggled: if (root.adapter) root.adapter.discoverable = checked
            }
        }

        ContentRowCard {
            visible: root.adapter && root.adapter.enabled
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
                    text: "Search for nearby Bluetooth devices"
                    font.pixelSize: Metrics.fontSize(12)
                    color: Appearance.m3colors.m3onSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                checked: root.adapter ? root.adapter.discovering : false
                onToggled: if (root.adapter) root.adapter.discovering = checked
            }
        }
    }

    ContentCard {
        visible: connectedDevices.count > 0

        StyledText {
            text: "Connected Devices"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Repeater {
            id: connectedDevices
            model: (Bluetooth.devices || []).filter(d => d && d.connected)

            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: modelData && modelData.batteryAvailable
                    ? "Connected • " + Math.floor(modelData.battery * 100) + "%"
                    : "Connected"
                showDisconnect: true
                showRemove: true
                usePrimary: true
            }
        }
    }

    ContentCard {
        visible: root.adapter && root.adapter.enabled

        StyledText {
            text: "Paired Devices"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Item {
            visible: pairedDevices.count === 0
            width: parent.width
            height: 40

            StyledText {
                text: "No paired devices"
                font.pixelSize: Metrics.fontSize(14)
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        Repeater {
            id: pairedDevices
            model: (Bluetooth.devices || []).filter(d => d && !d.connected && d.paired)

            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: "Not connected"
                showConnect: true
                showRemove: true
            }
        }
    }

    ContentCard {
        visible: root.adapter && root.adapter.enabled

        StyledText {
            text: "Available Devices"
            font.pixelSize: Metrics.fontSize(18)
            font.weight: Font.DemiBold
        }

        Item {
            visible: discoveredDevices.count === 0 && !(root.adapter && root.adapter.discovering)
            width: parent.width
            height: 40

            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No new devices found"
                font.pixelSize: Metrics.fontSize(14)
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }

        Repeater {
            id: discoveredDevices
            model: (Bluetooth.devices || []).filter(d => d && !d.paired && !d.connected)

            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: "Discovered"
                showConnect: true
                showPair: true
            }
        }
    }
}