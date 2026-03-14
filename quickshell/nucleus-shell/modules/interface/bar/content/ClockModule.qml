import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config
import qs.modules.components

Item {
    id: clockContainer

    property string displayName: screen?.name ?? ""
    property var barConfig: ConfigResolver.bar(displayName)

    property bool isVertical:
        barConfig.position === "left"
        || barConfig.position === "right"

    property bool use24h: barConfig.modules.clock?.use24h ?? true
    property bool blink: true

    property int hour24: parseInt(Time.format("HH"))
    property int hour12: ((hour24 + 11) % 12) + 1

    Layout.alignment: Qt.AlignVCenter

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight


    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: blink = !blink
    }


    Rectangle {
        id: background

        anchors.fill: parent

        implicitWidth: isVertical
            ? verticalClock.implicitWidth + 12
            : horizontalClock.implicitWidth + Metrics.margin("large")

        implicitHeight: barConfig.modules.height

        radius: barConfig.modules.radius
                * Config.runtime.appearance.rounding.factor

        color: isVertical
            ? "transparent"
            : Appearance.m3colors.m3surfaceContainerLow
    }


    RowLayout {
        id: horizontalClock

        visible: !isVertical
        anchors.centerIn: parent
        spacing: 3

        StyledText {
            text: use24h
                ? hour24.toString().padStart(2,"0")
                : hour12.toString().padStart(2,"0")
            font.pixelSize: Appearance.font.size.small
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            text: ":"
            font.pixelSize: Appearance.font.size.small
            Layout.alignment: Qt.AlignVCenter
            opacity: blink ? 1 : 0

            Layout.preferredWidth: implicitWidth

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        StyledText {
            text: Time.format("mm")
            font.pixelSize: Appearance.font.size.small
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            visible: !use24h
            text: Time.format("AP").toLowerCase()
            font.pixelSize: Appearance.font.size.small * 0.9
            opacity: 0.8
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            text: " • " + Time.format("dd MMM")
            font.pixelSize: Appearance.font.size.small
            Layout.alignment: Qt.AlignVCenter
        }
    }


    ColumnLayout {
        id: verticalClock

        visible: isVertical
        anchors.centerIn: parent
        spacing: 0

        StyledText {
            text: use24h
                ? hour24.toString().padStart(2,"0")
                : hour12.toString().padStart(2,"0")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            text: Time.format("mm")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Appearance.font.size.small
        }

        StyledText {
            visible: !use24h
            text: Time.format("AP").toLowerCase()
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Appearance.font.size.small * 0.8
            opacity: 0.7
        }
    }
}
