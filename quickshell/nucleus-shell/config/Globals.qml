import QtQuick
pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell

Singleton {
    id: root
    property QtObject visiblility
    property QtObject states

    visiblility: QtObject {
        property bool powermenu: false
        property bool launcher: false
        property bool sidebarRight: false
        property bool sidebarLeft: false
        // Widths used by the dock to shift away from open sidebars
        property int sidebarLeftWidth: 480
        property int sidebarRightWidth: 500
    }

    states: QtObject {
        property bool settingsOpen: false
        property bool intelligenceWindowOpen: false
    }

}
