import platform
import time

OS_ICONS = {
    "almalinux": "",
    "alpine": "",
    "arch": "󰣇",
    "archcraft": "",
    "arcolinux": "",
    "artix": "",
    "centos": "",
    "debian": "",
    "devuan": "",
    "elementary": "",
    "endeavouros": "",
    "fedora": "",
    "freebsd": "",
    "garuda": "",
    "gentoo": "",
    "hyperbola": "",
    "kali": "",
    "linuxmint": "󰣭",
    "mageia": "",
    "openmandriva": "",
    "manjaro": "",
    "neon": "",
    "nixos": "",
    "opensuse": "",
    "suse": "",
    "sles": "",
    "sles_sap": "",
    "opensuse-tumbleweed": "",
    "parrot": "",
    "pop": "",
    "raspbian": "",
    "rhel": "",
    "rocky": "",
    "slackware": "",
    "solus": "",
    "steamos": "",
    "tails": "",
    "trisquel": "",
    "ubuntu": "",
    "vanilla": "",
    "void": "",
    "zorin": "",
}

import time


def fetch_uptime():
    try:
        with open("/proc/uptime", "r") as f:
            # /proc/uptime contains two numbers: (total uptime) and (idle time)
            uptime_seconds = float(f.readline().split()[0])

            # Convert seconds into a structured format (days, hours, minutes)
            uptime_struct = time.gmtime(uptime_seconds)

            days = int(uptime_seconds // 86400)
            hours = uptime_struct.tm_hour
            minutes = uptime_struct.tm_min

            if days > 0:
                return f"{days}d {hours}h {minutes}m"
            elif hours > 0:
                return f"{hours}h {minutes}m"
            else:
                return f"{minutes}m"

    except (FileNotFoundError, PermissionError):
        return "unknown"


def fetch_os_name():
    try:
        return platform.freedesktop_os_release().get("ID", "linux")
    except AttributeError:
        return platform.system().lower()


def fetch_os_icon(os: str):
    return OS_ICONS.get(os, "🐧")


os_name = fetch_os_name()
os_icon = fetch_os_icon(os_name)
