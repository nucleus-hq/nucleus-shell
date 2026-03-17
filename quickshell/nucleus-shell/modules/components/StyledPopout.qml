import qs.config
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

LazyLoader {
    id: root

    property string displayName: screen?.name ?? ""
    property PanelWindow instance: null
    property HoverHandler hoverTarget
    property real margin: Metrics.margin(10)
    default property list<Component> content
    property bool startAnim: false
    property bool isVisible: false
    property bool keepAlive: false
    property bool interactable: false
    property bool hasHitbox: true
    property bool hCenterOnItem: false
    property bool followMouse: false
    property list<StyledPopout> childPopouts: []

    property bool requiresHover: true
    property bool _manualControl: false
    property int hoverDelay: Metrics.chronoDuration(250)

    property bool targetHovered: hoverTarget && hoverTarget.hovered
    property bool containerHovered: interactable && root.item && root.item.containerHovered
    property bool selfHovered: targetHovered || containerHovered

    property bool childrenHovered: {
        for (let i = 0; i < childPopouts.length; i++) {
            if (childPopouts[i].selfHovered)
                return true;
        }
        return false;
    }

    property bool hoverActive: selfHovered || childrenHovered

    property Timer showDelayTimer: Timer {
        interval: root.hoverDelay
        repeat: false
        onTriggered: {
            root.keepAlive = true;
            root.isVisible = true;
            root.startAnim = true;
        }
    }

    property Timer hangTimer: Timer {
        interval: Metrics.chronoDuration(200)
        repeat: false
        onTriggered: {
            root.startAnim = false;
            cleanupTimer.restart();
        }
    }

    property Timer cleanupTimer: Timer {
        interval: Metrics.chronoDuration("small")
        repeat: false
        onTriggered: {
            root.isVisible = false;
            root.keepAlive = false;
            root._manualControl = false;
            root.instance = null;
        }
    }

    onHoverActiveChanged: {
        if (_manualControl)
            return;
        if (!requiresHover)
            return;
        if (hoverActive) {
            hangTimer.stop();
            cleanupTimer.stop();
            if (hoverDelay > 0) {
                showDelayTimer.restart();
            } else {
                root.keepAlive = true;
                root.isVisible = true;
                root.startAnim = true;
            }
        } else {
            showDelayTimer.stop();
            hangTimer.restart();
        }
    }

    function show() {
        hangTimer.stop();
        cleanupTimer.stop();
        showDelayTimer.stop();
        _manualControl = true;
        keepAlive = true;
        isVisible = true;
        startAnim = true;
    }

    function hide() {
        _manualControl = true;
        showDelayTimer.stop();
        startAnim = false;
        hangTimer.stop();
        cleanupTimer.restart();
    }

    active: keepAlive

    component: PanelWindow {
        id: popoutWindow

        color: "transparent"
        visible: root.isVisible

        WlrLayershell.namespace: "nucleus:popout"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        anchors {
            left: true
            top: true
            right: true
            bottom: true
        }

        property bool exceedingHalf: false
        property var parentPopoutWindow: null
        property point mousePos: Qt.point(0, 0)
        property bool containerHovered: root.interactable && containerHoverHandler.hovered

        HoverHandler {
            id: windowHover
            onPointChanged: point => {
                if (root.followMouse)
                    popoutWindow.mousePos = point.position;
            }
        }

        mask: Region {
            x: !root.hasHitbox ? 0 : !requiresHover ? 0 : container.x
            y: !root.hasHitbox ? 0 : !requiresHover ? 0 : container.y
            width: !root.hasHitbox ? 0 : !requiresHover ? popoutWindow.width : container.implicitWidth
            height: !root.hasHitbox ? 0 : !requiresHover ? popoutWindow.height : container.implicitHeight
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: false

            onPressed: mouse => {
                if (!containerHoverHandler.containsMouse && root.isVisible) {
                    root.hide();
                }
            }
        }

        Item {
            id: container

            implicitWidth: contentArea.implicitWidth + root.margin * 2
            implicitHeight: contentArea.implicitHeight + root.margin * 2

            x: {
                let xValue;

                if (root.followMouse)
                    xValue = mousePos.x + 10;
                else {
                    let targetItem = hoverTarget?.parent;
                    if (!targetItem)
                        xValue = 0;
                    else {
                        let baseX = targetItem.mapToGlobal(Qt.point(0, 0)).x;
                        if (parentPopoutWindow)
                            baseX += parentPopoutWindow.x;

                        let targetWidth = targetItem.width;
                        let popupWidth = container.implicitWidth;

                        const barPosX = ConfigResolver.bar(root.displayName).position;
                        const densityX = ConfigResolver.bar(root.displayName).density;
                        const floatingX = ConfigResolver.bar(root.displayName).floating;
                        const barMarginX = ConfigResolver.bar(root.displayName).margins;

                        // Same issue as bottom: mapToGlobal returns window-local X for right bars.
                        if (barPosX === "right")
                            baseX += (screen?.width ?? 0) - densityX - (floatingX ? barMarginX : 0);

                        let xPos;
                        if (barPosX === "left") {
                            xPos = baseX + targetWidth;
                        } else if (barPosX === "right") {
                            xPos = baseX - popupWidth;
                        } else if (root.hCenterOnItem) {
                            xPos = baseX + (targetWidth - popupWidth) / 2;
                        } else {
                            xPos = baseX - 20;
                        }

                        if (xPos + popupWidth > (screen?.width ?? 0)) {
                            exceedingHalf = true;
                            xValue = (screen?.width ?? 0) - popupWidth - 10;
                        } else if (xPos < 10) {
                            exceedingHalf = false;
                            xValue = 10;
                        } else {
                            exceedingHalf = false;
                            xValue = xPos;
                        }
                    }
                }

                return root.cleanupTimer.running ? xValue : Math.round(xValue);
            }

            y: {
                let yValue;

                if (root.followMouse)
                    yValue = mousePos.y + 10;
                else {
                    let targetItem = hoverTarget?.parent;
                    if (!targetItem)
                        yValue = 0;
                    else {
                        let baseY = targetItem.mapToGlobal(Qt.point(0, 0)).y;
                        if (parentPopoutWindow)
                            baseY += parentPopoutWindow.y;

                        let targetHeight = targetItem.height;
                        let popupHeight = container.implicitHeight;

                        const barPos = ConfigResolver.bar(root.displayName).position;
                        const density = ConfigResolver.bar(root.displayName).density;
                        const floating = ConfigResolver.bar(root.displayName).floating;
                        const barMargin = ConfigResolver.bar(root.displayName).margins;

                        // mapToGlobal returns window-local coords for bottom bars because
                        // Quickshell doesn't report the bar window's Y to Qt for bottom-anchored windows.
                        // Add the bar's expected screen offset to convert to screen-global.
                        if (barPos === "bottom")
                            baseY += (screen?.height ?? 0) - density - (floating ? barMargin : 0);

                        let yPos;
                        if (barPos === "top")
                            yPos = baseY + targetHeight;
                        else if (barPos === "bottom")
                            yPos = baseY - popupHeight;
                        else
                            yPos = baseY + (targetHeight - popupHeight) / 2;

                        if (yPos + popupHeight > (screen?.height ?? 0))
                            yPos = (screen?.height ?? 0) - popupHeight - 10;
                        if (yPos < 10)
                            yPos = 10;

                        yValue = yPos;
                    }
                }

                return root.cleanupTimer.running ? yValue : Math.round(yValue);
            }

            opacity: root.startAnim ? 1 : 0
            scale: root.interactable ? 1 : root.startAnim ? 1 : 0.9


            Behavior on opacity {
                NumberAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }
            Behavior on scale {
                enabled: !root.interactable
                NumberAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }
            Behavior on implicitWidth {
                enabled: root.interactable
                NumberAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }
            Behavior on implicitHeight {
                enabled: root.interactable
                NumberAnimation {
                    duration: Metrics.chronoDuration("small")
                    easing.type: Appearance.animation.easing
                }
            }

            ClippingRectangle {
                id: popupBackground
                anchors.fill: parent
                color: Appearance.m3colors.m3surface
                radius: Appearance.rounding.normal

                ColumnLayout {
                    id: contentArea
                    anchors.fill: parent
                    anchors.margins: root.margin
                }
            }

            HoverHandler {
                id: containerHoverHandler
                enabled: root.interactable
            }
        }

        Component.onCompleted: {
            root.instance = popoutWindow;
            for (let i = 0; i < root.content.length; i++) {
                const comp = root.content[i];
                if (comp && comp.createObject) {
                    comp.createObject(contentArea);
                } else {
                    console.warn("StyledPopout: invalid content:", comp);
                }
            }


            let parentPopout = root.parent;
            while (parentPopout && !parentPopout.childPopouts)
                parentPopout = parentPopout.parent;

            if (parentPopout) {
                parentPopout.childPopouts = [...parentPopout.childPopouts, root];
                if (parentPopout.item)
                    popoutWindow.parentPopoutWindow = parentPopout.item;
            }
        }
    }
}
