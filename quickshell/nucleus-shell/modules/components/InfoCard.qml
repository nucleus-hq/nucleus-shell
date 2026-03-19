import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string icon: "info"
    property string title: "Title"
    property string description: "Description"

    property color containerColor: Appearance.m3colors.m3errorContainer
    property color contentColor: Appearance.m3colors.m3onErrorContainer

    implicitWidth: parent ? parent.width : 400
    implicitHeight: contentRow.implicitHeight + Metrics.margin(16) * 2

    Rectangle {
        anchors.fill: parent
        radius: Metrics.radius("normal")
        color: root.containerColor
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Metrics.margin(16)
        spacing: Metrics.spacing(16)

        Rectangle {
            width: 36
            height: 36
            radius: Metrics.radius(1000)
            color: Qt.alpha(root.contentColor, 0.12)

            MaterialSymbol {
                anchors.centerIn: parent
                icon: root.icon
                iconSize: Metrics.iconSize(22)
                color: root.contentColor
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: root.title
                font.pixelSize: Metrics.fontSize(14)
                font.weight: Font.Medium
                color: root.contentColor
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StyledText {
                text: root.description
                font.pixelSize: Metrics.fontSize(12)
                color: Qt.alpha(root.contentColor, 0.8)
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
    }
}