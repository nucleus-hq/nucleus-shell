pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

/**
 * TaskbarApps: manages the dock's app list.
 *
 * Combines pinned apps (from config) with currently running apps
 * (from ToplevelManager), grouped by appId.
 *
 * Each entry exposes:
 *   appId: string
 *   toplevels: list of Toplevel objects (have .activated and .activate())
 *   toplevelCount: int
 */
Singleton {
    id: root

    // Pinned app IDs, persisted in config. "SEPARATOR" is a special value.
    property var pinnedAppIds: Config.runtime.dockPinnedApps ?? []

    // Running apps indexed by appId, rebuilt when toplevels change.
    readonly property var _runningByAppId: {
        const map = {}
        const all = ToplevelManager.toplevels.values
        for (const t of all) {
            const id = t.appId
            if (!id) continue
            if (!map[id])
                map[id] = { appId: id, toplevels: [], toplevelCount: 0 }
            map[id].toplevels.push(t)
            map[id].toplevelCount++
        }
        return map
    }

    // Final ordered list: pinned first, then any extra running apps.
    readonly property var apps: {
        const list = []
        const seen = new Set()

        for (const appId of root.pinnedAppIds) {
            if (appId === "SEPARATOR") {
                list.push({ appId: "SEPARATOR", toplevels: [], toplevelCount: 0 })
                continue
            }
            list.push(root._runningByAppId[appId] || { appId, toplevels: [], toplevelCount: 0 })
            seen.add(appId)
        }

        for (const id in root._runningByAppId) {
            if (!seen.has(id))
                list.push(root._runningByAppId[id])
        }

        return list
    }

    // Toggle whether an appId is pinned, and save to config.
    function togglePin(appId) {
        const pinned = Array.from(root.pinnedAppIds)
        const idx = pinned.indexOf(appId)
        if (idx >= 0)
            pinned.splice(idx, 1)
        else
            pinned.push(appId)
        root.pinnedAppIds = pinned
        Config.updateKey("dockPinnedApps", pinned)
    }
}
