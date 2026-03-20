import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    
    Layout.fillWidth: true
    implicitHeight: container.implicitHeight

    default property alias content: contentArea.data
    property alias radius: container.radius

    property int cardMargin: Metrics.margin(20)
    property int cardSpacing: Metrics.spacing(10)
    property int padding: Metrics.padding(20)

    Rectangle {
        id: container
        anchors.fill: parent

        radius: Metrics.radius("large")

        // 🔥 CRITICAL FIX: use solid color (no alpha stacking issues)
        color: Appearance.m3colors.m3surface

        border.width: 1
        border.color: Appearance.m3colors.m3outlineVariant

        implicitHeight: contentArea.implicitHeight + root.padding * 2

        Behavior on color {
            enabled: Config.runtime.appearance.animations.enabled
            ColorAnimation {
                duration: Metrics.chronoDuration("fast")
                easing.type: Easing.OutCubic
            }
        }
    }

    RowLayout {
        id: contentArea
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: root.cardSpacing
    }
}