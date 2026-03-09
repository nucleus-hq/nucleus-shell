#!/usr/bin/env bash
set -Eeuo pipefail

# Paths / repo
CONFIG="$HOME/.config/nucleus-shell/config/configuration.json"
QS_DIR="$HOME/.config/quickshell/nucleus-shell"
REPO="xZepyx/nucleus-shell"
API="https://api.github.com/repos/$REPO/releases"

# Spinner
spinner() {
    local pid=$1
    local spin='|/-\'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r[*] %s %c" "$SPINNER_MSG" "${spin:i++%4:1}"
        sleep 0.1
    done
}

run() {
    SPINNER_MSG="$1"
    shift
    "$@" &>/dev/null &
    spinner $!
    wait $! || fail "$SPINNER_MSG failed"
    printf "\r[✓] %s\n" "$SPINNER_MSG"
}

fail() {
    printf "[✗] %s\n" "$1" >&2
    exit 1
}

info() {
    printf "[*] %s\n" "$1"
}

# Selection
echo "Select the version to install:"
echo "1. Latest"
echo "2. Edge"
echo "3. Tag"
echo "4. Git"

read -rp "[?] Choice: " choice

case "$choice" in
    1) mode="stable" ;;
    2) mode="indev" ;;
    3)
        mode="tag"
        read -rp "[?] Enter tag (ex: v0.7.6): " latest_tag
        [[ -z "$latest_tag" ]] && fail "No tag provided"
        latest="${latest_tag#v}"
        ;;
    4)
        mode="git"
        latest="RC"
        ;;
    *) fail "Invalid choice" ;;
esac

# Validate config
[[ -f "$CONFIG" ]] || fail "configuration.json not found"

current="$(jq -r '.shell.version // empty' "$CONFIG")"
[[ -n "$current" ]] || fail "Current version not set"

tmp="$(mktemp -d)"


if [[ "$mode" == "git" ]]; then
    repo_dir="$tmp/repo"
    SRC_DIR="$repo_dir/quickshell/nucleus-shell"

    run "Cloning repository" \
        git clone --depth=1 "https://github.com/$REPO.git" "$repo_dir"

    [[ -d "$SRC_DIR" ]] || fail "nucleus-shell directory missing in repo"

    run "Installing files" bash -c "
        rm -rf '$QS_DIR' &&
        mkdir -p '$QS_DIR' &&
        cp -r '$SRC_DIR/'* '$QS_DIR/'
    "
		
	# Update config
	run "Updating configuration" bash -c "
		tmp_cfg=\$(mktemp) &&
		jq --arg v '$latest' '.shell.version = \$v' '$CONFIG' > \"\$tmp_cfg\" &&
		mv \"\$tmp_cfg\" '$CONFIG'
	"

    run "Reloading shell" bash -c "
        killall quickshell &>/dev/null || true
        nohup quickshell -c nucleus-shell &>/dev/null & disown
    "

    printf "[✓] Updated to nucleus-shell git-rc \n"
    exit 0
fi

if [[ "$mode" == "stable" || "$mode" == "indev" ]]; then
    info "Resolving release"
    latest_tag="$(
        curl -fsSL "$API" |
        jq -r "
            map(select(.draft == false)) |
            $( [[ "$mode" == "stable" ]] && echo 'map(select(.prerelease == false)) |' )
            sort_by(.published_at) |
            last |
            .tag_name
        "
    )"

    [[ -n "$latest_tag" && "$latest_tag" != "null" ]] || fail "Release resolution failed"
    latest="${latest_tag#v}"
fi

# No-op
if [[ "$current" == "$latest" ]]; then
    info "Already up to date ($current)"
    exit 0
fi

zip="$tmp/source.zip"
root_dir="$tmp/nucleus-shell-$latest"
SRC_DIR="$root_dir/quickshell/nucleus-shell"

# Download
run "Downloading nucleus-shell $latest" \
    curl -fsSL \
    "https://github.com/$REPO/archive/refs/tags/$latest_tag.zip" \
    -o "$zip"

# Extract
run "Extracting archive" unzip -q "$zip" -d "$tmp"

[[ -d "$SRC_DIR" ]] || fail "nucleus-shell directory missing in archive"

# Install
run "Installing files" bash -c "
    rm -rf '$QS_DIR' &&
    mkdir -p '$QS_DIR' &&
    cp -r '$SRC_DIR/'* '$QS_DIR/'
"

# Update config
run "Updating configuration" bash -c "
    tmp_cfg=\$(mktemp) &&
    jq --arg v '$latest' '.shell.version = \$v' '$CONFIG' > \"\$tmp_cfg\" &&
    mv \"\$tmp_cfg\" '$CONFIG'
"

# Reload shell
run "Reloading shell" bash -c "
    killall quickshell &>/dev/null || true
    nohup quickshell -c nucleus-shell &>/dev/null & disown
"

printf "[✓] Updated nucleus-shell: %s -> %s\n" "$current" "$latest"
