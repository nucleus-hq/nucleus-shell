import helium
from helium.types import Box, Label, Button, MaterialSymbol, Grid

class QuickToggle(Box):
    def __init__(self, name: str, subtext: str, icon: str, toggle_type: str = "large", on_toggle_cb=None):
        super().__init__(orientation="horizontal", spacing=0)
        
        # Save configuration states
        self.toggle_type = toggle_type
        self.on_toggle_cb = on_toggle_cb
        self._is_active = False

        # Add distinct base CSS class names based on type
        self.add_css_class("quick-toggle-box")
        if self.toggle_type == "small":
            self.add_css_class("small-toggle")
        else:
            self.add_css_class("large-toggle")
        
        self.layer_grid = Grid(column_num=1, row_num=1)
        self.layer_grid.set_hexpand(True)

        self.content_box = Box(orientation="horizontal", spacing=14)
        self.content_box.add_css_class("quick-toggle-content")

        # Icon Frame
        self.icon_box = Box(orientation="horizontal", spacing=0)
        self.icon_box.add_css_class("quick-toggle-icon-frame")
        
        self.icon_glyph = Label(label=icon)
        self.icon_glyph.add_css_class("quick-toggle-icon")
        self.icon_box.add(self.icon_glyph)
        self.content_box.add(self.icon_box)

        if self.toggle_type == "large":
            self.text_box = Box(orientation="vertical", spacing=2)
            self.text_box.add_css_class("quick-toggle-text-frame")

            self.title_label = Label(label=name)
            self.title_label.add_css_class("quick-toggle-title")
            
            self.subtext_label = Label(label=subtext)
            self.subtext_label.add_css_class("quick-toggle-subtext")

            self.text_box.add(self.title_label)
            self.text_box.add(self.subtext_label)
            self.content_box.add(self.text_box)

        self.click_trigger = Button(label="")
        self.click_trigger.add_css_class("quick-toggle-trigger")
        self.click_trigger.set_hexpand(True)
        self.click_trigger.set_vexpand(True)
        self.click_trigger.connect("clicked", self._handle_click)

        # Multi-layer stack bindings
        self.layer_grid.attach(self.content_box, 0, 0)
        self.layer_grid.attach(self.click_trigger, 0, 0)

        self.add(self.layer_grid)
        self.set_hexpand(False)

    def _handle_click(self, *args):
        self._is_active = not self._is_active
            
        if self._is_active:
            self.add_css_class("active")
        else:
            self.remove_css_class("active")

        if self.on_toggle_cb:
            self.on_toggle_cb(self._is_active)

    def update_title(self, text: str):
        if self.toggle_type == "large":
            self.title_label.set_label(text)

    def update_subtext(self, text: str):
        if self.toggle_type == "large":
            self.subtext_label.set_label(text)

    def update_icon(self, icon_name: str):
        self.icon_glyph.set_label(icon_name)

    def set_active(self, active: bool, trigger_cb: bool = False):
        if self._is_active == active:
            return

        self._is_active = active
        if self._is_active:
            self.add_css_class("active")
        else:
            self.remove_css_class("active")

        if trigger_cb and self.on_toggle_cb:
            self.on_toggle_cb(self._is_active)