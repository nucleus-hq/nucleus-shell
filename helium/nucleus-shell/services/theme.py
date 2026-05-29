import subprocess
import helium

def toggle_theme_mode(current_theme: str = "dark") -> str:
    next_mode = "light" if current_theme == "dark" else "dark"
    
    try:
        helium.config.set("appearance.theme", next_mode)
    except Exception:
        pass

    wallpaper_path = None
    try:
        wallpaper_path = helium.config.get("appearance.background.path")
    except Exception:
        pass

    if wallpaper_path:
        cmd = ["matugen", "image", str(wallpaper_path), "-m", next_mode, "--prefer", "darkness"]
        try:
            subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True
            )
        except FileNotFoundError:
            pass
            
    return next_mode