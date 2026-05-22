import subprocess
import helium

def toggle_theme_mode(current_theme: str = "dark") -> str:
    # 1. Flip the mode explicitly in memory
    next_mode = "light" if current_theme == "dark" else "dark"
    
    # 2. Update Helium's live state directly
    try:
        helium.config.set("appearance.theme", next_mode)
    except Exception as e:
        print(f"Config write error: {e}")

    # 3. Pull background wallpaper reference
    wallpaper_path = None
    try:
        wallpaper_path = helium.config.get("appearance.background.path")
    except Exception:
        pass

    if wallpaper_path:
        # Crucial fix: Added the template configuration flags 
        # so matugen knows to parse configuration maps over to your layout paths
        cmd = ["matugen", "image", str(wallpaper_path), "-m", next_mode]
        try:
            subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True
            )
        except FileNotFoundError:
            print("Error: 'matugen' binary not found in system PATH.")
            
    return next_mode