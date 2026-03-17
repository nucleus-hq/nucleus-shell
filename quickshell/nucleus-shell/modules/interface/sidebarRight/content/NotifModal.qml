import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.functions
import qs.modules.interface.notifications
import qs.services
import qs.config
import qs.modules.components

StyledRect {
    id: root

    Layout.fillWidth: true
    radius: Metrics.radius("normal")
    color: Appearance.colors.colLayer1
    property bool dndActive: Config.runtime.notifications.doNotDisturb

    function toggleDnd() {
        Config.updateKey("notifications.doNotDisturb", !dndActive);
    }

    StyledButton {
        id: clearButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Metrics.margin(10)
        anchors.rightMargin: Metrics.margin(10)
        icon: "clear_all"
        text: "Clear"
        implicitHeight: 40
        implicitWidth: 100
        secondary: true

        onClicked: {
            const snapshot = NotifServer.data.slice()
            for (let i = 0; i < snapshot.length; i++) {
                const n = snapshot[i]
                if (n?.notification) n.notification.dismiss()
            }
        }
    }

    StyledButton {
        id: silentButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: Metrics.margin(10)
        anchors.rightMargin: clearButton.implicitWidth + Metrics.margin(15)
        text: "Silent"
        icon: "do_not_disturb_on"
        implicitHeight: 40
        implicitWidth: 100
        secondary: true
        checkable: true 
        checked: Config.runtime.notifications.doNotDisturb

        onClicked: {
            toggleDnd()
        }
    }

    StyledText {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Metrics.margin(15)
        anchors.leftMargin: Metrics.margin(15)
        text: NotifServer.data.length + " Notifications"

    }

    StyledText {
        anchors.centerIn: parent
        text: "No notifications"
        visible: NotifServer.data.length < 1
        font.pixelSize: Metrics.fontSize("huge")
    }

    ListView {
        id: notifList
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: clearButton.top
        anchors.margins: Metrics.margin(10)

        clip: true
        spacing: Metrics.spacing(8)
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { }

        model: Config.runtime.notifications.enabled
            ? NotifServer.history
            : []

        delegate: NotificationChild {
            required property var modelData

            width: notifList.width
            tracked: true
            title: modelData.summary
            body: modelData.body
            appName: modelData.appName
            isHistory: true
            timestamp: Qt.formatTime(modelData.time, "hh:mm")
            urgency: modelData.urgency
            image: modelData.image || modelData.appIcon
            rawNotif: modelData
            buttons: modelData.actions.map((action) => ({
                "label": action.text,
                "onClick": () => action.invoke()
            }))
        }
    }

}
