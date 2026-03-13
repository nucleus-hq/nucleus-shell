import QtQuick
import QtQuick.Layouts
import Quickshell
import "content/"
import qs.config
import qs.services
import qs.modules.components

Item {
    id: root

    property string displayName: screen?.name ?? ""
    property var barConfig: ConfigResolver.bar(displayName)

    property bool isHorizontal:
        barConfig.position === "top" || barConfig.position === "bottom"

    property real sideMargin: barConfig.density * 0.3
    property real vMargin: barConfig.density * 0.1

    function toggleSidebar(v) { Globals.visiblility.sidebarLeft = v }
    function togglePower(v) { Globals.visiblility.powermenu = v }

    Row {
        id: hCenterRow
        visible: isHorizontal
        anchors.centerIn: parent
        spacing: Metrics.spacing(4)

        SystemUsageModule {}
        MediaPlayerModule {}
        ActiveWindowModule {}
        ClockModule {}
        BatteryIndicatorModule {}
    }

    RowLayout {
        id: hLeftRow
        visible: isHorizontal

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: sideMargin

        spacing: Metrics.spacing(4)

        ToggleModule {
            icon: "menu"
            iconSize: Metrics.iconSize(22)
            iconColor: Appearance.m3colors.m3error
            toggle: Globals.visiblility.sidebarLeft
            onToggled: root.toggleSidebar(value)
        }

        WorkspaceModule {}
    }

    RowLayout {
        id: hRightRow
        visible: isHorizontal

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: sideMargin

        spacing: Metrics.spacing(4)

        SystemTray { id: sysTray }

        StyledText {
            id: separator
            visible: sysTray.items.count > 0 && barConfig.modules.statusIcons.enabled
            Layout.alignment: Qt.AlignLeft
            font.pixelSize: Metrics.fontSize("hugeass")
            text: "·"
        }

        StatusIconsModule {}

        StyledText {
            id: separator2
            Layout.alignment: Qt.AlignLeft
            font.pixelSize: Metrics.fontSize("hugeass")
            text: "·"
        }

        ToggleModule {
            icon: "power_settings_new"
            iconSize: Metrics.iconSize(22)
            iconColor: Appearance.m3colors.m3error
            toggle: Globals.visiblility.powermenu
            onToggled: root.togglePower(value)
        }
    }

    Item {
        visible: !isHorizontal

        anchors.top: parent.top
        anchors.topMargin: vMargin
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: vRow.implicitHeight
        implicitHeight: vRow.implicitWidth

        Row {
            id: vRow
            anchors.centerIn: parent
            spacing: Metrics.spacing(8)
            rotation: 90

            ToggleModule {
                icon: "menu"
                iconSize: Metrics.iconSize(22)
                iconColor: Appearance.m3colors.m3error
                toggle: Globals.visiblility.sidebarLeft
                rotation: 270
                onToggled: root.toggleSidebar(value)
            }

            SystemUsageModule {}
            MediaPlayerModule {}

            SystemTray { rotation: 0 }
        }
    }

    Item {
        visible: !isHorizontal

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 35

        implicitWidth: centerRow.implicitHeight
        implicitHeight: centerRow.implicitWidth

        Row {
            id: centerRow
            anchors.centerIn: parent

            WorkspaceModule { rotation: 90 }
        }
    }

    Item {
        visible: !isHorizontal

        anchors.bottom: parent.bottom
        anchors.bottomMargin: vMargin
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: row.implicitHeight
        implicitHeight: row.implicitWidth

        Row {
            id: row
            anchors.centerIn: parent
            spacing: Metrics.spacing(6)
            rotation: 90

            ClockModule { rotation: 270 }
            StatusIconsModule {}
            BatteryIndicatorModule {}

            ToggleModule {
                icon: "power_settings_new"
                iconSize: Metrics.iconSize(22)
                iconColor: Appearance.m3colors.m3error
                toggle: Globals.visiblility.powermenu
                rotation: 270
                onToggled: root.togglePower(value)
            }
        }
    }
}
