import json
import subprocess

def get_current_window_details():
    try:
        # Query hyprctl for the currently focused window in JSON format
        raw_json = subprocess.check_output(["hyprctl", "activewindow", "-j"]).decode("utf-8")
        data = json.loads(raw_json)
        
        # 'title' contains user-facing names like "Code OSS" or "file.py - Code - OSS"
        window_title = data.get("title", "")
        
        # 'class' contains the system/instance class name (e.g., "code-oss")
        window_class = data.get("class", "")
        
        # 'initialClass' often matches standard application IDs (like org.freedesktop...)
        initial_class = data.get("initialClass", "")
        
        return {
            "title": window_title,
            "class": window_class,
            "initial_class": initial_class
        }
    except Exception:
        return None
