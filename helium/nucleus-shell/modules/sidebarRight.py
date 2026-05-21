import helium
from helium.types import Window

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
        
        # Track visibility state manually
        self.is_visible = False
        self.hide()

    def show(self):
        super().show()
        self.is_visible = True

    def hide(self):
        super().hide()
        self.is_visible = False