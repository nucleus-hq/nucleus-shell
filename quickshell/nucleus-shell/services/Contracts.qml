pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs.services

// Backward-compatibility shim.
// Contracts.bar.source, Contracts.bar.active etc. all still work.
// Migrate callers to ModuleRegistry directly over time, then delete this file.
QtObject {
    id: root

    readonly property var bar:           ModuleRegistry.bar
    readonly property var background:    ModuleRegistry.background
    readonly property var powerMenu:     ModuleRegistry.powerMenu
    readonly property var launcher:      ModuleRegistry.launcher
    readonly property var notifications: ModuleRegistry.notifications
    readonly property var overlays:      ModuleRegistry.overlays
    readonly property var sidebarRight:  ModuleRegistry.sidebarRight
    readonly property var sidebarLeft:   ModuleRegistry.sidebarLeft
    readonly property var lockScreen:    ModuleRegistry.lockScreen
    readonly property var dock:          ModuleRegistry.dock
}