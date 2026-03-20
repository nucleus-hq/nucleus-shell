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
import qs.modules.interface.intelligence // Intelligence
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

    // Load modules

    LazyLoader {
        id: barLoader
        source: Contracts.bar
        active: Config.runtime.bar.enabled && !Contracts.overriddenBar
    }

    LazyLoader {
        id: backgroundLoader
        source: Contracts.background
        active: Config.runtime.appearance.background.enabled && !Contracts.overriddenBackground
    }

    LazyLoader {
        id: powerMenuLoader
        source: Contracts.powerMenu
        active: Globals.visiblility.powermenu && !Contracts.overriddenPowerMenu
    }

    LazyLoader {
        id: launcherLoader
        source: Contracts.launcher
        active: true && !Contracts.overriddenLauncher
    }

    LazyLoader {
        id: notificationsLoader
        source: Contracts.notifications
        active: Config.runtime.notifications.enabled && !Contracts.overriddenNotifications
    }

    LazyLoader {
        id: overlaysLoader
        source: Contracts.overlays
        active: Config.runtime.overlays.enabled && !Contracts.overriddenOverlays
    }

    LazyLoader {
        id: sidebarRightLoader
        source: Contracts.sidebarRight
        active: !Contracts.overriddenSidebarRight
    }

    LazyLoader {
        id: sidebarLeftLoader
        source: Contracts.sidebarLeft
        active: !Contracts.overriddenSidebarLeft
    }

    LazyLoader {
        id: lockScreenLoader
        source: Contracts.lockScreen
        active: true && !Contracts.overriddenLockScreen
    }

    LazyLoader {
        id: dockLoader
        source: Contracts.dock
        active: (Config.dock?.enabled ?? true) && !Contracts.overriddenDock
    }

    Settings { }
    Ipc { }
    Intelligence { }
    UpdateNotifier { }
    PluginHost { }
    ScreenCapture{ }
    PolkitAgent { }
}
