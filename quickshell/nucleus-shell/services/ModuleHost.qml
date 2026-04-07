pragma ComponentBehavior: Bound
import QtQuick
import qs.config
import qs.services
import qs.modules.hosts

// ModuleHost owns every module loader.
Item {
    id: root

    ModuleLoader {
        moduleId: "bar"
        source:   ModuleRegistry.bar.source
        enabled:  ModuleRegistry.bar.active
                  && Config.initialized
                  && Config.runtime.bar.enabled
    }

    ModuleLoader {
        moduleId: "background"
        source:   ModuleRegistry.background.source
        enabled:  ModuleRegistry.background.active
                  && Config.initialized
                  && Config.runtime.appearance.background.enabled
    }

    ModuleLoader {
        moduleId: "powerMenu"
        source:   ModuleRegistry.powerMenu.source
        enabled:  ModuleRegistry.powerMenu.active
                  && Globals.visiblility.powermenu
    }

    ModuleLoader {
        moduleId: "launcher"
        source:   ModuleRegistry.launcher.source
        enabled:  ModuleRegistry.launcher.active
                  && Globals.visiblility.launcher
    }

    ModuleLoader {
        moduleId: "notifications"
        source:   ModuleRegistry.notifications.source
        enabled:  ModuleRegistry.notifications.active
                  && Config.initialized
                  && Config.runtime.notifications.enabled
    }

    ModuleLoader {
        moduleId: "overlays"
        source:   ModuleRegistry.overlays.source
        enabled:  ModuleRegistry.overlays.active
                  && Config.initialized
                  && Config.runtime.overlays.enabled
    }

    ModuleLoader {
        moduleId: "sidebarRight"
        source:   ModuleRegistry.sidebarRight.source
        enabled:  ModuleRegistry.sidebarRight.active
    }

    ModuleLoader {
        moduleId: "sidebarLeft"
        source:   ModuleRegistry.sidebarLeft.source
        enabled:  ModuleRegistry.sidebarLeft.active
    }

    ModuleLoader {
        moduleId: "lockScreen"
        source:   ModuleRegistry.lockScreen.source
        enabled:  ModuleRegistry.lockScreen.active
    }

    ModuleLoader {
        moduleId: "dock"
        source:   ModuleRegistry.dock.source
        enabled:  ModuleRegistry.dock.active
                  && Config.initialized
                  && (Config.runtime.dock ? Config.runtime.dock.enabled : true)
    }
}