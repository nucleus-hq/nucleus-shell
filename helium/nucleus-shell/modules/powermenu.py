import helium
import subprocess
from helium.types import Window, Button, Grid

class Clickable(Button): 
    def __init__(self, label: str, cmd: list, parent_menu: Window):
        super().__init__(
            label=label
        )
        self.cmd = cmd
        self.parent_menu = parent_menu
        self.add_css_class("clickable")
        
        # Connects the signal
        self.connect("clicked", self.on_clicked)

    # Adding '*args' catches the button instance sent by the toolkit signal safely
    def on_clicked(self, *args):
        try:
            subprocess.Popen(self.cmd)
        except Exception as e:
            print(f"Failed to run command {' '.join(self.cmd)}: {e}")
        
        self.parent_menu.hide()

class PowerMenu(Window):
    def __init__(self, monitor: int):
        super().__init__(
            namespace="nucleus:powermenu",
            monitor=monitor,
            anchor=[],
            exclusivity="none",
            layer="overlay",
            kb_mode="none",
            popup=False,
            margin_top=10,
            margin_bottom=10,
            margin_left=10,
            margin_right=10,
            dynamic_input_region=False,
        )

        self.add_css_class("powermenu")
    
        self.layout = Grid()

        # Pass the specific command list and 'self' (the window) to each button
        self.layout.attach(Clickable("power_settings_new", ["poweroff"], self), 0, 0)
        self.layout.attach(Clickable("logout", ["hyprctl", "dispatch", "exit"], self), 1, 0)
        self.layout.attach(Clickable("sleep", ["systemctl", "suspend"], self), 2, 0)
        self.layout.attach(Clickable("lock", ["nucleus", "ipc", "call", "lockscreen", "lock"], self), 0, 1)
        
        # Assuming placeholder commands for your remaining buttons based on previous context
        self.layout.attach(Clickable("restart_alt", ["reboot"], self), 1, 1)
        self.layout.attach(Clickable("light_off", ["echo", "turn off lights/monitor placeholder"], self), 2, 1)

        self.set_child(self.layout)

        self.layout.set_hexpand(True)
        self.layout.set_vexpand(True)
        self.layout.set_halign("center")
        self.layout.set_valign("center")

        self.is_visible = False
        self.hide()

    def show(self):
        super().show()
        self.is_visible = True

    def hide(self):
        super().hide()
        self.is_visible = False