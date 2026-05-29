import subprocess

_process = None

def is_inhibiting() -> bool:
    global _process
    if _process is None:
        return False
    return _process.poll() is None

def toggle_idle_inhibit() -> tuple[bool, str]:
    global _process

    if is_inhibiting():
        _process.terminate()
        try:
            _process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            _process.kill()
        _process = None
        return False, "Inactive"

    try:
        _process = subprocess.Popen(
            ["systemd-inhibit", "--what=idle:sleep", "--who=helium",
             "--why=User toggle", "tail", "-f", "/dev/null"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )
        return True, "Active"
    except FileNotFoundError:
        return False, "Missing systemd-inhibit"
