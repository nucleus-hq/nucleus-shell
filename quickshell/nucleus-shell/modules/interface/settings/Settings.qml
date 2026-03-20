import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.modules.functions
import qs.modules.components
import qs.services

Scope {
    property var settingsWindow: null

    IpcHandler {
        function open(menu: string) {
            Globals.states.settingsOpen = true;

            if (menu !== "" && settingsWindow !== null) {
                for (var i = 0; i < settingsWindow.menuModel.length; i++) {
                    var item = settingsWindow.menuModel[i];
                    if (!item.header && item.label.toLowerCase() === menu.toLowerCase()) {
                        settingsWindow.selectedIndex = item.page;
                        break;
                    }
                }
            }
        }
        target: "settings"
    }

    LazyLoader {
        active: Globals.states.settingsOpen

        Window {
            id: root
            width: 1280
            height: 720
            visible: true
            title: "Nucleus - Settings"
            color: Appearance.m3colors.m3background
            onClosing: Globals.states.settingsOpen = false
            Component.onCompleted: settingsWindow = root

            property int selectedIndex: 0
            property bool sidebarCollapsed: false

            property var menuModel: [
                { "header": true, "label": "System" },
                { "icon": "bluetooth", "label": "Bluetooth", "page": 0 },
                { "icon": "network_wifi", "label": "Network", "page": 1 },
                { "icon": "volume_up", "label": "Audio", "page": 2 },
                { "icon": "palette", "label": "Appearance", "page": 3 },

                { "header": true, "label": "Customization" },
                { "icon": "toolbar", "label": "Bar", "page": 4 },
                { "icon": "dock_to_bottom", "label": "Dock", "page": 5 },
                { "icon": "wallpaper", "label": "Wallpapers", "page": 6 },
                { "icon": "apps", "label": "Launcher", "page": 7 },
                { "icon": "notifications", "label": "Notifications", "page": 8 },
                { "icon": "extension", "label": "Plugins", "page": 9 },
                { "icon": "store", "label": "Store", "page": 10 },
                { "icon": "build", "label": "Miscellaneous", "page": 11 },

                { "header": true, "label": "About" },
                { "icon": "info", "label": "About", "page": 12 }
            ]

            Item {
                anchors.fill: parent
                Rectangle {
                    id: sidebarBG
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: root.sidebarCollapsed ? 80 : 350
                    color: Appearance.m3colors.m3surfaceContainerLow

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.sidebarCollapsed ? 0 : Metrics.margin(40)
                        anchors.rightMargin: root.sidebarCollapsed ? 0 : Metrics.margin(40)
                        anchors.topMargin: Metrics.margin(40)
                        anchors.bottomMargin: Metrics.margin(40)
                        spacing: Metrics.spacing(5)

                        RowLayout {
                            Layout.fillWidth: true

                            StyledText {
                                Layout.fillWidth: true
                                text: "Settings"
                                font.family: "Outfit ExtraBold"
                                font.pixelSize: Metrics.fontSize(28)
                                visible: !root.sidebarCollapsed
                            }

                            StyledButton {
                                Layout.preferredHeight: 40
                                Layout.preferredWidth: 40
                                Layout.leftMargin: root.sidebarCollapsed ? 20 : 0
                                icon: root.sidebarCollapsed ? "left_panel_open" : "left_panel_close"
                                secondary: true
                                onClicked: root.sidebarCollapsed = !root.sidebarCollapsed
                            }
                        }

                        ListView {
                            id: sidebarList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter
                            model: root.menuModel
                            spacing: Metrics.spacing(5)
                            clip: true

                            delegate: Item {
                                width: root.sidebarCollapsed ? 64 : sidebarList.width
                                anchors.horizontalCenter: root.sidebarCollapsed ? parent.horizontalCenter : undefined
                                height: modelData.header ? (root.sidebarCollapsed ? 0 : 30) : 42
                                visible: !modelData.header || !root.sidebarCollapsed

                                // header
                                Item {
                                    width: parent.width
                                    height: parent.height

                                    StyledText {
                                        y: (parent.height - height) * 0.5
                                        x: 10
                                        text: modelData.label
                                        font.pixelSize: Metrics.fontSize(14)
                                        font.bold: true
                                        opacity: modelData.header ? 1 : 0
                                    }

                                }

                                Rectangle {
                                    width: root.sidebarCollapsed ? 40 : parent.width
                                    height: parent.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: !modelData.header
                                    radius: Appearance.rounding.large
                                    color: root.selectedIndex === modelData.page
                                           ? Appearance.m3colors.m3primary
                                           : "transparent"

                                    RowLayout {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: Metrics.margin(10)
                                        spacing: Metrics.spacing(10)
                                        visible: !root.sidebarCollapsed

                                        MaterialSymbol {
                                            icon: modelData.icon ? modelData.icon : ""
                                            iconSize: Metrics.iconSize(24)
                                        }

                                        StyledText {
                                            text: modelData.label
                                        }
                                    }

                                    // Collapsed layout (center icon)
                                    MaterialSymbol {
                                        visible: root.sidebarCollapsed
                                        anchors.centerIn: parent
                                        icon: modelData.icon ? modelData.icon : ""
                                        iconSize: Metrics.iconSize(24)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.page !== undefined
                                    onClicked: {
                                        root.selectedIndex = modelData.page
                                        settingsStack.currentIndex = modelData.page
                                    }
                                }
                            }
                        }
                    }

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.InOutCubic }
                    }
                }


                StackLayout {
                    id: settingsStack
                    anchors.left: sidebarBG.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    currentIndex: root.selectedIndex

                    BluetoothConfig    { Layout.fillWidth: true; Layout.fillHeight: true }
                    NetworkConfig      { Layout.fillWidth: true; Layout.fillHeight: true }
                    AudioConfig        { Layout.fillWidth: true; Layout.fillHeight: true }
                    AppearanceConfig   { Layout.fillWidth: true; Layout.fillHeight: true }
                    BarConfig          { Layout.fillWidth: true; Layout.fillHeight: true }
                    DockConfig         { Layout.fillWidth: true; Layout.fillHeight: true }
                    WallpaperConfig    { Layout.fillWidth: true; Layout.fillHeight: true }
                    LauncherConfig     { Layout.fillWidth: true; Layout.fillHeight: true }
                    NotificationConfig { Layout.fillWidth: true; Layout.fillHeight: true }
                    Plugins            { Layout.fillWidth: true; Layout.fillHeight: true }
                    Store              { Layout.fillWidth: true; Layout.fillHeight: true }
                    MiscConfig         { Layout.fillWidth: true; Layout.fillHeight: true }
                    About              { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }
        }
    }
}