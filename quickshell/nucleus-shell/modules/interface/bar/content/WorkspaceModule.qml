import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.modules.components
import qs.modules.functions
import qs.services

Item {
    id: workspaceContainer
    property string displayName: screen?.name ?? ""
    property int numWorkspaces: ConfigResolver.bar(displayName).modules.workspaces.workspaceIndicators
    property var workspaceOccupied: []
    property var occupiedRanges: []

    function japaneseNumber(num) {
        var kanjiMap = {
            "0": "零",
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "6": "六",
            "7": "七",
            "8": "八",
            "9": "九",
            "10": "十"
        };
        return kanjiMap[num] !== undefined ? kanjiMap[num] : "Number out of range";
    }

    function updateWorkspaceOccupied() {
        const offset = 1;
        workspaceOccupied = Array.from({
            "length": numWorkspaces
        }, (_, i) => {
            return Compositor.isWorkspaceOccupied(i + 1);
        });
        const ranges = [];
        let start = -1;
        for (let i = 0; i < workspaceOccupied.length; i++) {
            if (workspaceOccupied[i]) {
                if (start === -1)
                    start = i;

            } else if (start !== -1) {
                ranges.push({
                    "start": start,
                    "end": i - 1
                });
                start = -1;
            }
        }
        if (start !== -1)
            ranges.push({
            "start": start,
            "end": workspaceOccupied.length - 1
        });

        occupiedRanges = ranges;
    }

    visible: ConfigResolver.bar(displayName).modules.workspaces.enabled
    implicitWidth: bg.implicitWidth
    implicitHeight: ConfigResolver.bar(displayName).modules.height
    Component.onCompleted: updateWorkspaceOccupied()

    Connections {
        function onStateChanged() {
            updateWorkspaceOccupied();
        }

        target: Compositor
    }

    Rectangle {
        id: bg

        color: Appearance.m3colors.m3paddingContainer
        radius: ConfigResolver.bar(displayName).modules.radius * Config.runtime.appearance.rounding.factor
        implicitWidth: workspaceRow.implicitWidth + Metrics.margin("large") - 8
        implicitHeight: ConfigResolver.bar(displayName).modules.height

        // occupied background highlight
        Item {
            id: occupiedStretchLayer

            anchors.centerIn: workspaceRow
            width: workspaceRow.width
            height: 26
            z: 0
            visible: Compositor.require("hyprland") // Hyprland only

            Repeater {
                model: occupiedRanges

                Rectangle {
                    height: 26
                    radius: ConfigResolver.bar(displayName).modules.radius * Config.runtime.appearance.rounding.factor
                    color: ColorUtils.mix(Appearance.m3colors.m3tertiary, Appearance.m3colors.m3surfaceContainerLowest)
                    opacity: 0.8
                    x: modelData.start * (26 + workspaceRow.spacing)
                    width: (modelData.end - modelData.start + 1) * 26 + (modelData.end - modelData.start) * workspaceRow.spacing
                }

            }

        }

        // workspace highlight
        Rectangle {
            id: highlight

            property int offset: Compositor.require("hyprland") ? 1 : 0
            property int index: Math.max(0, Compositor.focusedWorkspaceId - 1 - offset)
            property real itemWidth: 26
            property real spacing: workspaceRow.spacing
            property int highlightIndex: {
                if (!Compositor.focusedWorkspaceId)
                    return 0;

                if (Compositor.require("hyprland"))
                    return Compositor.focusedWorkspaceId - 1;
                // Hyprland starts at 2 internally
                return Compositor.focusedWorkspaceId - 2; // Niri or default
            }
            property real targetX: Math.min(highlightIndex, numWorkspaces - 1) * (itemWidth + spacing) + 7.3
            property real animatedX1: targetX
            property real animatedX2: targetX

            x: Math.min(animatedX1, animatedX2)
            anchors.verticalCenter: parent.verticalCenter
            width: Math.abs(animatedX2 - animatedX1) + itemWidth - 1
            height: 24
            radius: ConfigResolver.bar(displayName).modules.radius * Config.runtime.appearance.rounding.factor
            color: Appearance.m3colors.m3tertiary
            onTargetXChanged: {
                animatedX1 = targetX;
                animatedX2 = targetX;
            }

            Behavior on animatedX1 {
                enabled: Config.runtime.appearance.animations.enabled

                NumberAnimation {
                    duration: Metrics.chronoDuration(400)
                    easing.type: Easing.OutSine
                }

            }

            Behavior on animatedX2 {
                enabled: Config.runtime.appearance.animations.enabled

                NumberAnimation {
                    duration: Metrics.chronoDuration(133)
                    easing.type: Easing.OutSine
                }

            }

        }

        RowLayout {
            id: workspaceRow

            anchors.centerIn: parent
            spacing: Metrics.spacing(10)

            Repeater {
                model: numWorkspaces

                Item {
                    property int wsIndex: index + 1
                    property bool occupied: Compositor.isWorkspaceOccupied(wsIndex)
                    property bool focused: wsIndex === Compositor.focusedWorkspaceId

                    width: 26
                    height: 26

                    // Icon container — only used on Hyprland
                    ClippingRectangle {
                        id: iconContainer

                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        color: "transparent"
                        radius: Appearance.rounding.small
                        clip: true

                        IconImage {
                            id: appIcon

                            anchors.fill: parent
                            visible: Compositor.require("hyprland") && ConfigResolver.bar(displayName).modules.workspaces.showAppIcons && occupied
                            rotation: (ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right") ? 270 : 0
                            source: {
                                const win = Compositor.focusedWindowForWorkspace(wsIndex);
                                if (!win) return "";
                                const entry = DesktopEntries.heuristicLookup(win.class);
                                if (entry && entry.icon)
                                    return AppRegistry.iconForDesktopIcon(entry.icon);
                                return AppRegistry.iconForClass(win.class);
                            }
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                saturation: (Config.runtime.appearance.tintIcons || (Config.runtime.appearance.colors.matugenScheme === "scheme-monochrome" && Config.runtime.appearance.colors.autogenerated) || Config.runtime.appearance.colors.scheme.toLowerCase() === "monochrome") ? -1.0 : 1.0
                            }
                        }

                    }

                    // Kanji mode — only if not Hyprland
                    StyledText {
                        anchors.centerIn: parent
                        visible: ConfigResolver.bar(displayName).modules.workspaces.showJapaneseNumbers && !ConfigResolver.bar(displayName).modules.workspaces.showAppIcons
                        text: japaneseNumber(index + 1)
                        rotation: (ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right") ? 270 : 0
                    }

                    // Numbers mode — only if not Hyprland
                    StyledText {
                        anchors.centerIn: parent
                        visible: !ConfigResolver.bar(displayName).modules.workspaces.showJapaneseNumbers && !ConfigResolver.bar(displayName).modules.workspaces.showAppIcons
                        text: index + 1
                        rotation: (ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right") ? 270 : 0
                    }

                    // Symbols for unoccupied workspaces — only for Hyprland icons
                    MaterialSymbol {
                        property string displayText: Config.runtime.appearance.rounding.factor === 0 ? "crop_square" : "fiber_manual_record"

                        anchors.centerIn: parent
                        visible: Compositor.require("hyprland") && ConfigResolver.bar(displayName).modules.workspaces.showAppIcons && !occupied
                        text: displayText
                        rotation: (ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right") ? 270 : 0
                        font.pixelSize: Metrics.iconSize(10)
                        fill: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Compositor.changeWorkspace(wsIndex)
                    }

                }

            }

        }

    }

}
