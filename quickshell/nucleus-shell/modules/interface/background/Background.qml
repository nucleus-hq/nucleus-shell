import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        WallpaperLayer {
            modelData: modelData
        }
    }

    Clock {
        id: clock
    }
}