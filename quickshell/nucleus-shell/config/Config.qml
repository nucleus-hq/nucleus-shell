pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import qs.plugins
import qs.services

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias runtime: configOptionsJsonAdapter
    property bool initialized: false
    property int readWriteDelay: 50
    property bool blockWrites: false

    function updateKey(nestedKey, value) {
        let keys = nestedKey.split(".")
        let obj = root.runtime
        if (!obj) {
            console.warn("Config.updateKey: adapter not available for key", nestedKey)
            return
        }

        for (let i = 0; i < keys.length - 1; ++i) {
            let k = keys[i]
            if (obj[k] === undefined || obj[k] === null || typeof obj[k] !== "object") {
                obj[k] = {}  // Use Plain JS for serialization
            }
            obj = obj[k]
            if (!obj) {
                console.warn("Config.updateKey: failed to resolve", k)
                return
            }
        }

        let convertedValue = value
        if (typeof value === "string") {
            let trimmed = value.trim()
            if (trimmed === "true" || trimmed === "false" || (!isNaN(Number(trimmed)) && trimmed !== "")) {
                try {
                    convertedValue = JSON.parse(trimmed)
                } catch (e) {
                    convertedValue = value
                }
            }
        }

        obj[keys[keys.length - 1]] = convertedValue
        configFileView.adapterUpdated()
    }

    function loadPluginConfigs(plugins) {
        console.log("Loading plugins:", plugins)

        if (!root.runtime)
            return

        if (!root.runtime.plugins)
            root.runtime.plugins = {}

        function mergeDefaults(target, defaults) {
            let changed = false

            for (let key in defaults) {
                const defVal = defaults[key]
                const tgtVal = target[key]

                if (tgtVal === undefined) {
                    target[key] = defVal
                    changed = true
                } else if (
                    typeof tgtVal === "object" &&
                    typeof defVal === "object" &&
                    tgtVal !== null &&
                    defVal !== null
                ) {
                    if (mergeDefaults(tgtVal, defVal))
                        changed = true
                }
            }

            return changed
        }

        let anyChange = false

        for (let i = 0; i < plugins.length; i++) {
            const name = plugins[i]
            const path = Directories.shellConfig + "/plugins/" + name + "/PluginConfigData.qml"

            const component = Qt.createComponent(path)
            if (component.status === Component.Error) {
                console.warn("Plugin failed:", path, component.errorString())
                continue
            }

            if (component.status !== Component.Ready)
                continue

            const pluginObj = component.createObject(root)
            if (!pluginObj) {
                console.warn("Failed to create plugin object:", name)
                component.destroy()
                continue
            }

            if (!pluginObj.defaults)
                pluginObj.defaults = { enabled: false }

            if (!root.runtime.plugins[name]) {
                root.runtime.plugins[name] = {}
                anyChange = true
            }

            if (mergeDefaults(root.runtime.plugins[name], pluginObj.defaults))
                anyChange = true

            console.log("Plugin config injected:", name)

            pluginObj.destroy()
            component.destroy()
        }

        if (anyChange) {
            console.log("Plugin defaults merged, writing config")
            configFileView.adapterUpdated()
        } else {
            console.log("Plugin configs already up to date")
        }
    }

    Timer { id: fileReloadTimer; interval: root.readWriteDelay; repeat: false; onTriggered: configFileView.reload() }
    Timer { id: fileWriteTimer; interval: root.readWriteDelay; repeat: false; onTriggered: configFileView.writeAdapter() }

    Timer { // Used to output all log/debug to the terminal
        interval: 1200
        running: true
        repeat: false
        onTriggered: {
            console.log("Injecting plugin configs")
            root.loadPluginConfigs(PluginLoader.plugins)
            console.log("Detected Compositor:", Compositor.detectedCompositor)
        }
    }

    FileView {
        id: configFileView
        path: root.filePath
        watchChanges: true
        blockWrites: root.blockWrites
        onFileChanged: fileReloadTimer.restart()
        onAdapterUpdated: fileWriteTimer.restart()
        onLoaded: { root.initialized = true }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) writeAdapter()
        }

        JsonAdapter {
            id: configOptionsJsonAdapter
            
            property var plugins: ({}) // dynamic plugins config variable
            property var monitors: ({}) // per-monitor configuration for bars and wallpapers

            property JsonObject appearance: JsonObject {
                property string theme: "dark"
                property bool tintIcons: false
                property JsonObject animations: JsonObject { property bool enabled: true; property double durationScale: 1 }
                property JsonObject transparency: JsonObject { property bool enabled: false; property double alpha: 0.2 }
                property JsonObject rounding: JsonObject { property double factor: 1 }
                property JsonObject font: JsonObject { 
                    property double scale: 1 
                    property JsonObject families: JsonObject {
                        property string main: "JetBrains Mono"
                        property string title: "Gabarito"
                        property string materialIcons: "Material Symbols Rounded"
                        property string nerdFonts: "JetBrains Mono NF"
                        property string monospace: "JetBrains Mono NF"
                        property string reading: "Readex Pro"
                        property string expressive: "Space Grotesk"
                    }
                }
                property JsonObject colors: JsonObject {
                    property string scheme: "catppuccin-lavender"
                    property string matugenScheme: "scheme-neutral"
                    property bool autogenerated: true
                    property bool runMatugenUserWide: false
                }
                property JsonObject background: JsonObject {
                    property bool enabled: true 
                    property url defaultPath: Directories.defaultsPath + "/default.jpg"
                    property JsonObject parallax: JsonObject {
                        property bool enabled: true 
                        property bool enableSidebarLeft: true
                        property bool enableSidebarRight: true
                        property real zoom: 1.10
                    }
                    property JsonObject clock: JsonObject {
                        property bool enabled: true 
                        property bool isAnalog: true
                        property bool rotatePolygonBg: false 
                        property int rotationDuration: 18 // lower the faster
                        property int edgeSpacing: 50
                        property int shape: 1
                        property int xPos: 0
                        property int yPos: 0
                        property bool animateHands: false
                    }
                    property JsonObject slideshow: JsonObject {
                        property bool enabled: false
                        property bool includeSubfolders: true
                        property int interval: 5
                        property string folder: ""
                    }
                }
            }

            property JsonObject misc: JsonObject { 
                property url pfp: Quickshell.env("HOME") + "/.face.icon" 
                property bool useMergedSidebarLayout: false // use merged sidebar layout when bar is merged
                property JsonObject intelligence: JsonObject {
                    property bool enabled: true
                    property string apiKey: ""
                }
            }

            
            property JsonObject notifications: JsonObject {
                property bool enabled: true 
                property bool doNotDisturb: false
                property string position: "center"
            }
            property JsonObject shell: JsonObject {
                property string version: "0.7.7"
                property string releaseChannel: "stable"
                property string qsVersion: "0.0.0"
            }
            property JsonObject overlays: JsonObject {
                property bool enabled: true 
                property bool volumeOverlayEnabled: true 
                property bool brightnessOverlayEnabled: true
                property string volumeOverlayPosition: "top"
                property string brightnessOverlayPosition: "top"
            }
            property JsonObject launcher: JsonObject {
                property bool fuzzySearchEnabled: true
                property string webSearchEngine: "google"
            }
            property JsonObject bar: JsonObject {
                property string position: "top"
                property bool enabled: true
                property bool merged: false
                property bool floating: false
                property bool gothCorners: true
                property int radius: Appearance.rounding.large
                property int margins: Appearance.margin.normal
                property int density: 50
                property JsonObject modules: JsonObject {
                    property color paddingColor: Appearance.m3colors.m3surfaceContainer
                    property int radius: Appearance.rounding.normal
                    property int height: 34
                    property JsonObject workspaces: JsonObject {
                        property bool enabled: true
                        property int workspaceIndicators: 8
                        property bool showAppIcons: true 
                        property bool showJapaneseNumbers: false
                    }
                    property JsonObject statusIcons: JsonObject {
                        property bool enabled: true
                        property bool networkStatusEnabled: true 
                        property bool bluetoothStatusEnabled: true 
                    }
                    property JsonObject systemUsage: JsonObject {
                        property bool enabled: true
                        property bool cpuStatsEnabled: true 
                        property bool memoryStatsEnabled: true 
                        property bool tempStatsEnabled: true
                    }
                }
            }
        }
    }
}
