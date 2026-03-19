import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

/* 

This LauncherContent has been depricated.
And yet not used. (4/3/26)

*/

Item {
    id: content

    property int selectedIndex: -1
    property string searchQuery: ""
    property var calcVars: ({})

    property alias listView: listView
    property alias filteredModel: filteredModel

    function launchCurrent() {
        launchApp(listView.currentIndex)
    }

    function webSearchUrl(query) {
        const engine = (Config.runtime.launcher.webSearchEngine || "").toLowerCase()
        if (engine.startsWith("http"))
            return engine.replace("%s", encodeURIComponent(query))

        const engines = {
            "google": "https://www.google.com/search?q=%s",
            "duckduckgo": "https://duckduckgo.com/?q=%s",
            "brave": "https://search.brave.com/search?q=%s",
            "bing": "https://www.bing.com/search?q=%s",
            "startpage": "https://www.startpage.com/search?q=%s"
        }
        const template = engines[engine] || engines["duckduckgo"]
        return template.replace("%s", encodeURIComponent(query))
    }

    function moveSelection(delta) {
        if (filteredModel.count === 0) return

        selectedIndex = Math.max(0, Math.min(selectedIndex + delta, filteredModel.count - 1))
        listView.currentIndex = selectedIndex
        listView.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function fuzzyMatch(text, pattern) {
        text = text.toLowerCase()
        pattern = pattern.toLowerCase()
        let ti = 0, pi = 0
        while (ti < text.length && pi < pattern.length) {
            if (text[ti] === pattern[pi]) pi++
            ti++
        }
        return pi === pattern.length
    }

    function evalExpression(expr) {
        try {
            const fn = new Function("vars", `
                with (vars) { with (Math) { return (${expr}); } }
            `)
            const res = fn(calcVars)
            if (res === undefined || Number.isNaN(res)) return null
            return res
        } catch (e) {
            return null
        }
    }

    function updateFilter() {
        filteredModel.clear()
        const query = searchQuery.toLowerCase().trim()

        const calcVal = evalExpression(query)
        if (calcVal !== null && query !== "") {
            filteredModel.append({
                name: String(calcVal),
                displayName: String(calcVal),
                comment: "Calculation",
                icon: "",
                exec: "",
                isCalc: true,
                isWeb: false
            })
        }

        const sourceApps = AppRegistry.apps

        if (query === "") {
            for (let app of sourceApps) {
                filteredModel.append({
                    name: app.name,
                    displayName: app.name,
                    comment: app.comment,
                    icon: AppRegistry.iconForDesktopIcon(app.icon),
                    exec: app.exec,
                    isCalc: false,
                    isWeb: false
                })
            }
            selectedIndex = filteredModel.count > 0 ? 0 : -1
            listView.currentIndex = selectedIndex
            return
        }

        let exactMatches = []
        let startsWithMatches = []
        let containsMatches = []
        let fuzzyMatches = []

        for (let app of sourceApps) {
            const name = app.name ? app.name.toLowerCase() : ""
            const comment = app.comment ? app.comment.toLowerCase() : ""

            if (name === query) exactMatches.push(app)
            else if (name.startsWith(query)) startsWithMatches.push(app)
            else if (name.includes(query) || comment.includes(query)) containsMatches.push(app)
            else if (Config.runtime.launcher.fuzzySearchEnabled && fuzzyMatch(name, query)) fuzzyMatches.push(app)
        }

        const sortedResults = [
            ...exactMatches,
            ...startsWithMatches,
            ...containsMatches,
            ...fuzzyMatches
        ]

        for (let app of sortedResults) {
            filteredModel.append({
                name: app.name,
                displayName: app.name,
                comment: app.comment,
                icon: AppRegistry.iconForDesktopIcon(app.icon),
                exec: app.exec,
                isCalc: false,
                isWeb: false
            })
        }

        if (filteredModel.count === 0 && query !== "") {
            filteredModel.append({
                name: query,
                displayName: "Search the web for \"" + query + "\"",
                comment: "Web search",
                icon: "public",
                exec: webSearchUrl(query),
                isCalc: false,
                isWeb: true
            })
        }

        selectedIndex = filteredModel.count > 0 ? 0 : -1
        listView.currentIndex = selectedIndex
        listView.positionViewAtBeginning()
    }

    function launchApp(idx) {
        if (idx < 0 || idx >= filteredModel.count) return

        const app = filteredModel.get(idx)
        if (app.isCalc) return
        if (app.isWeb)
            Quickshell.execDetached(["xdg-open", app.exec])
        else
            Quickshell.execDetached(["bash", "-c", app.exec + " &"])

        closeLauncher()
    }

    function closeLauncher() {
        Globals.visiblility.launcher = false
    }

    function resetSearch() {
        searchQuery = ""
        updateFilter()
        selectedIndex = -1
        listView.currentIndex = -1
    }

    Connections {
        target: AppRegistry
        function onReady() {
            updateFilter()
        }
    }

    anchors.fill: parent
    opacity: Globals.visiblility.launcher ? 1 : 0
    anchors.margins: Metrics.margin(10)

    ListModel { id: filteredModel }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.margin(16)
        spacing: Metrics.spacing(12)

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                model: filteredModel
                spacing: Metrics.spacing(8)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                highlightMoveDuration: 120
                currentIndex: selectedIndex

                delegate: Rectangle {
                    property bool isSelected: listView.currentIndex === index

                    width: listView.width
                    height: 60
                    radius: Appearance.rounding.normal
                    color: isSelected ? Appearance.m3colors.m3surfaceContainerHighest : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.margins: Metrics.margin(10)
                        spacing: Metrics.spacing(12)

                        Item {
                            width: 32
                            height: 32

                            Image {
                                anchors.fill: parent
                                visible: !model.isCalc && !model.isWeb
                                smooth: true
                                mipmap: true
                                antialiasing: true
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: 128
                                sourceSize.height: 128
                                source: model.icon
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                visible: model.isCalc
                                icon: "calculate"
                                iconSize: Metrics.iconSize(28)
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                visible: model.isWeb
                                icon: "public"
                                iconSize: Metrics.iconSize(28)
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: listView.width - 120
                            spacing: Metrics.spacing(4)

                            Text {
                                text: model.displayName
                                font.pixelSize: Metrics.fontSize(14)
                                font.bold: true
                                elide: Text.ElideRight
                                color: Appearance.m3colors.m3onSurface
                            }

                            Text {
                                text: model.comment
                                font.pixelSize: Metrics.fontSize(11)
                                elide: Text.ElideRight
                                color: Appearance.m3colors.m3onSurfaceVariant
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launchApp(index)
                        onEntered: listView.currentIndex = index
                    }
                }
            }
        }
    }

    Behavior on opacity {
        enabled: Config.runtime.appearance.animations.enabled
        NumberAnimation {
            duration: Metrics.chronoDuration(400)
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animation.curves.standard
        }
    }
}