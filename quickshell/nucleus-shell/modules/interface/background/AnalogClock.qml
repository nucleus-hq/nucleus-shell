import QtQuick
import qs.modules.components
import qs.modules.components.morphedPolygons
import qs.services
import qs.config
import "../../components/morphedPolygons/material-shapes.js" as MaterialShapes

Item {
    id: analogClockContainer

    property int hours: parseInt(Time.format("hh"))
    property int minutes: parseInt(Time.format("mm"))
    property int seconds: parseInt(Time.format("ss"))

    readonly property real cx: width / 2
    readonly property real cy: height / 2

    property var shapes: [
        MaterialShapes.getCookie7Sided,
        MaterialShapes.getCookie9Sided,
        MaterialShapes.getCookie12Sided,
        MaterialShapes.getPixelCircle,
        MaterialShapes.getCircle,
        MaterialShapes.getGhostish
    ]

    MorphedPolygon {
        id: shapeCanvas
        anchors.fill: parent
        color: Appearance.m3colors.m3secondaryContainer
        roundedPolygon: analogClockContainer.shapes[
            Config.runtime.appearance.background.clock.shape
        ]()

        transform: Rotation {
            origin.x: shapeCanvas.width / 2
            origin.y: shapeCanvas.height / 2
            angle: shapeCanvas.rotation
        }

        NumberAnimation on rotation {
            from: 0
            to: 360
            running:
                Config.runtime.appearance.animations.enabled &&
                Config.runtime.appearance.background.clock.rotatePolygonBg

            duration:
                Config.runtime.appearance.background.clock.rotationDuration * 1000

            loops: Animation.Infinite
        }
    }

    ClockDial {
        anchors.fill: parent
        anchors.margins: parent.width * 0.12
        color: Appearance.colors.colOnSecondaryContainer
    }

    StyledRect {
        z: 2
        width: 10
        height: parent.height * 0.3
        radius: Metrics.radius("full")
        color: Qt.darker(Appearance.m3colors.m3secondary, 0.8)
        x: analogClockContainer.cx - width / 2
        y: analogClockContainer.cy - height
        transformOrigin: Item.Bottom
        rotation: (hours % 12 + minutes / 60) * 30
    }

    StyledRect {
        anchors.centerIn: parent
    
        width: 16
        height: 16
        radius: width / 2
        color: Appearance.m3colors.m3secondary
    
        z: 99 // ensure above other elements
    
        // inner dot
        StyledRect {
            anchors.centerIn: parent
    
            width: parent.width / 2
            height: parent.height / 2
            radius: width / 2
            color: Appearance.m3colors.m3primaryContainer
    
            z: 100
        }
    }

    StyledRect {
        width: 18
        height: parent.height * 0.35
        radius: Metrics.radius("full")
        color: Appearance.m3colors.m3secondary
        x: analogClockContainer.cx - width / 2
        y: analogClockContainer.cy - height
        transformOrigin: Item.Bottom
        rotation: minutes * 6
        z: 10
    }

    StyledRect {
        width: 4
        height: parent.height * 0.28
        radius: Metrics.radius("full")
        color: Appearance.m3colors.m3error
        x: analogClockContainer.cx - width / 2
        y: analogClockContainer.cy - height
        transformOrigin: Item.Bottom
        rotation: seconds * 6
        z: 2
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Metrics.margin(30)
        spacing: Metrics.margin(0)
    
        StyledText {
            text: Time.format("hh")
            font.pixelSize: Metrics.fontSize(80)
            font.bold: true
            opacity: 0.3
            animate: false
        }
    
        StyledText {
            text: Time.format("mm")
            font.pixelSize: Metrics.fontSize(80)
            font.bold: true
            opacity: 0.3
            animate: false
        }
    }
}
