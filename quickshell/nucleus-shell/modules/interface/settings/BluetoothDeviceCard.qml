import QtQuick
import QtQuick.Layouts
import qs.modules.components 
import qs.config
import qs.modules.functions
import qs.services
import Quickshell.Bluetooth as QsBluetooth

ContentRowCard {
    id: root

    property var device
    property string statusText: ""
    property bool usePrimary: false
    property bool showConnect: false
    property bool showDisconnect: false
    property bool showPair: false
    property bool showRemove: false

    readonly property var d: (device && typeof device === "object") ? device : null

    cardMargin: 0
    cardSpacing: 12

    opacity: (d && (
        d.state === QsBluetooth.BluetoothDeviceState.Connecting ||
        d.state === QsBluetooth.BluetoothDeviceState.Disconnecting
    )) ? 0.6 : 1

    function iconName(dev) {
        if (!dev) return "bluetooth"
        const map = {
            "audio-headset": "headset",
            "audio-headphones": "headphones",
            "input-keyboard": "keyboard",
            "input-mouse": "mouse",
            "input-gaming": "sports_esports",
            "phone": "phone_android",
            "computer": "computer",
            "printer": "print",
            "camera": "photo_camera"
        }
        return map[dev.icon] || "bluetooth"
    }

    MaterialSymbol {
        icon: root.d ? iconName(root.d) : "bluetooth"
        font.pixelSize: 28
        color: root.usePrimary
               ? Appearance.m3colors.m3primary
               : Appearance.m3colors.m3onSurfaceVariant
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        StyledText {
            text: root.d ? (root.d.name || root.d.address || "Unknown Device") : ""
            font.pixelSize: Metrics.fontSize(15)
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        StyledText {
            text: root.statusText
            font.pixelSize: Metrics.fontSize(12)
            color: root.usePrimary
                   ? Appearance.m3colors.m3primary
                   : Appearance.m3colors.m3onSurfaceVariant
        }
    }

    Item { Layout.fillWidth: true }

    RowLayout {
        spacing: 6

        StyledButton {
            visible: root.showConnect && root.d
            icon: "link"
            onClicked: if (root.d) root.d.connect()
        }

        StyledButton {
            visible: root.showDisconnect && root.d
            icon: "link_off"
            onClicked: if (root.d) root.d.disconnect()
        }

        StyledButton {
            visible: root.showPair && root.d
            icon: "add"
            onClicked: if (root.d) root.d.pair()
        }

        StyledButton {
            visible: root.showRemove && root.d
            icon: "delete"
            onClicked: if (root.d) Bluetooth.removeDevice(root.d)
        }
    }
}