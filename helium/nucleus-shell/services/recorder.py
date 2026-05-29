import subprocess
import os
from datetime import datetime

_process = None
_output_path = None

def is_recording() -> bool:
    global _process
    if _process is None:
        return False
    return _process.poll() is None

def toggle_recording() -> tuple[bool, str]:
    global _process, _output_path
    
    if is_recording():
        _process.terminate()
        try:
            _process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            _process.kill()
        _process = None
        
        filename = os.path.basename(_output_path)
        subprocess.Popen([
            "notify-send", 
            "-a", "Helium Recorder", 
            "Screen Recording Saved", 
            f"Saved to {filename}"
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        return False, "Ready"

    try:
        geometry = subprocess.check_output(["slurp"], text=True).strip()
    except subprocess.CalledProcessError:
        return False, "Ready" # If user escapes out, reset to Ready

    videos_dir = os.path.expanduser("~/Videos")
    os.makedirs(videos_dir, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    _output_path = os.path.join(videos_dir, f"recording_{timestamp}.mp4")

    try:
        _process = subprocess.Popen(
            ["wf-recorder", "-g", geometry, "-f", _output_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        return True, "Recording..."
    except FileNotFoundError:
        return False, "Missing wf-recorder"