pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import qs.config

QtObject {
    id: root

    // Plain JS objects — no Qt.createQmlObject, no dynamic component creation.
    // source:     resolved URL of the default QML file
    // active:     master on/off for this module
    // overridden: true if source was replaced by a plugin
    // slots:      map of slotId → SlotDescriptor (optional, add per module as needed)

    function _mod(defaultSource, slots) {
        return {
            source:      Qt.resolvedUrl(defaultSource),
            active:      true,
            overridden:  false,
            slots:       slots || {}
        }
    }

    // source:   resolved URL of default slot QML file
    // active:   individual slot on/off
    // override: replacement URL (null = use default)
    function _slot(relativePath) {
        return {
            source:   Qt.resolvedUrl(relativePath),
            active:   true,
            override: null
        }
    }

    // Modules without slots are flat
    readonly property var bar: _mod(
        "../modules/interface/bar/Bar.qml"
    )

    readonly property var background: _mod(
        "../modules/interface/background/Background.qml"
    )

    readonly property var powerMenu: _mod(
        "../modules/interface/powermenu/Powermenu.qml"
    )

    readonly property var launcher: _mod(
        "../modules/interface/launcher/Launcher.qml"
    )

    readonly property var notifications: _mod(
        "../modules/interface/notifications/Notifications.qml"
    )

    readonly property var overlays: _mod(
        "../modules/interface/overlays/Overlays.qml"
    )

    readonly property var lockScreen: _mod(
        "../modules/interface/lockscreen/LockScreen.qml"
    )

    readonly property var dock: _mod(
        "../modules/interface/dock/Dock.qml"
    )

    readonly property var sidebarLeft: _mod(
        "../modules/interface/sidebarLeft/SidebarLeft.qml"
    )

    readonly property var sidebarRight: _mod(
        "../modules/interface/sidebarRight/SidebarRight.qml",
        {
            header: _slot(
                "../modules/interface/sidebarRight/content/SidebarRightHeader.qml"
            ),

            // Volume slider
            volumeSlider: _slot(
                "../modules/interface/sidebarRight/content/VolumeSlider.qml"
            ),

            // Brightness slider
            brightnessSlider: _slot(
                "../modules/interface/sidebarRight/content/BrightnessSlider.qml"
            ),

            // Network + flight mode row
            networkToggle: _slot(
                "../modules/interface/sidebarRight/content/NetworkToggle.qml"
            ),
            flightModeToggle: _slot(
                "../modules/interface/sidebarRight/content/FlightModeToggle.qml"
            ),

            // Bluetooth + theme + night mode row
            bluetoothToggle: _slot(
                "../modules/interface/sidebarRight/content/BluetoothToggle.qml"
            ),
            themeToggle: _slot(
                "../modules/interface/sidebarRight/content/ThemeToggle.qml"
            ),
            nightModeToggle: _slot(
                "../modules/interface/sidebarRight/content/NightModeToggle.qml"
            ),

            // Notification list
            notifModal: _slot(
                "../modules/interface/sidebarRight/content/NotifModal.qml"
            )
        }
    )


    // Called by plugins or config code — never by modules themselves.
    function overrideModuleSource(moduleId, newSource) {
        const mod = root[moduleId]
        if (!mod) {
            console.warn("ModuleRegistry.overrideModuleSource: unknown module", moduleId)
            return
        }
        mod.source     = Qt.resolvedUrl(newSource)
        mod.overridden = true
    }

    function disableModule(moduleId) {
        const mod = root[moduleId]
        if (mod) {
            mod.active = false
        } else {
            console.warn("ModuleRegistry.disableModule: unknown module", moduleId)
        }
    }

    function enableModule(moduleId) {
        const mod = root[moduleId]
        if (mod) {
            mod.active = true
        } else {
            console.warn("ModuleRegistry.enableModule: unknown module", moduleId)
        }
    }

    function overrideSlot(moduleId, slotId, newSource) {
        const mod = root[moduleId]
        if (!mod) {
            console.warn("ModuleRegistry.overrideSlot: unknown module", moduleId)
            return
        }
        if (!mod.slots[slotId]) {
            console.warn("ModuleRegistry.overrideSlot: unknown slot", moduleId, slotId)
            return
        }
        mod.slots[slotId].override = Qt.resolvedUrl(newSource)
    }

    function disableSlot(moduleId, slotId) {
        const mod = root[moduleId]
        if (!mod || !mod.slots[slotId]) {
            console.warn("ModuleRegistry.disableSlot: unknown slot", moduleId, slotId)
            return
        }
        mod.slots[slotId].active = false
    }

    function enableSlot(moduleId, slotId) {
        const mod = root[moduleId]
        if (!mod || !mod.slots[slotId]) {
            console.warn("ModuleRegistry.enableSlot: unknown slot", moduleId, slotId)
            return
        }
        mod.slots[slotId].active = true
    }

    function resetSlot(moduleId, slotId) {
        const mod = root[moduleId]
        if (!mod || !mod.slots[slotId]) return
        mod.slots[slotId].override = null
        mod.slots[slotId].active   = true
    }
}