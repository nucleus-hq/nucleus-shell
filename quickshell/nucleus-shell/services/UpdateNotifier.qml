import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Item {
    id: updater
    // Add 'v' arg to default local version because it is not stored
    // as vX.Y.Z but X.Y.Z while on github its published as vX.Y.Z

    property string currentVersion: ""
    property string latestVersion: ""
    property bool notified: false
    property string channel: Config.runtime.shell.releaseChannel || "stable"

    function readLocalVersion() {
        currentVersion = "v" + (Config.runtime.shell.version || "");
    }

    function fetchLatestVersion() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                try {
                    const json = JSON.parse(xhr.responseText);

                    if (channel === "stable") {
                        // /releases/latest returns a single object
                        if (json.tag_name) {
                            latestVersion = json.tag_name;
                            compareVersions();
                        } else {
                            console.warn("Stable update check returned unexpected response:", json);
                        }
                    } else if (channel === "edge") {
                        // /releases returns an array, newest first
                        for (var i = 0; i < json.length; i++) {
                            if (json[i].prerelease === true) {
                                latestVersion = json[i].tag_name;
                                compareVersions();
                                return;
                            }
                        }
                        console.warn("Edge channel: no pre-release found.");
                    }
                } catch (e) {
                    console.warn("Update check JSON parse failed:", xhr.responseText);
                }
            }
        };

        if (channel === "stable") {
            xhr.open("GET", "https://api.github.com/repos/xzepyx/nucleus-shell/releases/latest");
        } else {
            xhr.open("GET", "https://api.github.com/repos/xzepyx/nucleus-shell/releases");
        }

        xhr.send();
    }

    function compareVersions() {
        if (!currentVersion || !latestVersion)
            return;

        if (currentVersion !== latestVersion && currentVersion !== "vRC" && !notified) {
            notifyUpdate();
            notified = true;
        }
    }

    function notifyUpdate() {
        Quickshell.execDetached(["notify-send", "-a", "Nucleus Shell", "Update Available", "Installed: " + currentVersion + "\nLatest (" + channel + "): " + latestVersion]);
    }

    visible: false

    Timer {
        interval: 24 * 60 * 60 * 1000 // 24 hours
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            readLocalVersion();
            fetchLatestVersion();
        }
    }
}
