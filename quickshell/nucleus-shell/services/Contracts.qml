pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    // Power menu
    property url powerMenu: Qt.resolvedUrl("../modules/interface/powermenu/Powermenu.qml")
    property bool overriddenPowerMenu: false
    function overridePowerMenu() {
        overriddenPowerMenu = true
    }

    // Bar
    property url bar: Qt.resolvedUrl("../modules/interface/bar/Bar.qml")
    property bool overriddenBar: false
    function overrideBar() {
        overriddenBar = true
    }

    // App launcher
    property url launcher: Qt.resolvedUrl("../modules/interface/launcher/Launcher.qml")
    property bool overriddenLauncher: false
    function overrideLauncher() {
        overriddenLauncher = true
    }

    // Lock screen
    property url lockScreen: Qt.resolvedUrl("../modules/interface/lockscreen/LockScreen.qml")
    property bool overriddenLockScreen: false
    function overrideLockScreen() {
        overriddenLockScreen = true
    }

    // Desktop background / wallpaper handler
    property url background: Qt.resolvedUrl("../modules/interface/background/Background.qml")
    property bool overriddenBackground: false
    function overrideBackground() {
        overriddenBackground = true
    }

    // Notifications UI
    property url notifications: Qt.resolvedUrl("../modules/interface/notifications/Notifications.qml")
    property bool overriddenNotifications: false
    function overrideNotifications() {
        overriddenNotifications = true
    }

    // Global overlays (OSD, volume, brightness, etc.)
    property url overlays: Qt.resolvedUrl("../modules/interface/overlays/Overlays.qml")
    property bool overriddenOverlays: false
    function overrideOverlays() {
        overriddenOverlays = true
    }

    // Right sidebar
    property url sidebarRight: !overriddenSidebarRight ? Qt.resolvedUrl("../modules/interface/sidebarRight/SidebarRight.qml") : "" // Force override
    property bool overriddenSidebarRight: false
    function overrideSidebarRight() {
        overriddenSidebarRight = true
    }

    // Left sidebar
    property url sidebarLeft: !overriddenSidebarLeft ? Qt.resolvedUrl("../modules/interface/sidebarLeft/SidebarLeft.qml") : "" // Force override
    property bool overriddenSidebarLeft: false
    function overrideSidebarLeft() {
        overriddenSidebarLeft = true
    }

    // Dock
    property url dock: Qt.resolvedUrl("../modules/interface/dock/Dock.qml")
    property bool overriddenDock: false
    function overrideDock() {
        overriddenDock = true
    }
}
