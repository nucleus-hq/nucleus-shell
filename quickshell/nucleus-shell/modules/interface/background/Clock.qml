import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
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
                const x = Math.floor(Math.random() * (width - clockWidth))
                const y = Math.floor(Math.random() * (height - clockHeight))
                animX.to = x
                animY.to = y
                moveAnim.start()
                Config.updateKey("appearance.background.clock.xPos", x)
                Config.updateKey("appearance.background.clock.yPos", y)
            }

            color: "transparent"

            visible: (
                Config.runtime.appearance.background.clock.enabled &&
                Config.initialized &&
                !imageFailed
            )

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

                height: clockHeight
                width: clockWidth

                Component.onCompleted: {
                    Qt.callLater(() => {
                        x = Config.runtime.appearance.background.clock.xPos
                        y = Config.runtime.appearance.background.clock.yPos
                    })
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: rootContentContainer
                    drag.axis: Drag.XAndYAxis
                    acceptedButtons: Qt.RightButton

                    onReleased: {
                        if (mouse.button === Qt.RightButton)
                            return

                        Config.updateKey(
                            "appearance.background.clock.xPos",
                            rootContentContainer.x
                        )

                        Config.updateKey(
                            "appearance.background.clock.yPos",
                            rootContentContainer.y
                        )
                    }
                }

                DigitalClock {
                    visible: !Config.runtime.appearance.background.clock.isAnalog
                    anchors.fill: parent
                }

                AnalogClock {
                    visible: Config.runtime.appearance.background.clock.isAnalog
                    anchors.fill: parent
                }
            }
        }
    }
}