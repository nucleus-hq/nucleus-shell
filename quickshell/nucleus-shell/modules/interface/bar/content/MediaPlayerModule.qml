import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Item {
    id: mediaPlayer

    property var barConfig: screen && Config.bar?.[screen.name]
        ? Config.bar[screen.name]
        : Config.runtime.bar

    property bool isVertical: (
        barConfig.position === "left" ||
        barConfig.position === "right"
    )

    Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter

    implicitWidth: bgRect.implicitWidth
    implicitHeight: bgRect.implicitHeight


    Rectangle {
        id: bgRect

        radius: barConfig.modules.radius *
                Config.runtime.appearance.rounding.factor

        implicitWidth: isVertical
            ? row.implicitWidth + Metrics.margin("large") - 10
            : row.implicitWidth + Metrics.margin("large")

        implicitHeight: barConfig.modules.height

        color: "transparent"


        Image {
            id: blurSource

            anchors.centerIn: parent
            width: parent.width * 1.6
            height: parent.height * 1.6

            source: Mpris.artUrl
            visible: false

            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
        }


        FastBlur {
            id: blurred
            anchors.fill: parent
            source: blurSource
            radius: 70
            visible: false
        }


        OpacityMask {
            anchors.fill: parent
            visible: Mpris.artUrl !== ""

            source: blurred

            maskSource: Rectangle {
                width: bgRect.width
                height: bgRect.height
                radius: bgRect.radius
                color: "black"
            }
        }


        Rectangle {
            anchors.fill: parent
            radius: bgRect.radius
            color: Appearance.m3colors.m3paddingContainer
            opacity: Mpris.artUrl !== "" ? 0.35 : 1
        }
    }


    Row {
        id: row

        anchors.centerIn: parent
        spacing: Metrics.margin("small")


        ClippingRectangle {
            id: iconButton

            width: 24
            height: 24

            radius: barConfig.modules.radius / 1.2

            color: Appearance.colors.colLayer1Hover
            opacity: hoverArea.containsMouse ? 1 : 0.9

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


                Rectangle {
                    id: hoverOverlay

                    anchors.fill: parent
                    radius: parent.radius

                    color: "#66000000"
                    opacity: hoverArea.containsMouse ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 120 }
                    }


                    MaterialSymbol {
                        anchors.centerIn: parent

                        icon: Mpris.isPlaying ? "pause" : "play_arrow"
                        iconSize: 16
                        color: "white"
                    }
                }
            }


            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: Mpris.playPause()
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
