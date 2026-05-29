import config
import helium
from modules.bar.bar import Bar, reload_bar_config
from modules.sidebarRight.sidebarRight import SidebarRight
from modules.powermenu.powermenu import PowerMenu
from helium.managers import CssManager
import services.modules as modules  # unified registry

helium.init()
CssManager.load("css/colors.css")
CssManager.load("css/bar.css")
CssManager.load("css/sidebarRight.css")
CssManager.load("css/powermenu.css")

sidebar = SidebarRight(0)
powermenu = PowerMenu(0)

# Register references globally into our module service mapping
modules.init_modules({
    "sidebarRight": sidebar,
    "powermenu": powermenu
})

# Bar automatically gets visibility tracking access globally so we don't register it to the ModuleRegistry
Bar(0) 

helium.functions.Poll(50, reload_bar_config)
helium.run()