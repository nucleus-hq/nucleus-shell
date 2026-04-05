import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import "."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 0

    GridLayout {
        Layout.fillWidth: true
        columns: 1
        columnSpacing: Metrics.spacing(8)
        rowSpacing: Metrics.spacing(8)
        Layout.preferredWidth: parent.width

        RowLayout {
            NetworkToggle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }
            FlightModeToggle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
            }
        }

        RowLayout {
            BluetoothToggle {
                Layout.preferredWidth: 220
                Layout.preferredHeight: 80
            }
            ThemeToggle {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
            }
            NightModeToggle {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.m3colors.m3outlineVariant
        radius: Metrics.radius(1)
        Layout.topMargin: Metrics.margin(5)
        Layout.bottomMargin: Metrics.margin(5)
    }
}