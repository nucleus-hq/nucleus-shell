pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    function _slot(defaultPath) {
        const resolved = Qt.resolvedUrl(defaultPath)
        return Qt.createQmlObject(`
            import QtQuick
            QtObject {
                property url  source:     "` + resolved + `"
                property bool overridden: false
                property bool disabled:   false

                function override(newSource) {
                    source     = newSource
                    overridden = true
                }
                function disable() {
                    disabled = true
                }
                property bool active: !disabled
            }
        `, root, "slot_" + defaultPath)
    }

    readonly property var powerMenu:     _slot("../modules/interface/powermenu/Powermenu.qml")
    readonly property var bar:           _slot("../modules/interface/bar/Bar.qml")
    readonly property var launcher:      _slot("../modules/interface/launcher/Launcher.qml")
    readonly property var lockScreen:    _slot("../modules/interface/lockscreen/LockScreen.qml")
    readonly property var background:    _slot("../modules/interface/background/Background.qml")
    readonly property var notifications: _slot("../modules/interface/notifications/Notifications.qml")
    readonly property var overlays:      _slot("../modules/interface/overlays/Overlays.qml")
    readonly property var sidebarRight:  _slot("../modules/interface/sidebarRight/SidebarRight.qml")
    readonly property var sidebarLeft:   _slot("../modules/interface/sidebarLeft/SidebarLeft.qml")
    readonly property var dock:          _slot("../modules/interface/dock/Dock.qml")
}