import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.components
import qs.services

Item {
    id: battery

    visible: UPower.batteryPresent
    Layout.alignment: Qt.AlignVCenter

    property string displayName: screen?.name ?? ""

    property bool isVertical:
        ConfigResolver.bar(displayName).position === "left"
        || ConfigResolver.bar(displayName).position === "right"

    property real level: UPower.percentage / 100

    property bool charging: UPower.state === "charging"

    property bool low: UPower.percentage <= 20

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight


    Rectangle {
        id: container

        radius: 999
        anchors.fill: parent

        implicitHeight: ConfigResolver.bar(displayName).modules.height
        implicitWidth: content.implicitWidth + 18

        color: Appearance.m3colors.m3surfaceContainer


        Rectangle {
            id: fill

            height: parent.height
            radius: parent.radius

            width: parent.width * level

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            color: {
                if (charging)
                    return Appearance.m3colors.m3primary
                if (low)
                    return Appearance.m3colors.m3error
                return Appearance.m3colors.m3secondary
            }

            opacity: 0.35
        }


        RowLayout {
            id: content

            anchors.centerIn: parent
            spacing: 6


            MaterialSymbol {
                icon: charging ? "bolt" : UPower.battIcon

                iconSize: Metrics.iconSize(18)

                color: {
                    if (charging)
                        return Appearance.m3colors.m3primary
                    if (low)
                        return Appearance.m3colors.m3error
                    return Appearance.m3colors.m3onSurface
                }
            }


            StyledText {
                text: UPower.percentage + "%"

                animate: false

                font.pixelSize: Appearance.font.size.small

                color: Appearance.m3colors.m3onSurface
            }
        }
    }
}
