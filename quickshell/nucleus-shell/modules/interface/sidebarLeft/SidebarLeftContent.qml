import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Item {
    anchors.fill: parent
    anchors.leftMargin: 16

    SwipeView {
        id: view

        anchors.fill: parent

        IntelligencePanel {}
        SystemOverview {}
        WallpapersPage {}

    }

    Rectangle {
        height: 2
        width: parent.width - Metrics.margin("verylarge")
        color: Appearance.m3colors.m3outlineVariant
        opacity: 0.6

        anchors {
            top: view.top
            topMargin: segmentedIndicator.height + Metrics.margin("verysmall")
            horizontalCenter: view.horizontalCenter
        }

    }

    Rectangle {
        id: activeTabIndicator

        height: 2
        width: 96
        radius: Metrics.radius(1)
        color: Appearance.m3colors.m3primary
        x: (segmentedIndicator.width / view.count) * view.currentIndex + (segmentedIndicator.width / view.count - width) / 2

        anchors {
            top: segmentedIndicator.bottom
            topMargin: Metrics.margin(8)
        }

        Behavior on x {
            NumberAnimation {
                duration: Metrics.chronoDuration(220)
                easing.type: Easing.OutCubic
            }

        }

    }

    Item {
        id: segmentedIndicator

        height: 56
        width: parent.width

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: [{
                    "icon": "neurology",
                    "text": "Intelligence"
                }, {
                    "icon": "overview",
                    "text": "Overview"
                }, {
                    "icon": "wallpaper",
                    "text": "Wallpapers"
                }]

                Item {
                    width: segmentedIndicator.width / view.count
                    height: parent.height

                    MouseArea {
                        anchors.fill: parent
                        onClicked: view.currentIndex = index
                    }

                    // Icon (true center)
                    MaterialSymbol {
                        icon: modelData.icon
                        iconSize: Metrics.iconSize("huge")
                        color: view.currentIndex === index ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurfaceVariant

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: Metrics.margin(12)
                        }

                    }

                    // Label (independent centering)
                    StyledText {
                        text: modelData.text
                        font.pixelSize: Metrics.fontSize("large")
                        font.weight: Font.Medium
                        color: view.currentIndex === index ? Appearance.m3colors.m3primary : Appearance.m3colors.m3onSurfaceVariant

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 0
                        }

                    }

                }

            }

        }

    }

}
