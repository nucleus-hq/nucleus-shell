import "../../components/morphedPolygons/geometry/offset.js" as Offset
import "../../components/morphedPolygons/material-shapes.js" as MaterialShapes // For polygons
import "../../components/morphedPolygons/shapes/corner-rounding.js" as CornerRounding
import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import Quickshell.Wayland
import qs.config
import qs.modules.functions
import qs.modules.interface.background
import qs.modules.components
import qs.modules.components.morphedPolygons
import qs.services

Rectangle {
    id: root

    required property LockContext context
    property string displayName: screen?.name ?? ""

    color: "transparent"

    Image {
        anchors.fill: parent
        z: -1
        property string previewImg: {
            const displays = Config.runtime.monitors
            const fallback = Config.runtime.appearance.background.defaultPath

            if (!displays)
                return fallback

                const monitor = displays?.[displayName]
                return monitor?.wallpaper ?? fallback
            }

        source: previewImg + "?t=" + Date.now()
    }

    RowLayout {
        spacing: Metrics.spacing(20)

        anchors {
            top: parent.top
            right: parent.right
            topMargin: Metrics.spacing(20)
            rightMargin: Metrics.spacing(30)
        }

        MaterialSymbol {
            id: themeIcon

            fill: 1
            icon: Config.runtime.appearance.theme === "light" ? "light_mode" : "dark_mode"
            iconSize: Metrics.fontSize("hugeass")
        }

        MaterialSymbol {
            id: wifi

            icon: Network.icon
            iconSize: Metrics.fontSize("hugeass")
        }

        MaterialSymbol {
            id: btIcon

            icon: Bluetooth.icon
            iconSize: Metrics.fontSize("hugeass")
        }

        StyledText {
            id: keyboardLayoutIcon

            text: SystemDetails.keyboardLayout
            font.pixelSize: Metrics.fontSize(Appearance.font.size.huge - 4)
        }

    }

    ColumnLayout {

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Metrics.margin(150)
        }

        StyledText {
            id: clock

            visible: !Config.runtime.appearance.background.clock.isAnalog
            Layout.alignment: Qt.AlignBottom
            animate: false
            renderType: Text.NativeRendering
            font.pixelSize: Metrics.fontSize(180)
            text: Time.format("hh:mm")
        }

        StyledText {
            id: date

            visible: !Config.runtime.appearance.background.clock.isAnalog
            Layout.alignment: Qt.AlignCenter
            animate: false
            renderType: Text.NativeRendering
            font.pixelSize: Metrics.fontSize(50)
            text: Time.format("dddd, dd/MM")
        }

        Item {
            id: analogClockContainer

            property int hours: parseInt(Time.format("hh"))
            property int minutes: parseInt(Time.format("mm"))
            property int seconds: parseInt(Time.format("ss"))
            readonly property real cx: width / 2
            readonly property real cy: height / 2
            property var shapes: [MaterialShapes.getCookie7Sided, MaterialShapes.getCookie9Sided, MaterialShapes.getCookie12Sided, MaterialShapes.getPixelCircle, MaterialShapes.getCircle, MaterialShapes.getGhostish]

            visible: Config.runtime.appearance.background.clock.isAnalog
            width: 350
            height: 350

            // Polygon
            MorphedPolygon {
                id: shapeCanvas

                anchors.fill: parent
                color: Appearance.m3colors.m3secondaryContainer
                roundedPolygon: analogClockContainer.shapes[Config.runtime.appearance.background.clock.shape]()
            }

            ClockDial {
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
                width: 14
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
                anchors.topMargin: Metrics.margin(60)
                font.pixelSize: Metrics.fontSize(100)
                font.bold: true
                opacity: 0.3
                animate: false
            }

            StyledText {
                text: Time.format("mm")
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Metrics.margin(150)
                font.pixelSize: Metrics.fontSize(100)
                font.bold: true
                opacity: 0.3
                animate: false
            }

        }

    }

    ColumnLayout {
        // Commenting this will make the password entry visible on all monitors.
        visible: Window.active

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Metrics.margin(20)
        }

        RowLayout {
            StyledTextField {
                id: passwordBox

                implicitWidth: 300
                padding: Metrics.padding(10)
                placeholder: root.context.showFailure ? "Incorrect Password" : "Enter Password"
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                // Update the text in the context when the text in the box changes.
                onTextChanged: root.context.currentText = this.text
                // Try to unlock when enter is pressed.
                onAccepted: root.context.tryUnlock()

                // Update the text in the box to match the text in the context.
                // This makes sure multiple monitors have the same text.
                Connections {
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }

                    target: root.context
                }

            }

            StyledButton {
                icon: "chevron_right"
                padding: Metrics.padding(10)
                radius: Metrics.radius("large")
                // don't steal focus from the text box
                focusPolicy: Qt.NoFocus
                enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                onClicked: root.context.tryUnlock()
            }

        }

    }

}
