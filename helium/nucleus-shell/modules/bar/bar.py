import copy
import helium
import re
import json
import subprocess
import os
import threading
import urllib.request
from urllib.parse import urlparse
import datetime
import services.toplevel
from functools import partial
from helium.types import (
    Panel, Box, Label, Button, CenterBox, MaterialSymbol, Icon, Image
)
from helium.compositor.hyprland import (
    hyprland_dispatch,
    get_workspaces,
    get_active_workspace,
)
from helium.managers import WindowManager

wm = WindowManager.get_default() 

# Setup network service
net = None
try:
    net = helium.services.NetworkService.get_default()
except Exception:
    pass

# Setup mpris service
mpris = None
try:
    mpris = helium.services.MprisService.get_default()
    mpris.start_polling()
except Exception:
    pass

def build_module(name, ctx):
    if name == "active_window":
        return ActiveWindowIndicator()
    elif name == "media":
        return Media()
    elif name == "workspaces":
        return WorkspaceContainer()
    elif name == "status":
        return StatusPills(sbrRef=ctx.get("sbrRef"))
    elif name == "clock":
        return Clock()
    elif name == "power":
        return PowerButton(pmRef=ctx.get("pmRef"))
    return None

def build_section(module_names, ctx, orientation="horizontal"):
    box = Box(orientation=orientation, spacing=2)
    widgets = []
    for name in module_names:
        w = build_module(name, ctx)
        if w:
            widgets.append(w)
    for i, w in enumerate(widgets):
        n = len(widgets)
        if n == 1:
            w.add_css_class("module-single")
        elif i == 0:
            w.add_css_class("module-first")
        elif i == n - 1:
            w.add_css_class("module-last")
        else:
            w.add_css_class("module-middle")
        box.add(w)
    return box

# Bar widgets
class WorkspaceContainer(Box):
    def __init__(self):
        super().__init__(
            orientation="horizontal",
            spacing=5
        )
        self.add_css_class("wscontainer")
        
        self.buttons = {}
        for wid in range(1, 9):
            btn = Button(label=str(wid))
            btn.add_css_class("workspace")
            btn.on_click(partial(self.switch_workspace, wid))
            self.add(btn)
            self.buttons[wid] = btn

        self.last_active_id = None
        self.last_occupied_ids = set()

        helium.functions.Poll(50, self.update_workspaces)
        self.update_workspaces()

    def update_workspaces(self):
        try:
            raw_ws = get_workspaces()
            occupied_ids = {ws["id"] for ws in json.loads(raw_ws)}
            
            active_raw = json.loads(get_active_workspace())
            active_id = active_raw["id"]

            if active_id == self.last_active_id and occupied_ids == self.last_occupied_ids:
                return True

            for wid, btn in self.buttons.items():
                btn.remove_css_class("active")
                btn.remove_css_class("occupied")
                btn.remove_css_class("empty")
                
                if wid == active_id:
                    btn.add_css_class("active")
                elif wid in occupied_ids:
                    btn.add_css_class("occupied")
                else:
                    btn.add_css_class("empty")

            self.last_active_id = active_id
            self.last_occupied_ids = occupied_ids

        except Exception:
            pass
        return True

    def switch_workspace(self, workspace_id):
        hyprland_dispatch(f"dispatch workspace {workspace_id}")


class Clock(Box):
    def __init__(self):
        super().__init__(
            orientation="horizontal",
            spacing=0 
        )
        self.add_css_class("clock-pill")
        
        self.icon_label = MaterialSymbol(symbol="date_range", size=18) 
        self.icon_label.add_css_class("clock-icon")
        
        self.separator = Label(label="|")
        self.separator.add_css_class("clock-sep")
        
        self.time_label = Label()
        self.time_label.add_css_class("clock-time")
        
        self.add(self.icon_label)
        self.add(self.separator)
        self.add(self.time_label)

        helium.functions.Poll(1000, self.tick)
        self.tick()

    def tick(self):
        now = datetime.datetime.now()
        self.time_label.set_label(now.strftime("%H:%M"))
        return True


class ActiveWindowIndicator(Box):
    def __init__(self):
        super().__init__(
            orientation="horizontal",
            spacing=6
        )

        self.appIcon = Icon(pixel_size=24)
        self.appIcon.add_css_class("appIcon")

        labelBox = Box(
            orientation="vertical",
            spacing=0
        )

        self.windowLabel = Label(label="")
        self.classLabel = Label(label="")

        self.classLabel.add_css_class("classLabel")
        self.windowLabel.add_css_class("windowLabel")

        labelBox.add(self.windowLabel)
        labelBox.add(self.classLabel)

        self.add_css_class("activeIndicator")

        self.add(self.appIcon)
        self.add(labelBox)

        self.last_top = None
        self.last_bottom = None

        helium.functions.Poll(100, self.update_indicator)
        self.update_indicator()

    def get_clean_app_name(self, title: str, raw_class: str) -> str:
        if not title:
            return ""

        title = re.sub(r'[●⬤○◉◌◎]', '', title)
        title = re.sub(r'\s*[|—]\s*', ' - ', title)
        title = re.sub(r'\s+', ' ', title).strip()

        parts = [p.strip() for p in title.split(" - ") if p.strip()]

        apps = [
            "Firefox", "Mozilla Firefox",
            "Chromium", "Google Chrome",
            "Neovim", "VS Code", "Code",
            "Kitty", "Alacritty", "Terminal",
            "Discord", "Spotify", "Steam",
            "Aelyx Settings", "Settings"
        ]

        app_name = ""
        for part in reversed(parts):
            for a in apps:
                if a in part:
                    if "Firefox" in a: app_name = "Firefox"
                    elif "Chrome" in a: app_name = "Google Chrome"
                    elif "Code" in a: app_name = "Code OSS"
                    else: app_name = a
                    break
            if app_name:
                break

        if not app_name:
            app_name = parts[-1] if parts else raw_class.replace("-", " ").title()

        MAX_CHARS = 24
        if len(app_name) > MAX_CHARS:
            app_name = app_name[:MAX_CHARS - 3] + "..."

        return app_name

    def format_app_id(self, app_id: str) -> str:
        if not app_id:
            return ""
        parts = re.split(r'[-_]', app_id.lower())
        return ".".join([p for p in parts if p])

    def update_indicator(self):
        window_data = services.toplevel.get_current_window_details()
        
        if window_data and (window_data.get("title") or window_data.get("class")):
            raw_title = window_data.get("title", "")
            raw_class = window_data.get("class", "")
            initial_class = window_data.get("initial_class") or raw_class

            top_text = self.get_clean_app_name(raw_title, raw_class)
            bottom_text = self.format_app_id(initial_class)
            
            icon_name = raw_class.lower()
            
            if "code-oss" in icon_name or "vscode" in icon_name:
                icon_name = "code-oss"
            elif "foot" in icon_name or "kitty" in icon_name or "alacritty" in icon_name:
                icon_name = "utilities-terminal"
        else:
            top_text = "Desktop"
            icon_name = "computer"
            try:
                active_ws = json.loads(get_active_workspace())
                bottom_text = f"workspace {active_ws.get('id', 1)}"
            except Exception:
                bottom_text = "workspace 1"

        if top_text == self.last_top and bottom_text == self.last_bottom:
            return True

        self.windowLabel.set_label(top_text)
        self.classLabel.set_label(bottom_text)
        
        try:
            self.appIcon.set_icon_name(icon_name)
        except Exception:
            self.appIcon.set_icon_name("application-x-executable")

        self.last_top = top_text
        self.last_bottom = bottom_text
        return True

class PowerButton(Box):
    def __init__(self, pmRef=None):
        super().__init__(
            orientation="horizontal",
            spacing=0
        )

        self.pm = pmRef
        powerbutton = Button(label="power_settings_new")
        powerbutton.add_css_class("powerbutton")
        powerbutton.on_click(self.on_pill_clicked)

        self.add(powerbutton)
        self.add_css_class("powerbutton-pill")

    def on_pill_clicked(self):
        if self.pm:
            if self.pm.is_visible:
                self.pm.hide()
            else:
                self.pm.show()


class StatusPills(Box):
    def __init__(self, sbrRef=None):
        super().__init__(
            orientation="horizontal",
            spacing=0
        )
        self.add_css_class("status-pill-container")

        self.sidebar = sbrRef # store the ref locally

        # Set default state tracks
        self.wifi_symbol = "signal_wifi_off"
        self.bluetooth_symbol = "bluetooth"

        if net:
            is_connected = getattr(net, "connected", False)
            strength = getattr(net, "signal_strength", 0)
            self.wifi_symbol = self.get_material_wifi_symbol(is_connected, strength)

        # Assemble initial dual-glyph string label
        initial_label = f"{self.wifi_symbol} {self.bluetooth_symbol}"

        # Create one unified button containing both icons as text ligatures
        self.pillButton = Button(label=initial_label)
        self.pillButton.add_css_class("status-pill-button")
        self.pillButton.on_click(self.on_pill_clicked)

        self.add(self.pillButton)

        if net:
            helium.functions.Poll(3000, self.update_status)

    def get_material_wifi_symbol(self, connected: bool, strength: int) -> str:
        if not connected:
            return "signal_wifi_off"
            
        if strength >= 80:
            return "signal_wifi_4_bar"
        elif strength >= 60:
            return "network_wifi_3_bar"
        elif strength >= 40:
            return "network_wifi_2_bar"
        elif strength >= 20:
            return "network_wifi_1_bar"
        else:
            return "signal_wifi_0_bar"

    def update_status(self):
        if net:
            try:
                is_connected = getattr(net, "connected", False)
                strength = getattr(net, "signal_strength", 0)
                
                next_wifi = self.get_material_wifi_symbol(is_connected, strength)
                
                if next_wifi != self.wifi_symbol:
                    self.wifi_symbol = next_wifi
                    # Refresh the dual-icon string label
                    self.pillButton.set_label(f"{self.wifi_symbol} {self.bluetooth_symbol}")
            except Exception:
                pass
        return True

    def on_pill_clicked(self):
        if self.sidebar:
            if self.sidebar.is_visible:
                self.sidebar.hide()
            else:
                self.sidebar.show()


class Media(Box):
    def __init__(self):
        super().__init__(
            orientation="horizontal",
            spacing=0
        )
        self.add_css_class("media-pill")
        
        # Constrain the root container's height
        self.set_size_request(-1, 42) 

        # Logo Icon container
        self.image_container = Box(orientation="horizontal", spacing=0)
        self.image_container.add_css_class("media-art-container")
        self.image_container.set_size_request(32, 32)
        self.add(self.image_container)
        
        # Persistent Material Symbol logo
        self.logo_icon = MaterialSymbol(symbol="music_note", size=20)
        self.image_container.add(self.logo_icon)

        # Vertical text layout stack
        self.labelBox = Box(orientation="vertical", spacing=0) 
        self.labelBox.add_css_class("media-text-container")
        
        # Explicit vertical alignment centering inside the container matrix
        self.labelBox.set_valign("center") 
        self.add(self.labelBox)

        # Song Title (Top, Bold)
        self.titleLabel = Label(label="No Media")
        self.titleLabel.add_css_class("media-title")

        # Artist Name (Bottom)
        self.artistLabel = Label(label="No Artist")
        self.artistLabel.add_css_class("media-artist")

        self.labelBox.add(self.titleLabel)
        self.labelBox.add(self.artistLabel)

        self.last_title = None

        # Track player state updates
        helium.functions.Poll(1000, self.update_media)
        self.update_media()

    def get_playerctl_metadata(self, key: str) -> str:
        try:
            return subprocess.check_output(
                ["playerctl", "metadata", key], 
                stderr=subprocess.DEVNULL
            ).decode("utf-8").strip()
        except subprocess.CalledProcessError:
            return ""

    def update_media(self):
        title = self.get_playerctl_metadata("title")
        artist = self.get_playerctl_metadata("artist")

        if not title:
            self.artistLabel.set_label("No Artist")
            self.titleLabel.set_label("No Media")
            self.last_title = None
            return True

        # Prevent unnecessary DOM restyling if the track hasn't changed
        if title == self.last_title:
            return True

        self.last_title = title

        # Strict string length shortening limits
        if len(title) > 20: title = title[:17] + "..."
        if len(artist) > 15: artist = artist[:12] + "..."

        self.artistLabel.set_label(artist)
        self.titleLabel.set_label(title)

        return True

_current_bar = None

def reload_bar_config():
    b = _current_bar
    if b:
        b.check_config_reload()
    return True


class Bar(Panel):
    def __init__(self, monitor: int, sbrRef=None, pmRef=None):
        global _current_bar

        self._sbrRef = sbrRef
        self._pmRef = pmRef
        self._monitor = monitor
        self._pos = helium.config.get("bar.position") or "top"

        if _current_bar is not None:
            _current_bar.hide()

        position = self._pos
        is_vertical = position in ("left", "right")
        thickness = helium.config.get("bar.height")

        if position == "bottom":
            anchor = ["bottom", "left", "right"]
        elif position == "left":
            anchor = ["left", "top", "bottom"]
        elif position == "right":
            anchor = ["right", "top", "bottom"]
        else:
            anchor = ["top", "left", "right"]

        super().__init__(
            namespace="nucleus:bar",
            anchor=anchor,
            exclusive=True,
            width=thickness if is_vertical else -1,
            height=-1 if is_vertical else thickness,
        )

        self.add_css_class("bar")
        self._old_config = copy.deepcopy(helium.config.data) if helium.config.data else {}
        self.build_layout()

        if is_vertical:
            angle = 270 if position == "left" else 90
            self.set_style(f"transform: rotate({angle}deg);")

        self.show()

        _current_bar = self

    def check_config_reload(self):
        old = self._old_config
        try:
            helium.config.reload()
        except Exception:
            return True
        new = copy.deepcopy(helium.config.data) if helium.config.data else {}

        old_bar = old.get("bar", {}) if isinstance(old, dict) else {}
        new_bar = new.get("bar", {}) if isinstance(new, dict) else {}

        if not new_bar:
            self._old_config = new
            return True

        if old_bar.get("modules") != new_bar.get("modules"):
            self.build_layout()

        if old_bar.get("height") != new_bar.get("height"):
            t = new_bar.get("height", 45)
            if self._pos in ("left", "right"):
                self.set_width(t)
            else:
                self.set_height(t)

        if old_bar.get("position") != new_bar.get("position"):
            self._old_config = new
            Bar(self._monitor, sbrRef=self._sbrRef, pmRef=self._pmRef)
            return False

        self._old_config = new
        return True

    def build_layout(self):
        layout = CenterBox()
        ctx = {"sbrRef": self._sbrRef, "pmRef": self._pmRef}

        for section in ["start", "center", "end"]:
            names = helium.config.get(f"bar.modules.{section}") or []
            if names:
                section_box = build_section(names, ctx)
                getattr(layout, f"set_{section}")(section_box)

        self.set_child(layout)