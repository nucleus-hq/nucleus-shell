import "../../components/morphedPolygons/geometry/offset.js" as Offset
import "../../components/morphedPolygons/material-shapes.js" as MaterialShapes // For polygons
import "../../components/morphedPolygons/shapes/corner-rounding.js" as CornerRounding
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.modules.components
import qs.modules.components.morphedPolygons
import qs.services

Scope {
    id: root

    property bool imageFailed: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: clock

            required property var modelData
            property int padding: Config.runtime.appearance.background.clock.edgeSpacing
            property int clockHeight: Config.runtime.appearance.background.clock.isAnalog ? 250 : 160
            property int clockWidth: Config.runtime.appearance.background.clock.isAnalog ? 250 : 360

            function setRandomPosition() {
                const x = Math.floor(Math.random() * (width - clockWidth));
                const y = Math.floor(Math.random() * (height - clockHeight));
                animX.to = x;
                animY.to = y;
                moveAnim.start();
                Config.updateKey("appearance.background.clock.xPos", x);
                Config.updateKey("appearance.background.clock.yPos", y);
            }

            color: "transparent"
            visible: (Config.runtime.appearance.background.clock.enabled && Config.initialized && !root.imageFailed)
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Bottom
            screen: modelData

            ParallelAnimation {
                id: moveAnim

                NumberAnimation {
                    id: animX

                    target: rootContentContainer
                    property: "x"
                    duration: Metrics.chronoDuration(400)
                    easing.type: Easing.InOutCubic
                }

                NumberAnimation {
                    id: animY

                    target: rootContentContainer
                    property: "y"
                    duration: Metrics.chronoDuration(400)
                    easing.type: Easing.InOutCubic
                }

            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            margins {
                top: padding
                bottom: padding
                left: padding
                right: padding
            }

            Item {
                id: rootContentContainer

                property real releasedX: 0
                property real releasedY: 0

                height: clockHeight
                width: clockWidth
                Component.onCompleted: {
                    Qt.callLater(() => {
                        x = Config.runtime.appearance.background.clock.xPos;
                        y = Config.runtime.appearance.background.clock.yPos;
                    });
                }

                MouseArea {
                    id: ma

                    anchors.fill: parent
                    drag.target: rootContentContainer
                    drag.axis: Drag.XAndYAxis
                    acceptedButtons: Qt.RightButton
                    onReleased: {
                        if (ma.button === Qt.RightButton)
                            return
                        Config.updateKey("appearance.background.clock.xPos", rootContentContainer.x);
                        Config.updateKey("appearance.background.clock.yPos", rootContentContainer.y);
                    }
                }

                Item {
                    id: digitalClockContainer

                    visible: !Config.runtime.appearance.background.clock.isAnalog

                    Column {
                        spacing: Metrics.spacing(-40)

                        StyledText {
                            animate: false
                            text: Time.format("hh:mm")
                            font.pixelSize: Metrics.fontSize(Appearance.font.size.wildass * 3)
                            font.family: Metrics.fontFamily("main")
                            font.bold: true
                        }

                        StyledText {
                            anchors.left: parent.left
                            anchors.leftMargin: Metrics.margin(8)
                            animate: false
                            text: Time.format("dddd, dd/MM")
                            font.pixelSize: Metrics.fontSize(32)
                            font.family: Metrics.fontFamily("main")
                            font.bold: true
                        }

                    }

                }

                Item {
                    id: analogClockContainer

                    property int hours: parseInt(Time.format("hh"))
                    property int minutes: parseInt(Time.format("mm"))
                    property int seconds: parseInt(Time.format("ss"))
                    readonly property real cx: width / 2
                    readonly property real cy: height / 2
                    property var shapes: [MaterialShapes.getCookie7Sided, MaterialShapes.getCookie9Sided, MaterialShapes.getCookie12Sided, MaterialShapes.getPixelCircle, MaterialShapes.getCircle, MaterialShapes.getGhostish]

                    anchors.fill: parent
                    visible: Config.runtime.appearance.background.clock.isAnalog
                    width: clock.width / 1.1
                    height: clock.height / 1.1

                    // Polygon
                    MorphedPolygon {
                        id: shapeCanvas

                        anchors.fill: parent
                        color: Appearance.m3colors.m3secondaryContainer
                        roundedPolygon: analogClockContainer.shapes[Config.runtime.appearance.background.clock.shape]()

                        transform: Rotation {
                            origin.x: shapeCanvas.width / 2
                            origin.y: shapeCanvas.height / 2
                            angle: shapeCanvas.rotation
                        }

                        NumberAnimation on rotation {
                            from: 0
                            to: 360
                            running: Config.runtime.appearance.animations.enabled && Config.runtime.appearance.background.clock.rotatePolygonBg
                            duration: Config.runtime.appearance.background.clock.rotationDuration * 1000
                            loops: Animation.Infinite
                        }
                    }

                    ClockDial {
                        id: dial
                        anchors.fill: parent
                        anchors.margins: parent.width * 0.12
                        color: Appearance.colors.colOnSecondaryContainer
                        z: 0
                    }

                    // Hour hand
                    StyledRect {
                        z: 2
                        width: 10
                        height: parent.height * 0.3
                        radius: Metrics.radius("full")
                        color: Qt.darker(Appearance.m3colors.m3secondary, 0.8)
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: (analogClockContainer.hours % 12 + analogClockContainer.minutes / 60) * 30
                    }

                    StyledRect {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        radius: width / 2
                        color: Appearance.m3colors.m3secondary
                        z: 99 // Ensures its on top of everthing

                        // Inner dot
                        StyledRect {
                            width: parent.width / 2
                            height: parent.height / 2
                            radius: width / 2
                            anchors.centerIn: parent
                            z: 100
                            color: Appearance.m3colors.m3primaryContainer
                        }

                    }

                    // Minute hand
                    StyledRect {
                        width: 18
                        height: parent.height * 0.35
                        radius: Metrics.radius("full")
                        color: Appearance.m3colors.m3secondary
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: analogClockContainer.minutes * 6
                        z: 10 // On top of all hands
                    }

                    // Second hand
                    StyledRect {
                        visible: true
                        width: 4
                        height: parent.height * 0.28
                        radius: Metrics.radius("full")
                        color: Appearance.m3colors.m3error
                        x: analogClockContainer.cx - width / 2
                        y: analogClockContainer.cy - height
                        transformOrigin: Item.Bottom
                        rotation: analogClockContainer.seconds * 6
                        z: 2
                    }

                    StyledText {
                        text: Time.format("hh")
                        anchors.top: parent.top 
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: Metrics.margin(30)
                        font.pixelSize: Metrics.fontSize(80)
                        font.bold: true
                        opacity: 0.3
                        animate: false
                    }

                    StyledText {
                        text: Time.format("mm")
                        anchors.top: parent.top 
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: Metrics.margin(110)
                        font.pixelSize: Metrics.fontSize(80)
                        font.bold: true
                        opacity: 0.3
                        animate: false
                    }

                    IpcHandler {
                        function changePosition() {
                            clock.setRandomPosition();
                        }

                        target: "clock"
                    }

                }

            }

        }

    }

}
