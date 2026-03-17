pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs.config

// from github.com/end-4/dots-hyprland with modifications

Singleton {
    id: root

    property list<Notif> data: []
    property list<Notif> popups: {
        let result = []
        for (let i = 0; i < data.length; i++) {
            if (data[i].popup) result.push(data[i])
        }
        return result
    }
    property list<Notif> history: data

    NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            root.data.push(notifComp.createObject(root, {
                popup: true,
                notification: notif,
                shown: false
            }));
        }
    }
    
    function removeById(id) {
        const i = data.findIndex(n => n.notification.id === id);
        if (i >= 0) {
            data.splice(i, 1);
        }
    }


    component Notif: QtObject {
        id: notif

        property bool popup
        readonly property date time: new Date()
        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        property bool shown: false
        required property Notification notification
        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property int urgency: notification.urgency
        readonly property list<NotificationAction> actions: notification.actions

        readonly property Timer timer: Timer {
            running: true
            interval: {
                if (notif.notification.expireTimeout > 0)
                    return notif.notification.expireTimeout
                if (notif.urgency === 2)
                    return 15000  // critical: 15 seconds
                return 5000
            }
            onTriggered: {
                notif.popup = false
            }
        }

        readonly property Connections conn2: Connections {
            target: notif.notification

            function onClosed(reason) {
                const i = root.data.indexOf(notif)
                if (i >= 0)
                    root.data.splice(i, 1)
            }
        }

        readonly property Connections conn: Connections {
            target: notif.notification.Retainable

            function onDropped(): void {
                const i = root.data.indexOf(notif)
                if (i >= 0)
                    root.data.splice(i, 1)
            }

            function onAboutToDestroy(): void {
                notif.destroy()
            }
        }

    }

    Component {
        id: notifComp

        Notif {}
    }
}
