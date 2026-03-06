import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Item {
    id: mediaPlayer

    property bool isVertical: (
        Config.runtime.bar.position === "left" ||
        Config.runtime.bar.position === "right"
    )

    Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter

    implicitWidth: bgRect.implicitWidth
    implicitHeight: bgRect.implicitHeight


    Rectangle {
        id: bgRect

        color: Appearance.m3colors.m3paddingContainer
        radius: Config.runtime.bar.modules.radius *
                Config.runtime.appearance.rounding.factor

        implicitWidth: isVertical
            ? row.implicitWidth + Metrics.margin("large") - 10
            : row.implicitWidth + Metrics.margin("large")

        implicitHeight: Config.runtime.bar.modules.height
    }


    Row {
        id: row

        anchors.centerIn: parent
        spacing: Metrics.margin("small")


        ClippingRectangle {
            id: iconButton

            width: 24
            height: 24
            radius: Config.runtime.bar.modules.radius / 1.2

            color: Appearance.colors.colLayer1Hover
            opacity: 0.9

            clip: true
            layer.enabled: true


            Item {
                anchors.fill: parent


                Image {
                    id: art

                    anchors.fill: parent
                    visible: Mpris.artUrl !== ""

                    source: Mpris.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }


                MaterialSymbol {
                    anchors.centerIn: parent

                    visible: Mpris.artUrl === ""
                    icon: "music_note"

                    iconSize: 18
                    color: Config.runtime.appearance.theme === "dark"
                        ? "#b1a4a4"
                        : "grey"
                }
            }


            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onClicked: Mpris.playPause()

                onEntered: iconButton.opacity = 1
                onExited: iconButton.opacity = 0.9
            }


            RotationAnimation on rotation {
                from: 0
                to: 360

                duration: Metrics.chronoDuration(4000)
                loops: Animation.Infinite

                running: Mpris.isPlaying &&
                         Config.runtime.appearance.animations.enabled
            }
        }


        StyledText {
            id: textItem

            anchors.verticalCenter: parent.verticalCenter

            text: StringUtils.shortText(Mpris.title, 16)

            visible: !mediaPlayer.isVertical
        }
    }
}
