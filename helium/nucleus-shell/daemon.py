import config
import helium
from modules.bar.bar import Bar
from modules.sidebarRight.sidebarRight import SidebarRight
from modules.powermenu.powermenu import PowerMenu
from helium.managers import CssManager

helium.init()
CssManager.load("css/bar.css")
CssManager.load("css/colors.css")
CssManager.load("css/sidebarRight.css")
CssManager.load("css/powermenu.css")

sidebar = SidebarRight(0)
powermenu = PowerMenu(0)
Bar(0, sbrRef=sidebar, pmRef=powermenu)

helium.run()
