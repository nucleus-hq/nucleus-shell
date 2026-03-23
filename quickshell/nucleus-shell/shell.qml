//@ pragma IconTheme Papirus
import Quickshell
import QtQuick
import qs.config
import qs.plugins
import qs.services
import qs.modules.interface.bar
import qs.modules.interface.background
import qs.modules.interface.powermenu
import qs.modules.interface.launcher
import qs.modules.interface.notifications
import qs.modules.interface.intelligence
import qs.modules.interface.overlays
import qs.modules.interface.sidebarRight
import qs.modules.interface.settings
import qs.modules.interface.sidebarLeft
import qs.modules.interface.lockscreen
import qs.modules.interface.screencapture
import qs.modules.interface.polkit
import qs.modules.interface.dock

ShellRoot {
    id: shellroot

    // Modules
    LazyLoader {
        id: barLoader
        source: Contracts.bar.source
        active: Contracts.bar.active && Config.runtime.bar.enabled
    }
    LazyLoader {
        id: backgroundLoader
        source: Contracts.background.source
        active: Contracts.background.active && Config.runtime.appearance.background.enabled
    }
    LazyLoader {
        id: powerMenuLoader
        source: Contracts.powerMenu.source
        active: Contracts.powerMenu.active && Globals.visibility.powermenu
    }
    LazyLoader {
        id: launcherLoader
        source: Contracts.launcher.source
        active: Contracts.launcher.active
    }
    LazyLoader {
        id: notificationsLoader
        source: Contracts.notifications.source
        active: Contracts.notifications.active && Config.runtime.notifications.enabled
    }
    LazyLoader {
        id: overlaysLoader
        source: Contracts.overlays.source
        active: Contracts.overlays.active && Config.runtime.overlays.enabled
    }
    LazyLoader {
        id: sidebarRightLoader
        source: Contracts.sidebarRight.source
        active: Contracts.sidebarRight.active
    }
    LazyLoader {
        id: sidebarLeftLoader
        source: Contracts.sidebarLeft.source
        active: Contracts.sidebarLeft.active
    }
    LazyLoader {
        id: lockScreenLoader
        source: Contracts.lockScreen.source
        active: Contracts.lockScreen.active
    }
    LazyLoader {
        id: dockLoader
        source: Contracts.dock.source
        active: Contracts.dock.active && (Config.dock?.enabled ?? true)
    }

    // Services
    Settings      { }
    Ipc           { }
    Intelligence  { }
    UpdateNotifier{ }
    PluginHost    { }
    ScreenCapture { }
    PolkitAgent   { }
}