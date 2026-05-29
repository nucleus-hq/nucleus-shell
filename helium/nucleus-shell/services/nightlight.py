import subprocess

def is_hyprsunset_running() -> bool:
    try:
        result = subprocess.run(["pgrep", "hyprsunset"], capture_output=True)
        return result.returncode == 0
    except FileNotFoundError:
        return False

def toggle_night_light(variant: str = "cold") -> bool:
    if is_hyprsunset_running():
        subprocess.run(["pkill", "hyprsunset"])
        return False
        
    temperature = "3000" if variant == "warm" else "8000"
    
    try:
        # Use Popen instead of run() so it executes completely in the background
        subprocess.Popen(
            ["hyprsunset", "-t", temperature],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        return True
    except FileNotFoundError:
        return False