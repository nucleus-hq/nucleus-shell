import config
import helium
from modules.bar import Bar
from helium.managers import CssManager

helium.init()
CssManager.load("css/bar.css")
CssManager.load("css/colors.css")

Bar(0)

helium.run()