pragma Singleton
import QtQuick
import Quickshell
import qs.modules.functions
import qs.config

/*
    This registry is only used to get app details for wm classes.
*/

Singleton {
    id: registry

    property var apps: []
    property var classToIcon: ({})
    property var desktopIdToIcon: ({})
    property var nameToIcon: ({})

    signal ready()

    function iconForDesktopIcon(icon) {
        if (!icon) return ""

        // If it's already a URL, keep it
        if (icon.startsWith("file://") || icon.startsWith("qrc:/"))
            return icon

        // Absolute filesystem path → convert to file URL
        if (icon.startsWith("/"))
            return "file://" + icon

        // Try exact theme icon name first
        const exact = Quickshell.iconPath(icon, true)
        if (exact) return exact

        // Symbolic fallback for themes like Adwaita that only ship -symbolic variants
        const symbolic = Quickshell.iconPath(icon + "-symbolic", true)
        if (symbolic) return symbolic

        // Pixmaps fallback for apps that ship their icon outside the theme
        const exts = ["png", "svg", "xpm"]
        for (const ext of exts) {
            const path = "/usr/share/pixmaps/" + icon + "." + ext
            if (FileUtils.fileExists(path))
                return "file://" + path
        }

        return ""
    }

    // Try very aggressive matching so the running app always gets the same icon as launcher
    function iconForClass(id) {
        if (!id) return ""

        const lower = id.toLowerCase()

        // direct hits first
        if (classToIcon[lower])
            return iconForDesktopIcon(classToIcon[lower])

        if (desktopIdToIcon[lower])
            return iconForDesktopIcon(desktopIdToIcon[lower])

        if (nameToIcon[lower])
            return iconForDesktopIcon(nameToIcon[lower])

        // fuzzy contains match against wmClass map
        for (let key in classToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(classToIcon[key])
        }

        // fuzzy against desktop ids
        for (let key in desktopIdToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(desktopIdToIcon[key])
        }

        // fuzzy against names
        for (let key in nameToIcon) {
            if (lower.includes(key) || key.includes(lower))
                return iconForDesktopIcon(nameToIcon[key])
        }

        // final fallback to theme resolution
        const resolved = FileUtils.resolveIcon(id)
        return iconForDesktopIcon(resolved)
    }

    // Extra helper: resolve icon using any metadata we might have (Hyprland, Niri, etc.)
    function iconForAppMeta(meta) {
        if (!meta) return Quickshell.iconPath("application-x-executable")

        const candidates = [
            meta.appId,
            meta.class,
            meta.initialClass,
            meta.desktopId,
            meta.title,
            meta.name
        ]

        for (let c of candidates) {
            const icon = iconForClass(c)
            if (icon !== "")
                return icon
        }

        // fallback: try compositor provided icon name
        if (meta.icon)
            return iconForDesktopIcon(meta.icon)

        // hard fallback icons (guaranteed to exist in most themes)
        const fallbacks = [
            "application-x-executable",
            "application-default-icon",
            "window"
        ]

        for (let f of fallbacks) {
            const resolved = Quickshell.iconPath(f)
            if (resolved)
                return resolved
        }

        return ""
    }

    function registerApp(displayName, comment, icon, exec, wmClass, desktopId) {
        const entry = {
            name: displayName,
            comment: comment,
            icon: icon,
            exec: exec,
            wmClass: wmClass,
            desktopId: desktopId
        }

        apps.push(entry)

        if (wmClass)
            classToIcon[wmClass.toLowerCase()] = icon

        if (desktopId)
            desktopIdToIcon[desktopId.toLowerCase()] = icon

        if (displayName)
            nameToIcon[displayName.toLowerCase()] = icon

        // Hard aliases for apps with messy WM_CLASS values
        if (displayName.toLowerCase().includes("visual studio code") ||
            icon.toLowerCase().includes("code")) {

            classToIcon["code"] = icon
            classToIcon["code-oss"] = icon
            classToIcon["code-url-handler"] = icon
            desktopIdToIcon["code.desktop"] = icon
            desktopIdToIcon["code-oss.desktop"] = icon
        }
    }

    function buildRegistry() {
        const entries = DesktopEntries.applications.values
        if (entries.length === 0) return

        // Reset maps before rebuilding
        registry.classToIcon = {}
        registry.desktopIdToIcon = {}
        registry.nameToIcon = {}
        registry.apps = []

        for (let entry of entries) {
            if (entry.noDisplay)
                continue

            registry.registerApp(
                entry.name || "",
                entry.comment || "",
                entry.icon || "",
                entry.execString || "",
                entry.startupWMClass || "",
                entry.id || ""
            )
        }

        registry.ready()
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { buildRegistry() }
    }

    Component.onCompleted: buildRegistry()
}