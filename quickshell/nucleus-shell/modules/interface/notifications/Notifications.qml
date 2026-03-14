import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.config
import qs.modules.components

Scope {
    id: root

    property int innerSpacing: Metrics.spacing(10)

    PanelWindow {
        id: window

        implicitWidth: 550
        visible: true
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        WlrLayershell.namespace: "nucleus:notification"

        anchors {
            top: true
            left: Config.runtime.notifications.position.endsWith("left")
            bottom: true
            right: Config.runtime.notifications.position.endsWith("right")
        }

        Item {
            id: notificationList

            anchors.leftMargin: 0
            anchors.topMargin: Metrics.margin(10)
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Rectangle {
                id: bgRectangle

                layer.enabled: true
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: Metrics.margin(20)
                anchors.rightMargin: Metrics.margin(20)
                anchors.right: parent.right
                height: window.mask.height > 0 ? window.mask.height + 40 : 0
                color: "transparent"
                radius: Metrics.radius("large")

                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.m3colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                Behavior on height {
                    enabled: Config.runtime.appearance.animations.enabled
                    NumberAnimation {
                        duration: Metrics.chronoDuration("small")
                        easing.type: Easing.InOutExpo
                    }

                }

            }

            Item {
                id: notificationColumn

                anchors.left: parent.left
                anchors.right: parent.right

                Repeater {
                    id: rep
                    model: (!Config.runtime.notifications.doNotDisturb && Config.runtime.notifications.enabled) ? NotifServer.data : []

                    NotificationChild {
                        id: child

                        required property var modelData
                        required property int index

                        visible: modelData.popup
                        width: notificationColumn.width - 80
                        anchors.horizontalCenter: notificationColumn.horizontalCenter
                        y: {
                            var pos = 0
                            for (let i = 0; i < index; i++) {
                                var prev = rep.itemAt(i)
                                if (prev && prev.visible)
                                    pos += prev.height + root.innerSpacing
                            }
                            return pos + 20
                        }

                        Component.onCompleted: {
                            if (!modelData.shown)
                                modelData.shown = true
                        }

                        title: modelData.summary
                        appName: modelData.appName
                        timestamp: Qt.formatTime(modelData.time, "hh:mm")
                        body: modelData.body
                        image: modelData.image || modelData.appIcon
                        urgency: modelData.urgency
                        rawNotif: modelData
                        tracked: modelData.shown
                        buttons: modelData.actions.map((action) => ({
                            "label": action.text,
                            "onClick": () => action.invoke()
                        }))

                        Behavior on y {
                            enabled: Config.runtime.appearance.animations.enabled
                            NumberAnimation {
                                duration: Metrics.chronoDuration("normal")
                                easing.type: Easing.InOutExpo
                            }
                        }
                    }
                }

            }

        }

        mask: Region {
            width: window.width
            height: {
                var total = 0
                var visibleCount = 0
                for (let i = 0; i < rep.count; i++) {
                    var child = rep.itemAt(i)
                    if (child && child.visible) {
                        total += child.height
                        if (visibleCount > 0) total += root.innerSpacing
                        visibleCount++
                    }
                }
                return total
            }
        }

    }

}
