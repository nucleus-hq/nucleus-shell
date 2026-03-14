import QtQuick
import QtQuick.Layouts
import qs.modules.components
import qs.services

Item {

    signal setWallpaper()

    anchors.centerIn: parent

    Rectangle {

        width: 550
        height: 400
        radius: Appearance.rounding.windowRounding
        color: "transparent"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Metrics.margin("small")

            MaterialSymbol {
                text: "wallpaper"
                font.pixelSize: Metrics.fontSize("wildass")
                color: Appearance.colors.colOnLayer2
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                text: "Wallpaper Missing"
                font.pixelSize: Metrics.fontSize("hugeass")
                font.bold: true
                color: Appearance.colors.colOnLayer2
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                text: "Seems like you haven't set a wallpaper yet."
                font.pixelSize: Metrics.fontSize("small")
                color: Appearance.colors.colSubtext
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }

            StyledButton {
                text: "Set wallpaper"
                icon: "wallpaper"
                secondary: true
                radius: Metrics.radius("large")
                Layout.alignment: Qt.AlignHCenter
                onClicked: setWallpaper()
            }
        }
    }
}