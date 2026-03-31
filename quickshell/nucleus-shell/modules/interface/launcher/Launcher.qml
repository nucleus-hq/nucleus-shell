import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

import qs.modules.components
import qs.modules.functions
import qs.config
import qs.services

PanelWindow {
    id: launcherWindow

    readonly property bool launcherOpen: Globals.visiblility.launcher

    visible: launcherOpen
    focusable: true
    aboveWindows: true // btw I never knew this was a property (read docs)
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore // why this? idk but it works atleast
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    ScrollView {
        id: maskId

        implicitHeight: DisplayMetrics.scaledHeight(0.623)
        implicitWidth: DisplayMetrics.scaledWidth(0.3)

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: (parent.width / 2) - (implicitWidth / 2)
        anchors.topMargin: (parent.height / 2) - (implicitHeight / 2)

        clip: true
        focus: true

        Rectangle {
            id: launcher
            property string currentSearch: ""
            property int entryIndex: 0
            property list<DesktopEntry> appList: Apps.list

            Connections {
                target: launcherWindow
                function onLauncherOpenChanged() {
                    if (!launcherWindow.launcherOpen) {
                        launcher.currentSearch = ""
                        launcher.entryIndex = 0
                        launcher.appList = Apps.list
                    }
                }
            }

            anchors.fill: parent
            color: Appearance.m3colors.m3surface
            radius: Metrics.radius(21)

            StyledRect {
                id: searchBox
                anchors.top: parent.top
                anchors.topMargin: Metrics.margin(10)

                color: Appearance.m3colors.m3surfaceContainerLow
                width: parent.width - 20
                anchors.left: parent.left
                anchors.leftMargin: (parent.width / 2) - (width / 2)
                height: 45
                radius: Metrics.radius(15)
                z: 2

                focus: true

                Keys.onDownPressed: launcher.entryIndex += 1
                Keys.onUpPressed: {
                    if (launcher.entryIndex != 0)
                        launcher.entryIndex -= 1
                }
                Keys.onEscapePressed: Globals.visiblility.launcher = false

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        launcher.appList[launcher.entryIndex].execute()
                        Globals.visiblility.launcher = false
                    } else if (event.key === Qt.Key_Backspace) {
                        launcher.currentSearch = launcher.currentSearch.slice(0, -1)
                    } else if (" abcdefghijklmnopqrstuvwxyz1234567890`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?".includes(event.text.toLowerCase())) {
                        launcher.currentSearch += event.text
                    }

                    launcher.appList = Apps.fuzzyQuery(launcher.currentSearch)
                    launcher.entryIndex = 0
                }

                MaterialSymbol {
                    id: iconText
                    anchors.left: parent.left
                    anchors.leftMargin: Metrics.margin(10)
                    icon: "search"
                    font.pixelSize: Metrics.fontSize(14)
                    font.weight: 600
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height / 2) - ((font.pixelSize + 5) / 2)
                    opacity: 0.8
                }

                StyledText {
                    id: placeHolderText
                    anchors.left: iconText.right
                    anchors.leftMargin: Metrics.margin(10)
                    color: (launcher.currentSearch != "") ? Appearance.m3colors.m3onSurface : Appearance.colors.colOutline
                    text: (launcher.currentSearch != "") ? launcher.currentSearch : "Start typing to search ..."
                    font.pixelSize: Metrics.fontSize(13)
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height / 2) - ((font.pixelSize + 5) / 2)
                    animate: false
                    opacity: 0.8
                }
            }

            ScrollView {
                anchors.top: searchBox.bottom
                anchors.topMargin: Metrics.margin(10)

                anchors.left: parent.left
                anchors.leftMargin: (parent.width / 2) - (width / 2)
                width: parent.width - 20
                height: parent.height - searchBox.height - 20

                ListView {
                    id: appList
                    anchors.fill: parent
                    spacing: Metrics.spacing(10)
					anchors.bottomMargin: Metrics.margin(4)

                    model: launcher.appList
                    currentIndex: launcher.entryIndex

                    delegate: AppItem {
                        required property int index
                        required property DesktopEntry modelData
                        selected: index === launcher.entryIndex
                        parentWidth: appList.width
                    }
                }
            }
        }
    }
    
}