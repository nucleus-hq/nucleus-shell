import os, json
import helium

class BarConfig:
    def __init__(self):
        self.height = 45
        self.position = "top"

class BackgroundConfig:
    def __init__(self):
        self.path = ""

class AppearanceConfig:
    def __init__(self):
        self.background = BackgroundConfig()

class Configuration:
    def __init__(self):
        self.bar = BarConfig()
        self.appearance = AppearanceConfig()
        self.theme = "dark"

config = helium.config
config.merge_defaults(helium.functions.config_from_class(Configuration()))

config.set_path(os.path.expanduser("~/.config/helium/config.json"))
config.save()