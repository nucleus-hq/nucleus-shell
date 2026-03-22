#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLUE="\033[34m"
RESET="\033[0m"

clear
echo -e "${BLUE}"
cat <<'EOF'
 _   _            _                    ____  _          _ _
| \ | |_   _  ___| | ___ _   _ ___    / ___|| |__   ___| | |
|  \| | | | |/ __| |/ _ \ | | / __|   \___ \| '_ \ / _ \ | |
| |\  | |_| | (__| |  __/ |_| \__ \    ___) | | | |  __/ | |
|_| \_|\__,_|\___|_|\___|\__,_|___/   |____/|_| |_|\___|_|_|
EOF
echo -e "${RESET}"

# Run installation steps
if bash "$ROOT_DIR/pkg.sh" && \
   mkdir -p ~/.config/quickshell/nucleus-shell && \
   cp -r "$ROOT_DIR/../quickshell/nucleus-shell/"* ~/.config/quickshell/nucleus-shell
then
    echo "Finished!"
    echo "Check ~/.config/quickshell/nucleus-shell/* exists to confirm installation."

    # Increment counter ONLY on success
    curl -fsS https://api.counterapi.dev/v1/xzepyx/nucleus-shell/up >/dev/null 2>&1 || true
else
    echo "Installation failed. Skipping counter update."
    exit 1
fi
