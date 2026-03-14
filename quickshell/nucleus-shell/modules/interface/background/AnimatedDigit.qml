import QtQuick
import qs.modules.components
import qs.services
import qs.config

Item {
    id: root

    property string value
    property int size: 80

    width: text1.implicitWidth
    height: text1.implicitHeight

    property string oldValue: value

    onValueChanged: {
        if (oldValue === value)
            return

        text2.text = value
        slideAnim.start()
        oldValue = value
    }

    StyledText {
        id: text1
        text: root.value

        anchors.centerIn: parent

        font.pixelSize: root.size
        font.family: Appearance.font.families.expressive
        font.weight: Font.Medium
        font.letterSpacing: 1

        renderType: Text.NativeRendering

        Component.onCompleted: {
            color = Appearance.m3colors.m3primary
        }
    }

    StyledText {
        id: text2
        text: ""

        anchors.centerIn: parent

        font.pixelSize: root.size
        font.family: Appearance.font.families.expressive
        font.weight: Font.Medium
        font.letterSpacing: 1

        renderType: Text.NativeRendering

        opacity: 0
        y: -10

        Component.onCompleted: {
            color = Appearance.m3colors.m3primary
        }
    }

    ParallelAnimation {
        id: slideAnim

        NumberAnimation {
            target: text1
            property: "opacity"
            from: 1
            to: 0
            duration: 220
        }

        NumberAnimation {
            target: text1
            property: "y"
            from: 0
            to: 10
            duration: 220
        }

        NumberAnimation {
            target: text2
            property: "opacity"
            from: 0
            to: 1
            duration: 220
        }

        NumberAnimation {
            target: text2
            property: "y"
            from: -10
            to: 0
            duration: 220
        }

        onFinished: {
            text1.text = text2.text
            text1.opacity = 1
            text1.y = 0
            text2.opacity = 0
            text2.y = -10
        }
    }
}
