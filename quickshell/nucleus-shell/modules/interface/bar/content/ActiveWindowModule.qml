import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Item {
    id: container

    property string displayName: screen?.name ?? ""

    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

    property Toplevel activeToplevel: Compositor.isWorkspaceOccupied(Compositor.focusedWorkspaceId)
        ? Compositor.activeToplevel
        : null

    readonly property string appId: activeToplevel?.appId ?? ""
    readonly property string windowTitle: activeToplevel?.title ?? ""

    implicitHeight: ConfigResolver.bar(displayName).modules.height
    implicitWidth: row.implicitWidth + 24

    function cleanTitle(title) {
        if (!title)
            return ""

        title = title.replace(/[●⬤○◉◌◎]/g, "")

        title = title
            .replace(/\s*[|—]\s*/g, " - ")
            .replace(/\s+/g, " ")
            .trim()

        const parts = title.split(" - ").map(p => p.trim()).filter(Boolean)

        if (parts.length === 1)
            return parts[0]

        const app = parts[parts.length - 1]
        const context = parts[0]

        if (context && context !== app)
            return `${app} · ${context}`

        return app
    }

    function trimTitle(text, max) {
        if (!text)
            return ""

        if (text.length <= max)
            return text

        const separators = [" · ", " - ", " | "]

        for (let s of separators) {
            if (text.includes(s)) {
                const parts = text.split(s)
                const left = parts[0]
                const right = parts.slice(1).join(s)

                if (left.length + right.length + 5 <= max)
                    return `${left}${s}${right}`

                const rmax = Math.floor(max * 0.55)
                if (right.length > rmax)
                    return `${left}${s}${right.slice(0, rmax)}…`

                return `${left}${s}${right}`
            }
        }

        const half = Math.floor(max / 2)

        return text.substring(0, half)
             + "…"
             + text.substring(text.length - half)
    }

    function resolveIcon(appId) {
        if (!appId)
            return "application-x-executable"

        const id = appId.toLowerCase()

        const map = {
            "org.mozilla.firefox": "firefox",
            "firefox": "firefox",
            "chromium": "chromium",
            "google-chrome": "google-chrome",
            "code": "vscode",
            "code-oss": "vscode",
            "kitty": "kitty",
            "alacritty": "alacritty",
            "discord": "discord",
            "spotify": "spotify",
            "steam": "steam"
        }

        return map[id] || id
    }

    Rectangle {
        anchors.fill: parent

        visible: ConfigResolver.bar(displayName).position === "top"
              || ConfigResolver.bar(displayName).position === "bottom"

        radius: ConfigResolver.bar(displayName).modules.radius

        color: Appearance.m3colors.m3surfaceContainerLow
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Item {
            id: iconContainer

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Math.min(container.implicitHeight * 0.55, 20)
            Layout.preferredHeight: Layout.preferredWidth

            Image {
                anchors.fill: parent

                source: activeToplevel
                    ? "image://icon/" + resolveIcon(appId)
                    : "image://icon/user-desktop"

                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true
            }
        }

        StyledText {
            id: titleText

            Layout.alignment: Qt.AlignVCenter

            text: {
                if (!activeToplevel)
                    return "Desktop"

                const cleaned = cleanTitle(windowTitle)
                return trimTitle(cleaned, 34)
            }

            font.pixelSize: Appearance.font.size.small
            elide: Text.ElideRight
        }
    }
}
