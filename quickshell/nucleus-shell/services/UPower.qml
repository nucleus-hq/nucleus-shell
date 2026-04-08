import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Item {
    // I have to make such services because quickshell services like Quickshell.Services.UPower don't work and are messy.

    id: root

    // Battery
    property int percentage: 0
    property string state: "unknown"
    property string iconName: ""
    property bool onBattery: false
    property bool charging: false
    property bool batteryPresent: false
    property bool rechargeable: false
    // Energy metrics
    property real energyWh: 0
    property real energyFullWh: 0
    property real energyRateW: 0
    property real capacityPercent: 0
    // AC / system
    property bool acOnline: false
    property bool lidClosed: false
    property string battIcon: {
        const b = percentage;
        if (b > 80)
            return "battery_6_bar";

        if (b > 60)
            return "battery_5_bar";

        if (b > 50)
            return "battery_4_bar";

        if (b > 40)
            return "battery_3_bar";

        if (b > 30)
            return "battery_2_bar";

        if (b > 20)
            return "battery_1_bar";

        if (b > 10)
            return "battery_alert";

        return "battery_0_bar";
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: upowerProc.running = true
    }

    Process {
        id: upowerProc

        command: ["upower", "-d"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                // ---------- DisplayDevice (preferred) ----------
                // ---------- Rechargeable ----------
                // ---------- Physical battery (extra info) ----------
                // ---------- Daemon / system ----------
                // ---------- AC adapter ----------

                const t = text;
                let m;
                m = t.match(/DisplayDevice[\s\S]*?present:\s+(yes|no)/);
                if (m) {
                    root.batteryPresent = (m[1] === "yes");
                } else {
                    // fallback: physical battery
                    m = t.match(/battery_BAT\d+[\s\S]*?present:\s+(yes|no)/);
                    if (m)
                        root.batteryPresent = (m[1] === "yes");

                }
                m = t.match(/DisplayDevice[\s\S]*?rechargeable:\s+(yes|no)/);
                if (m)
                    root.rechargeable = (m[1] === "yes");

                m = t.match(/DisplayDevice[\s\S]*?percentage:\s+(\d+)%/);
                if (m)
                    root.percentage = parseInt(m[1]);

                m = t.match(/DisplayDevice[\s\S]*?state:\s+([a-z\-]+)/);
                if (m) {
                    root.state = m[1];
                    root.charging = (m[1].includes("charge"));
                }
                m = t.match(/DisplayDevice[\s\S]*?icon-name:\s+'([^']+)'/);
                if (m)
                    root.iconName = m[1];

                m = t.match(/DisplayDevice[\s\S]*?energy:\s+([\d.]+)\s+Wh/);
                if (m)
                    root.energyWh = parseFloat(m[1]);

                m = t.match(/DisplayDevice[\s\S]*?energy-full:\s+([\d.]+)\s+Wh/);
                if (m)
                    root.energyFullWh = parseFloat(m[1]);

                m = t.match(/DisplayDevice[\s\S]*?energy-rate:\s+([\d.]+)\s+W/);
                if (m)
                    root.energyRateW = parseFloat(m[1]);

                m = t.match(/capacity:\s+([\d.]+)%/);
                if (m)
                    root.capacityPercent = parseFloat(m[1]);

                m = t.match(/on-battery:\s+(yes|no)/);
                if (m)
                    root.onBattery = (m[1] === "yes");

                m = t.match(/lid-is-closed:\s+(yes|no)/);
                if (m)
                    root.lidClosed = (m[1] === "yes");

                m = t.match(/line-power[\s\S]*?online:\s+(yes|no)/);
                if (m)
                    root.acOnline = (m[1] === "yes");

            }
        }

    }

}
