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

    ModuleHost { }

    // Services — unchanged
    Settings       { }
    Ipc            { }
    Intelligence   { }
    UpdateNotifier { }
    PluginHost     { }
    ScreenCapture  { }
    PolkitAgent    { }
}