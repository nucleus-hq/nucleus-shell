import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    property real value: 0.65
    property real strokeWidth: 3
    property color bgColor: Appearance.m3colors.m3surfaceContainerHighest
    property color fgColor: Appearance.m3colors.m3primary

    property string icon: "battery_full"
    property int iconSize: Metrics.iconSize(18)
    property bool fillIcon: false

    property int size: 28

    width: size
    height: size

    Behavior on value {
        NumberAnimation {
            duration: Metrics.chronoDuration("small")
            easing.type: Easing.OutCubic
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)

            const cx = width / 2
            const cy = height / 2
            const r = (width - root.strokeWidth) / 2

            const start = -Math.PI / 2
            const end = start + (2 * Math.PI * root.value)

            ctx.lineWidth = root.strokeWidth
            ctx.lineCap = "round"

            // background ring
            ctx.strokeStyle = root.bgColor
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
            ctx.stroke()

            // progress ring
            ctx.strokeStyle = root.fgColor
            ctx.beginPath()
            ctx.arc(cx, cy, r, start, end)
            ctx.stroke()
        }
    }

    onValueChanged: canvas.requestPaint()

    MaterialSymbol {
        anchors.centerIn: parent
        icon: root.icon
        iconSize: root.iconSize

        font.variableAxes: {
            "FILL": root.fillIcon ? 1 : 0
        }

        color: root.fgColor
    }
}
