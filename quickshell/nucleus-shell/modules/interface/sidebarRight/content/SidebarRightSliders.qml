import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import "."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 0

    VolumeSlider {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        icon: "volume_up"
        iconSize: Metrics.iconSize("large") + 3
    }

    BrightnessSlider {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        icon: "brightness_high"
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Appearance.m3colors.m3outlineVariant
        radius: Metrics.radius(1)
    }
}