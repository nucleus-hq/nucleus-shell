import helium
import subprocess
import re
from helium.types import (
    Window, Box, Label, Button, CenterBox, Separator, Scale, MaterialSymbol
)
from services import system, theme, nightlight, recorder
from modules.sidebarRight.quicktoggle import QuickToggle

net_service = None
try:
    net_service = helium.services.NetworkService.get_default()
except Exception:
    pass

bt_service = None
try:
    bt_service = helium.services.BluetoothService.get_default()
except Exception:
    pass

power_service = None
try:
    power_service = helium.services.PowerProfilesService.get_default()
except Exception:
    pass

class UppermostSection(Box):
    def __init__(self):
        super().__init__(
            orientation="horizontal",
            spacing=0
        )

        self.layout = CenterBox()
        self.layout.set_hexpand(True) 

        self.osLogo = Label(label=system.os_icon)
        self.uptime = Label(label=f"Up {system.fetch_uptime()}")
        self.settingsButton = Button(label="settings")

        self.osLogo.add_css_class("osLogo")
        self.uptime.add_css_class("uptime")
        self.settingsButton.add_css_class("settingsButton")
        self.add_css_class("uppermost-box")

        self.left_group = Box(orientation="horizontal", spacing=12)
        self.left_group.add(self.osLogo)
        self.left_group.add(self.uptime)

        self.layout.set_start(self.left_group)
        self.layout.set_end(self.settingsButton)

        self.add(self.layout)


class QuickToggleSection(Box):
    def __init__(self):
        super().__init__(orientation="vertical", spacing=8)
        self.add_css_class("quicktoggle-grid")

        self.wifi_toggle = QuickToggle(
            name="Network",
            subtext="Connected",
            icon="wifi",
            on_toggle_cb=lambda x: self.toggle_network(x)
        )

        self.bt_toggle = QuickToggle(
            name="Bluetooth",
            subtext="Connected",
            icon="bluetooth",
            on_toggle_cb=lambda x: self.toggle_bluetooth(x)
        )

        self.theme_toggle = QuickToggle(
            name="",
            subtext="",
            icon="dark_mode",
            toggle_type="small",
            on_toggle_cb=lambda active: self.handle_theme_toggle(active)
        )

        self.nightlight_toggle = QuickToggle(
            name="",
            subtext="",
            icon="light_off",
            toggle_type="small",
            on_toggle_cb=lambda active: self.handle_nightlight(active)
        )

        self.dnd_toggle = QuickToggle(
            name="",
            subtext="",
            icon="notifications_off",
            toggle_type="small",
            on_toggle_cb=lambda x: print("Clicked")
        )

        self.battery_saver_toggle = QuickToggle(
            name="Battery Saver ",
            subtext="Turned Off (90% Batt)",
            icon="battery_saver",
            on_toggle_cb=lambda x: self.toggle_battery_saver(x)
        )

        self.recorder_toggle = QuickToggle(
            name="Record",
            subtext="Ready",
            icon="screen_record",
            on_toggle_cb=lambda active: self.handle_recording_toggle(active)
        )

        self.privacy_toggle = QuickToggle(
            name="Privacy",
            subtext="Active",
            icon="mic",
            on_toggle_cb=lambda active: self.handle_privacy_toggle(active)
        )

        self.recorder_toggle.add_css_class("recorder-toggle")
        self.recorder_toggle.set_hexpand(False)
        self.recorder_toggle.set_halign("start")

        self.privacy_toggle.add_css_class("privacy-toggle")
        self.privacy_toggle.set_hexpand(False)
        self.privacy_toggle.set_halign("start")

        self.row_top = Box(orientation="horizontal", spacing=4)
        self.row_top.add(self.wifi_toggle)
        self.row_top.add(self.bt_toggle)

        self.row_bottom = Box(orientation="horizontal", spacing=4)
        self.row_bottom.add(self.theme_toggle)
        self.row_bottom.add(self.battery_saver_toggle)
        self.row_bottom.add(self.dnd_toggle)

        self.row_last = Box(orientation="horizontal", spacing=4)
        self.row_last.add(self.recorder_toggle)
        self.row_last.add(self.nightlight_toggle)
        self.row_last.add(self.privacy_toggle)

        self.add(self.row_top)
        self.add(self.row_bottom)
        self.add(self.row_last)

        self.sync_wifi_ui_state()
        self.sync_bluetooth_ui_state()
        self.sync_battery_ui_state()
        self.sync_nightlight_ui_state()
        self.sync_theme_ui_state()
        self.sync_recorder_ui_state()
        self.sync_privacy_ui_state()

    def toggle_network(self, active: bool):
        try:
            target_state = "on" if active else "off"
            subprocess.run(["nmcli", "radio", "wifi", target_state], check=True)
        except Exception:
            pass
        self.sync_wifi_ui_state()

    def sync_wifi_ui_state(self):
        if not net_service:
            return
        
        is_connected = net_service.is_connected()
        wifi_ssid = net_service.get_ssid() if hasattr(net_service, 'get_ssid') else None
        
        if is_connected and wifi_ssid:
            self.wifi_toggle.update_title(str(wifi_ssid))
            self.wifi_toggle.update_subtext("Connected")
            self.wifi_toggle.update_icon("wifi")
            self.wifi_toggle.set_active(True, trigger_cb=False)
        else:
            self.wifi_toggle.update_title("Network")
            self.wifi_toggle.update_subtext("Disconnected")
            self.wifi_toggle.update_icon("wifi_off")
            self.wifi_toggle.set_active(False, trigger_cb=False)

    def toggle_bluetooth(self, active: bool):
        if not bt_service:
            return
        try:
            bt_service.set_bluetooth_on(active)
        except Exception:
            pass
        self.sync_bluetooth_ui_state()

    def sync_bluetooth_ui_state(self):
        if not bt_service:
            return
        
        is_on = bt_service.is_bluetooth_on()
        
        if is_on:
            devices = bt_service.get_devices() or []
            connected_devices = [d.name for d in devices if getattr(d, 'connected', False)]
            
            if connected_devices:
                self.bt_toggle.update_subtext(connected_devices[0])
            else:
                self.bt_toggle.update_subtext("Adapter On")
                
            self.bt_toggle.update_icon("bluetooth")
            self.bt_toggle.set_active(True, trigger_cb=False)
        else:
            self.bt_toggle.update_subtext("Adapter Off")
            self.bt_toggle.update_icon("bluetooth_disabled")
            self.bt_toggle.set_active(False, trigger_cb=False)

    def _get_system_battery_percentage(self) -> str:
        try:
            path_cmd = subprocess.run(["upower", "-e"], capture_output=True, text=True, check=True)
            battery_paths = [line for line in path_cmd.stdout.splitlines() if "battery_" in line]
            
            if not battery_paths:
                return "100%"
                
            info_cmd = subprocess.run(["upower", "-i", battery_paths[0]], capture_output=True, text=True, check=True)
            match = re.search(r"percentage:\s+(\d+%)", info_cmd.stdout)
            return match.group(1) if match else "100%"
        except Exception:
            return "100%"

    def toggle_battery_saver(self, active: bool):
        if not power_service:
            return
        try:
            profile = "power-saver" if active else "balanced"
            power_service.set_profile(profile)
        except Exception:
            pass
        self.sync_battery_ui_state()

    def sync_battery_ui_state(self):
        batt_pct = self._get_system_battery_percentage()
        
        if power_service:
            is_saver = power_service.get_profile() == "power-saver"
        else:
            is_saver = False
            
        if is_saver:
            self.battery_saver_toggle.update_subtext(f"Turned On ({batt_pct} Batt)")
            self.battery_saver_toggle.set_active(True, trigger_cb=False)
        else:
            self.battery_saver_toggle.update_subtext(f"Turned Off ({batt_pct} Batt)")
            self.battery_saver_toggle.set_active(False, trigger_cb=False)

    def handle_nightlight(self, active: bool):
        variant_type = "cold"
        try:
            variant_type = helium.config.get("misc.nightlight.variant")
        except Exception:
            pass

        is_now_on = nightlight.toggle_night_light(variant_type)
        self.sync_nightlight_ui_state(is_now_on)

    def sync_nightlight_ui_state(self, force_state: bool = None):
        if force_state is None:
            is_running = nightlight.is_hyprsunset_running()
        else:
            is_running = force_state

        if is_running:
            self.nightlight_toggle.update_icon("lightbulb")
            self.nightlight_toggle.set_active(True, trigger_cb=False)
        else:
            self.nightlight_toggle.update_icon("light_off")
            self.nightlight_toggle.set_active(False, trigger_cb=False)

    def handle_theme_toggle(self, active: bool):
        current_theme_string = "light" if active else "dark"

        new_mode = theme.toggle_theme_mode(current_theme_string)
        
        self.sync_theme_ui_state(new_mode)
        
        try:
            helium.style.reload() 
        except Exception:
            pass

    def sync_theme_ui_state(self, current_mode: str = None):
        if current_mode is None:
            try:
                current_mode = helium.config.get("appearance.theme")
            except Exception:
                try:
                    current_mode = helium.config.get("appearance.theme")
                except Exception:
                    current_mode = "dark"

        if current_mode == "dark":
            self.theme_toggle.update_icon("dark_mode")
            self.theme_toggle.set_active(True, trigger_cb=False)
        else:
            self.theme_toggle.update_icon("light_mode")
            self.theme_toggle.set_active(False, trigger_cb=False)

    def handle_recording_toggle(self, active: bool):
        is_running, status_message = recorder.toggle_recording()
        
        self.recorder_toggle.update_subtext(status_message)
        self.recorder_toggle.set_active(is_running, trigger_cb=False)
        
        if is_running:
            self.recorder_toggle.update_icon("stop_circle")
        else:
            self.recorder_toggle.update_icon("screen_record")

    def sync_recorder_ui_state(self):
        is_running = recorder.is_recording()
        self.recorder_toggle.set_active(is_running, trigger_cb=False)
        
        if is_running:
            self.recorder_toggle.update_subtext("Recording...")
            self.recorder_toggle.update_icon("stop_circle")
        else:
            self.recorder_toggle.update_subtext("Ready")
            self.recorder_toggle.update_icon("screen_record")

    def handle_privacy_toggle(self, active: bool):
        try:
            # active=True means user clicked to turn ON privacy protection (Mute Mic)
            target_mute = "1" if active else "0"
            subprocess.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", target_mute], check=True)
        except Exception:
            pass
        
        # Pass the clicked state directly to the sync function to bypass the race condition
        self.sync_privacy_ui_state(force_state=active)

    def sync_privacy_ui_state(self, force_state: bool = None):
        try:
            if force_state is not None:
                is_muted = force_state
            else:
                output = subprocess.check_output(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"], text=True)
                is_muted = "[MUTED]" in output
            
            if is_muted:
                self.privacy_toggle.update_subtext("Turned On")
                self.privacy_toggle.update_icon("mic_off")
                # Visual button highlights indicating privacy shield is ON
                self.privacy_toggle.set_active(True, trigger_cb=False)
                self.privacy_toggle.add_css_class("privacy-muted")
            else:
                self.privacy_toggle.update_subtext("Turned Off")
                self.privacy_toggle.update_icon("mic")
                # Visual button returns to low-profile dark background when mic is live
                self.privacy_toggle.set_active(False, trigger_cb=False)
                self.privacy_toggle.remove_css_class("privacy-muted")
        except Exception:
            self.privacy_toggle.update_subtext("Unavailable")
            self.privacy_toggle.update_icon("mic_external_off")
            self.privacy_toggle.set_active(False, trigger_cb=False)

class MediaContainer(Box):
    def __init__(self):
        super().__init__(
            orientation="vertical",
            spacing=0
        )

        self.add_css_class("mediacontainer")

class MainContainer(Box):
    def __init__(self):
        super().__init__(
            orientation="vertical",
            spacing=0
        )

        self.add(UppermostSection())
        self.add(self.separator("margin: 0px 16px 0px 16px;"))
        
        self.quick_toggles = QuickToggleSection()
        self.add(self.quick_toggles)
        
        self.add(self.separator("margin: 24px 16px 0px 16px;"))

        self.add(MediaContainer())

    def separator(self, margins: str = "margin: 0px;"):
        uppersep = Separator(orientation="horizontal")
        uppersep.set_style(margins)
        return uppersep


class SidebarRight(Window):
    def __init__(self, monitor: int):
        super().__init__(
            namespace="nucleus:sidebarRight",
            monitor=monitor,
            anchor=["bottom", "top", "right"],
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

        self.add_css_class("sidebarRight")

        self.set_child(MainContainer())
        
        self.is_visible = False
        self.hide()

    def show(self):
        super().show()
        self.is_visible = True
        if hasattr(self, 'quick_toggles'):
            self.quick_toggles.sync_wifi_ui_state()
            self.quick_toggles.sync_bluetooth_ui_state()
            self.quick_toggles.sync_battery_ui_state()
            self.quick_toggles.sync_nightlight_ui_state()
            self.quick_toggles.sync_theme_ui_state()
            self.quick_toggles.sync_recorder_ui_state()
            self.quick_toggles.sync_privacy_ui_state()

    def hide(self):
        super().hide()
        self.is_visible = False