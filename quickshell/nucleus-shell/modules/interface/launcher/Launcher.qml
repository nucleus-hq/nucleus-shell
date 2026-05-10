pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.components

PanelWindow {
    id: launcher

    WlrLayershell.namespace:     "nucleus:launcher"
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: Globals.visiblility.launcher

    color:    "transparent"
    visible:  Globals.visiblility.launcher

    anchors { top: true; bottom: true; left: true; right: true }

    property string searchText:    ""
    property int    categoryIndex: 0
    property bool   isSearching:   searchText.length > 0
    property string layout:        Config.runtime.launcher.layout === "list" ? "list" : "grid"

    readonly property var _searchEngines: ({
        "google":     { label: "Google",     icon: "language", url: "https://www.google.com/search?q=" },
        "brave":      { label: "Brave",      icon: "language", url: "https://search.brave.com/search?q=" },
        "duckduckgo": { label: "DuckDuckGo", icon: "language", url: "https://duckduckgo.com/?q=" },
        "bing":       { label: "Bing",       icon: "language", url: "https://www.bing.com/search?q=" },
    })

    readonly property string _engineKey: {
        const k = (Config.runtime.launcher.webSearchEngine ?? "google").toLowerCase()
        return _searchEngines[k] ? k : "google"
    }

    function _evalCalc(expr) {
        if (!expr || expr.trim() === "") return null
        // Only attempt eval on strings that look mathematical
        if (!/^[\d\s+\-*/^().%,]+$/.test(expr.trim())) return null
        try {
            // eslint-disable-next-line no-new-func
            const result = Function('"use strict"; return (' + expr.trim() + ')')()
            if (typeof result === "number" && isFinite(result)) return result
        } catch (e) {}
        return null
    }

    // Returns null when no special action, or an object:
    //   { type: "calc",   result: number, expr: string }
    //   { type: "web",    query: string,  engineLabel: string, url: string }
    readonly property var searchAction: {
        const q = searchText.trim()
        if (q === "") return null

        // Calculator — only when no apps match exactly or query looks like math
        const calcResult = launcher._evalCalc(q)
        if (calcResult !== null) {
            return { type: "calc", result: calcResult, expr: q }
        }

        // Web search — show when user prefixes with "?" or no apps found at all
        const forceWeb = q.startsWith("?")
        const cleanQ   = forceWeb ? q.slice(1).trim() : q
        if (forceWeb || (isSearching && launcher.displayApps.length === 0 && cleanQ.length > 0)) {
            const engine = launcher._searchEngines[launcher._engineKey]
            return {
                type:        "web",
                query:       cleanQ,
                engineLabel: engine.label,
                url:         engine.url + encodeURIComponent(cleanQ)
            }
        }

        return null
    }

    function _runSearchAction() {
        const action = launcher.searchAction
        if (!action) return false
        if (action.type === "calc") {
            // Copy result to clipboard
            Quickshell.execDetached(["sh", "-c",
                "echo -n '" + action.result + "' | wl-copy"])
            Globals.visiblility.launcher = false
            return true
        }
        if (action.type === "web") {
            Quickshell.execDetached(["xdg-open", action.url])
            Globals.visiblility.launcher = false
            return true
        }
        return false
    }

    readonly property var allApps: Apps.list

    readonly property var displayApps: {
        if (isSearching)
            return Config.runtime.launcher.fuzzySearchEnabled
                ? Apps.fuzzyQuery(searchText)
                : allApps.filter(a =>
                    a.name.toLowerCase().includes(searchText.toLowerCase()))

        if (categoryIndex === 0)
            return allApps

        const cat = _categories[categoryIndex].key
        return allApps.filter(a =>
            (a.categories ?? []).some(c => c.toLowerCase().includes(cat)))
    }

    readonly property var _categories: [
        { label: "All",       icon: "apps",           key: "" },
        { label: "Internet",  icon: "language",        key: "network" },
        { label: "Media",     icon: "play_circle",     key: "audio" },
        { label: "Dev",       icon: "code",            key: "development" },
        { label: "System",    icon: "settings",        key: "system" },
        { label: "Games",     icon: "sports_esports",  key: "game" },
        { label: "Office",    icon: "work",            key: "office" },
        { label: "Graphics",  icon: "palette",         key: "graphics" },
    ]

    onVisibleChanged: {
        if (!visible) {
            searchText    = ""
            categoryIndex = 0
            searchField.text = ""
        } else {
            revealAnim.restart()
            Qt.callLater(() => searchField.forceActiveFocus())
        }
    }

    Rectangle {
        anchors.fill: parent
        color:   "transparent"
        opacity: launcher.visible ? 0.45 : 0
        z: 0
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.durations.normal
                easing.type: Easing.OutCubic
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: Globals.visiblility.launcher = false
        }
    }

    Item {
        id: sheet
        z: 1
        width:  Math.min(parent.width  * 0.82, 880)
        height: Math.min(parent.height * 0.80, 700)
        anchors.centerIn: parent

        property real revealProgress: 0
        NumberAnimation on revealProgress {
            id: revealAnim
            from: 0; to: 1
            duration: Appearance.animation.durations.expressiveDefaultSpatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animation.curves.expressiveDefaultSpatial
        }

        opacity: revealProgress
        scale:   0.88 + 0.12 * revealProgress
        transformOrigin: Item.Center

        Rectangle {
            id: card
            anchors.fill: parent
            radius: Metrics.radius("verylarge")
            color:  Appearance.m3colors.m3background
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.margin.large
            spacing: Appearance.margin.small

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.margin.small

                Rectangle {
                    width: 40; height: 40
                    radius: Metrics.radius("normal")
                    color: Appearance.colors.colPrimary

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "apps"
                        iconSize: Metrics.iconSize(20)
                        color: Appearance.colors.colOnPrimary
                    }
                }

                StyledText {
                    text: "Applications"
                    font.family:    Appearance.font.family.title
                    font.pixelSize: Metrics.fontSize("large")
                    font.weight:    Font.DemiBold
                    opacity: 0.85
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: launcher.isSearching
                    height: 26
                    width:  resultLabel.implicitWidth + 20
                    radius: Metrics.radius("full")
                    color: Qt.rgba(
                        Appearance.colors.colPrimary.r,
                        Appearance.colors.colPrimary.g,
                        Appearance.colors.colPrimary.b, 0.14)

                    StyledText {
                        id: resultLabel
                        anchors.centerIn: parent
                        text: launcher.displayApps.length + " results"
                        font.pixelSize: Metrics.fontSize("smaller")
                        color: Appearance.colors.colPrimary
                    }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    width: 34; height: 34
                    radius: Metrics.radius("full")
                    color: layoutToggleMa.containsMouse
                        ? Appearance.colors.colLayer2Hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: launcher.layout === "grid" ? "view_list" : "view_cozy"
                        iconSize: Metrics.iconSize(20)
                        color: Appearance.colors.colOnLayer1
                        opacity: 0.7
                    }
                    MouseArea {
                        id: layoutToggleMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const next = launcher.layout === "grid" ? "list" : "grid"
                            launcher.layout = next
                            Config.updateKey("launcher.layout", next)
                        }
                    }
                }

                Rectangle {
                    width: 34; height: 34
                    radius: Metrics.radius("full")
                    color: closeMa.containsMouse
                        ? Appearance.colors.colLayer2Hover : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "close"
                        iconSize: Metrics.iconSize(20)
                        color: Appearance.colors.colOnLayer1
                        opacity: 0.7
                    }
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Globals.visiblility.launcher = false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 50
                radius: Metrics.radius("verylarge")
                color:  Appearance.colors.colLayer2
                border.color: searchField.activeFocus
                    ? Appearance.colors.colPrimary
                    : Appearance.colors.colOutline
                border.width: searchField.activeFocus ? 2 : 1

                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on border.width { NumberAnimation  { duration: 200 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 12 }
                    spacing: 10

                    MaterialSymbol {
                        icon: "search"
                        iconSize: Metrics.iconSize(20)
                        color: searchField.activeFocus
                            ? Appearance.colors.colPrimary
                            : Appearance.colors.colSubtext
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        font.family:    Appearance.font.family.main
                        font.pixelSize: Metrics.fontSize("normal")
                        color:          Appearance.colors.colOnLayer2
                        selectionColor: Qt.rgba(
                            Appearance.colors.colPrimary.r,
                            Appearance.colors.colPrimary.g,
                            Appearance.colors.colPrimary.b, 0.3)
                        clip: true

                        onTextChanged: launcher.searchText = text

                        Keys.onEscapePressed: {
                            if (text.length > 0) { text = ""; return }
                            Globals.visiblility.launcher = false
                        }
                        Keys.onReturnPressed: {
                            if (launcher._runSearchAction()) return
                            if (launcher.displayApps.length > 0) {
                                Apps.launch(launcher.displayApps[0])
                                Globals.visiblility.launcher = false
                            }
                        }
                        Keys.onDownPressed: {
                            if (launcher.layout === "grid")
                                appGrid.forceActiveFocus()
                            else
                                appList.forceActiveFocus()
                        }
                    }

                    Rectangle {
                        width: 28; height: 28
                        radius: Metrics.radius("full")
                        color:   clearMa.containsMouse
                            ? Appearance.colors.colLayer2Hover : "transparent"
                        visible: launcher.isSearching
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on color   { ColorAnimation  { duration: 120 } }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            icon: "close"
                            iconSize: Metrics.iconSize(16)
                            color: Appearance.colors.colSubtext
                        }
                        MouseArea {
                            id: clearMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: searchField.text = ""
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                height:  38
                visible: !launcher.isSearching
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Row {
                    anchors.fill: parent
                    spacing: Appearance.margin.tiny

                    Repeater {
                        model: launcher._categories

                        delegate: Item {
                            required property int index
                            required property var modelData

                            width:  chipRect.implicitWidth
                            height: 38

                            Rectangle {
                                id: chipRect
                                height: 34
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: chipRow.implicitWidth + 22
                                radius: Metrics.radius("full")

                                readonly property bool selected: launcher.categoryIndex === index

                                color: selected
                                    ? Appearance.colors.colSecondaryContainer
                                    : chipMa.containsMouse
                                        ? Appearance.colors.colLayer2Hover
                                        : Appearance.colors.colLayer2

                                Behavior on color { ColorAnimation { duration: 160 } }

                                RowLayout {
                                    id: chipRow
                                    anchors.centerIn: parent
                                    spacing: 5

                                    MaterialSymbol {
                                        icon:      modelData.icon
                                        iconSize:  Metrics.iconSize(15)
                                        color:     chipRect.selected
                                            ? Appearance.colors.colOnSecondaryContainer
                                            : Appearance.colors.colOnLayer1
                                        Behavior on color { ColorAnimation { duration: 160 } }
                                    }

                                    StyledText {
                                        text:           modelData.label
                                        font.pixelSize: Metrics.fontSize("smaller")
                                        font.weight:    chipRect.selected ? Font.Medium : Font.Normal
                                        color:          chipRect.selected
                                            ? Appearance.colors.colOnSecondaryContainer
                                            : Appearance.colors.colOnLayer1
                                        Behavior on color { ColorAnimation { duration: 160 } }
                                    }
                                }

                                MouseArea {
                                    id: chipMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: launcher.categoryIndex = index
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    anchors.centerIn: parent
                    spacing: Appearance.margin.small
                    visible: launcher.displayApps.length === 0 && !launcher.searchAction
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    MaterialSymbol {
                        anchors.horizontalCenter: parent.horizontalCenter
                        icon: "search_off"
                        iconSize: Metrics.iconSize(52)
                        color: Appearance.colors.colSubtext
                        opacity: 0.5
                    }

                    StyledText {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No applications found"
                        font.pixelSize: Metrics.fontSize("normal")
                        color: Appearance.colors.colSubtext
                        opacity: 0.6
                    }
                }

                // ── Search / Calc action card ─────────────────────
                Item {
                    anchors.fill: parent
                    visible: launcher.searchAction !== null
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 180 } }

                    Rectangle {
                        id: actionCard
                        anchors.top:              parent.top
                        anchors.left:             parent.left
                        anchors.right:            parent.right
                        anchors.topMargin:        Appearance.margin.small
                        height: 72
                        radius: Metrics.radius("large")
                        color:  actionCardMa.containsMouse
                            ? Appearance.colors.colLayer2Hover
                            : Appearance.colors.colLayer2
                        Behavior on color { ColorAnimation { duration: 120 } }

                        scale: actionCardMa.pressed ? 0.985 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: actionCardMa.pressed ? 80 : 200
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Appearance.animation.curves.expressiveFastSpatial
                            }
                        }

                        RowLayout {
                            anchors {
                                fill:        parent
                                leftMargin:  Appearance.margin.normal
                                rightMargin: Appearance.margin.normal
                            }
                            spacing: Appearance.margin.normal

                            // Leading icon pill
                            Rectangle {
                                width: 44; height: 44
                                radius: Metrics.radius("normal")
                                color: launcher.searchAction?.type === "calc"
                                    ? Qt.rgba(Appearance.colors.colPrimary.r,
                                              Appearance.colors.colPrimary.g,
                                              Appearance.colors.colPrimary.b, 0.15)
                                    : Qt.rgba(Appearance.m3colors.m3tertiary.r,
                                              Appearance.m3colors.m3tertiary.g,
                                              Appearance.m3colors.m3tertiary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    icon: launcher.searchAction?.type === "calc"
                                        ? "calculate"
                                        : "travel_explore"
                                    iconSize: Metrics.iconSize(24)
                                    color: launcher.searchAction?.type === "calc"
                                        ? Appearance.colors.colPrimary
                                        : Appearance.m3colors.m3tertiary
                                }
                            }

                            // Labels
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: Appearance.margin.tinier

                                StyledText {
                                    text: {
                                        const a = launcher.searchAction
                                        if (!a) return ""
                                        if (a.type === "calc")
                                            return a.expr + " = " + a.result
                                        return a.query
                                    }
                                    font.pixelSize: Metrics.fontSize("normal")
                                    font.weight:    Font.Medium
                                    color: Appearance.colors.colOnLayer2
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                StyledText {
                                    text: {
                                        const a = launcher.searchAction
                                        if (!a) return ""
                                        if (a.type === "calc")
                                            return "Press Enter to copy result"
                                        return "Search with " + a.engineLabel
                                    }
                                    font.pixelSize: Metrics.fontSize("smaller")
                                    color: Appearance.colors.colSubtext
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Engine switcher chips (web only)
                            Row {
                                spacing: Appearance.margin.tiny
                                Layout.alignment: Qt.AlignVCenter
                                visible: launcher.searchAction?.type === "web"

                                Repeater {
                                    model: ["google", "brave", "duckduckgo", "bing"]

                                    delegate: Rectangle {
                                        required property string modelData
                                        required property int    index

                                        readonly property bool active:
                                            launcher._engineKey === modelData

                                        height: 28
                                        width:  engineLabel.implicitWidth + 16
                                        radius: Metrics.radius("full")
                                        color: active
                                            ? Appearance.m3colors.m3tertiaryContainer
                                            : engineMa.containsMouse
                                                ? Appearance.colors.colLayer1Active
                                                : Appearance.colors.colLayer1
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        StyledText {
                                            id: engineLabel
                                            anchors.centerIn: parent
                                            text: launcher._searchEngines[modelData].label
                                            font.pixelSize: Metrics.fontSize("smaller")
                                            font.weight: parent.active ? Font.Medium : Font.Normal
                                            color: parent.active
                                                ? Appearance.m3colors.m3onTertiaryContainer
                                                : Appearance.colors.colOnLayer1
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }

                                        MouseArea {
                                            id: engineMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape:  Qt.PointingHandCursor
                                            onClicked: {
                                                Config.updateKey(
                                                    "launcher.webSearchEngine",
                                                    modelData)
                                            }
                                        }
                                    }
                                }
                            }

                            MaterialSymbol {
                                icon: launcher.searchAction?.type === "calc"
                                    ? "content_copy"
                                    : "open_in_new"
                                iconSize: Metrics.iconSize(18)
                                color:    Appearance.colors.colSubtext
                                opacity:  actionCardMa.containsMouse ? 1 : 0.5
                                Layout.alignment: Qt.AlignVCenter
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                        }

                        MouseArea {
                            id: actionCardMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    launcher._runSearchAction()
                        }
                    }

                    // App results below the action card (web search with results)
                    GridView {
                        anchors.top:    actionCard.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: Appearance.margin.small
                        clip: true
                        visible: launcher.layout === "grid"
                                 && launcher.displayApps.length > 0
                                 && launcher.searchAction !== null

                        readonly property int cols: Math.max(3, Math.floor(width / 128))
                        cellWidth:  Math.floor(width / cols)
                        cellHeight: 118
                        model: visible ? launcher.displayApps : []

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle {
                                radius:  Metrics.radius("full")
                                color:   Appearance.colors.colOutline
                                opacity: 0.45
                            }
                        }

                        delegate: Item {
                            required property int index
                            required property var modelData
                            width:  parent.cellWidth
                            height: parent.cellHeight

                            Rectangle {
                                anchors { fill: parent; margins: 5 }
                                radius: Metrics.radius("large")
                                color: overflowMa.containsMouse
                                    ? Appearance.colors.colLayer2Hover : "transparent"
                                Behavior on color { ColorAnimation { duration: 130 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Appearance.margin.verysmall
                                    width: parent.width - 12

                                    Item {
                                        width: 48; height: 48
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: Metrics.radius("normal")
                                            color: Qt.rgba(Appearance.colors.colPrimary.r,
                                                           Appearance.colors.colPrimary.g,
                                                           Appearance.colors.colPrimary.b, 0.13)
                                            visible: !overflowIcon.visible
                                        }
                                        StyledText {
                                            anchors.centerIn: parent
                                            text: modelData.name.charAt(0).toUpperCase()
                                            font.family:    Appearance.font.family.title
                                            font.pixelSize: Metrics.fontSize("big")
                                            font.weight:    Font.Bold
                                            color:   Appearance.colors.colPrimary
                                            visible: !overflowIcon.visible
                                        }
                                        Image {
                                            id: overflowIcon
                                            anchors.fill: parent
                                            source: AppRegistry.iconForDesktopIcon(modelData.icon) || ""
                                            fillMode: Image.PreserveAspectFit
                                            visible:  status === Image.Ready
                                            smooth: true; mipmap: true; asynchronous: true
                                        }
                                    }
                                    StyledText {
                                        width: parent.width
                                        text:  modelData.name
                                        font.pixelSize: Metrics.fontSize("smaller")
                                        color: Appearance.colors.colOnLayer1
                                        horizontalAlignment: Text.AlignHCenter
                                        elide:    Text.ElideRight
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                    }
                                }
                                MouseArea {
                                    id: overflowMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: {
                                        Apps.launch(modelData)
                                        Globals.visiblility.launcher = false
                                    }
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: appGrid
                    anchors.fill: parent
                    clip: true
                    focus: true
                    visible: launcher.layout === "grid" && launcher.searchAction === null
                    enabled: visible

                    readonly property int cols: Math.max(3, Math.floor(width / 128))
                    cellWidth:  Math.floor(width / cols)
                    cellHeight: 118

                    model: visible ? launcher.displayApps : []

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            radius:  Metrics.radius("full")
                            color:   Appearance.colors.colOutline
                            opacity: 0.45
                        }
                    }

                    Keys.onReturnPressed: {
                        const idx = currentIndex
                        if (idx >= 0 && idx < launcher.displayApps.length) {
                            Apps.launch(launcher.displayApps[idx])
                            Globals.visiblility.launcher = false
                        }
                    }
                    Keys.onEscapePressed: searchField.forceActiveFocus()

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"; from: 0; to: 1
                            duration: 200
                        }
                        NumberAnimation {
                            property: "scale"; from: 0.82; to: 1
                            duration: 260
                            easing.type: Easing.OutBack
                        }
                    }
                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration:   220
                            easing.type: Easing.OutCubic
                        }
                    }

                    delegate: Item {
                        id: appDelegate
                        required property int index
                        required property var modelData

                        width:  appGrid.cellWidth
                        height: appGrid.cellHeight

                        property real entranceP: 0
                        NumberAnimation on entranceP {
                            from: 0; to: 1
                            duration: 340
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.animation.curves.emphasizedDecel
                            running: launcher.visible && launcher.layout === "grid"
                        }

                        opacity: entranceP
                        scale:   0.78 + 0.22 * entranceP

                        Rectangle {
                            id: appCard
                            anchors { fill: parent; margins: 5 }
                            radius: Metrics.radius("large")
                            color: {
                                if (appGrid.currentIndex === appDelegate.index)
                                    return Appearance.colors.colSecondaryContainer
                                if (appHoverMa.containsMouse)
                                    return Appearance.colors.colLayer2Hover
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: 130 } }

                            scale: appHoverMa.pressed
                                ? 0.92
                                : appHoverMa.containsMouse ? 1.04 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: appHoverMa.pressed ? 90 : 280
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Appearance.animation.curves.expressiveFastSpatial
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: Appearance.margin.verysmall
                                width: parent.width - 12

                                Item {
                                    width: 48; height: 48
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Metrics.radius("normal")
                                        color: Qt.rgba(
                                            Appearance.colors.colPrimary.r,
                                            Appearance.colors.colPrimary.g,
                                            Appearance.colors.colPrimary.b, 0.13)
                                        visible: !appIcon.visible
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: appDelegate.modelData.name.charAt(0).toUpperCase()
                                        font.family:    Appearance.font.family.title
                                        font.pixelSize: Metrics.fontSize("big")
                                        font.weight:    Font.Bold
                                        color: Appearance.colors.colPrimary
                                        visible: !appIcon.visible
                                    }

                                    Image {
                                        id: appIcon
                                        anchors.fill: parent
                                        source: AppRegistry.iconForDesktopIcon(
                                            appDelegate.modelData.icon) || ""
                                        fillMode: Image.PreserveAspectFit
                                        visible: status === Image.Ready
                                        smooth: true; mipmap: true; asynchronous: true
                                    }
                                }

                                StyledText {
                                    width: parent.width
                                    text: appDelegate.modelData.name
                                    font.pixelSize: Metrics.fontSize("smaller")
                                    font.weight: appGrid.currentIndex === appDelegate.index
                                        ? Font.Medium : Font.Normal
                                    color: appGrid.currentIndex === appDelegate.index
                                        ? Appearance.colors.colOnSecondaryContainer
                                        : Appearance.colors.colOnLayer1
                                    horizontalAlignment: Text.AlignHCenter
                                    elide:    Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    Behavior on color { ColorAnimation { duration: 130 } }
                                }
                            }

                            MouseArea {
                                id: appHoverMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onEntered: appGrid.currentIndex = appDelegate.index
                                onClicked: {
                                    console.log("TYPE:", typeof appDelegate.modelData)
                                    console.log("EXEC:", appDelegate.modelData.execString)
                                    console.log("ID:", appDelegate.modelData.id)
                                    Apps.launch(appDelegate.modelData)
                                    Globals.visiblility.launcher = false
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: appList
                    anchors.fill: parent
                    clip: true
                    focus: true
                    visible: launcher.layout === "list" && launcher.searchAction === null
                    enabled: visible
                    spacing: Appearance.margin.tinier
                    boundsBehavior: Flickable.StopAtBounds

                    model: visible ? launcher.displayApps : []

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            radius:  Metrics.radius("full")
                            color:   Appearance.colors.colOutline
                            opacity: 0.45
                        }
                    }

                    Keys.onReturnPressed: {
                        const idx = currentIndex
                        if (idx >= 0 && idx < launcher.displayApps.length) {
                            Apps.launch(launcher.displayApps[idx])
                            Globals.visiblility.launcher = false
                        }
                    }
                    Keys.onEscapePressed: searchField.forceActiveFocus()

                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
                        NumberAnimation { property: "scale"; from: 0.96; to: 1; duration: 220; easing.type: Easing.OutCubic }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
                    }

                    delegate: Item {
                        id: listDelegate
                        required property int index
                        required property var modelData

                        width: appList.width
                        height: 64

                        property real entranceP: 0
                        NumberAnimation on entranceP {
                            from: 0; to: 1
                            duration: 280
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Appearance.animation.curves.emphasizedDecel
                            running: launcher.visible && launcher.layout === "list"
                        }
                        opacity: entranceP

                        Rectangle {
                            id: listCard
                            anchors { fill: parent; leftMargin: 2; rightMargin: 2; topMargin: 1; bottomMargin: 1 }
                            radius: Metrics.radius("large")
                            color: {
                                if (appList.currentIndex === listDelegate.index)
                                    return Appearance.colors.colSecondaryContainer
                                if (listHoverMa.containsMouse)
                                    return Appearance.colors.colLayer2Hover
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: 120 } }

                            scale: listHoverMa.pressed ? 0.98 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: listHoverMa.pressed ? 80 : 220
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Appearance.animation.curves.expressiveFastSpatial
                                }
                            }

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin:  Appearance.margin.normal
                                    rightMargin: Appearance.margin.normal
                                }
                                spacing: Appearance.margin.normal

                                Item {
                                    width: 40; height: 40
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Metrics.radius("normal")
                                        color: Qt.rgba(
                                            Appearance.colors.colPrimary.r,
                                            Appearance.colors.colPrimary.g,
                                            Appearance.colors.colPrimary.b, 0.13)
                                        visible: !listIcon.visible
                                    }
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: listDelegate.modelData.name.charAt(0).toUpperCase()
                                        font.family:    Appearance.font.family.title
                                        font.pixelSize: Metrics.fontSize("large")
                                        font.weight:    Font.Bold
                                        color:   Appearance.colors.colPrimary
                                        visible: !listIcon.visible
                                    }
                                    Image {
                                        id: listIcon
                                        anchors.fill: parent
                                        source: AppRegistry.iconForDesktopIcon(
                                            listDelegate.modelData.icon) || ""
                                        fillMode:    Image.PreserveAspectFit
                                        visible:     status === Image.Ready
                                        smooth:      true
                                        mipmap:      true
                                        asynchronous: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: Appearance.margin.tinier

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: listDelegate.modelData.name
                                        font.pixelSize: Metrics.fontSize("small")
                                        font.weight: appList.currentIndex === listDelegate.index
                                            ? Font.Medium : Font.Normal
                                        color: appList.currentIndex === listDelegate.index
                                            ? Appearance.colors.colOnSecondaryContainer
                                            : Appearance.colors.colOnLayer1
                                        elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: listDelegate.modelData.comment ?? ""
                                        visible: (listDelegate.modelData.comment ?? "").length > 0
                                        font.pixelSize: Metrics.fontSize("smaller")
                                        color: appList.currentIndex === listDelegate.index
                                            ? Qt.rgba(
                                                Appearance.colors.colOnSecondaryContainer.r,
                                                Appearance.colors.colOnSecondaryContainer.g,
                                                Appearance.colors.colOnSecondaryContainer.b, 0.75)
                                            : Appearance.colors.colSubtext
                                        elide: Text.ElideRight
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }
                                }

                                MaterialSymbol {
                                    icon: "chevron_right"
                                    iconSize: Metrics.iconSize(18)
                                    color: appList.currentIndex === listDelegate.index
                                        ? Appearance.colors.colOnSecondaryContainer
                                        : Appearance.colors.colSubtext
                                    opacity: listHoverMa.containsMouse
                                          || appList.currentIndex === listDelegate.index ? 1 : 0
                                    Layout.alignment: Qt.AlignVCenter
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    Behavior on color   { ColorAnimation  { duration: 120 } }
                                }
                            }

                            MouseArea {
                                id: listHoverMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onEntered: appList.currentIndex = listDelegate.index
                                onClicked: {
                                    Apps.launch(listDelegate.modelData)
                                    Globals.visiblility.launcher = false
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.margin.small

                StyledText {
                    text: launcher.displayApps.length + " apps"
                    font.pixelSize: Metrics.fontSize("smallest")
                    color: Appearance.colors.colSubtext
                    opacity: 0.55
                }

                Item { Layout.fillWidth: true }

                Repeater {
                    model: [
                        { icon: "keyboard_return", label: "Launch" },
                        { icon: "keyboard_tab",    label: "Navigate" },
                        { icon: "backspace",       label: "Close" },
                    ]

                    RowLayout {
                        required property var modelData
                        spacing: 4

                        Rectangle {
                            height: 20
                            width:  hintSymbol.implicitWidth + 10
                            radius: 4
                            color:  Appearance.colors.colLayer2

                            MaterialSymbol {
                                id: hintSymbol
                                anchors.centerIn: parent
                                icon:     parent.parent.modelData.icon
                                iconSize: Metrics.iconSize(12)
                                color:    Appearance.colors.colSubtext
                            }
                        }

                        StyledText {
                            text:           parent.modelData.label
                            font.pixelSize: Metrics.fontSize("smallest")
                            color: Appearance.colors.colSubtext
                            opacity: 0.5
                        }
                    }
                }
            }
        }
    }
    
}
