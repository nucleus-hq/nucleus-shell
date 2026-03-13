import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.config
import qs.modules.functions

Item {
    id: root
    width: 200
    height: 56

    property string label: "Select option"
    property var model: ["Option 1","Option 2","Option 3","Option 4","Option 5"]
    property int currentIndex: -1
    property bool enabled: true
    property string textRole: ""

    property int radius: Metrics.radius(18)

    property string currentText: {
        if (currentIndex < 0)
            return ""

        if (textRole && model && model.get)
            return model.get(currentIndex)[textRole] ?? ""

        return model[currentIndex] ?? ""
    }

    signal selectedIndexChanged(int index)

    Rectangle {
        id: container
        anchors.fill: parent

        radius: root.radius
        color: "transparent"

        border.color: dropdown.activeFocus
                      ? Appearance.m3colors.m3primary
                      : Appearance.m3colors.m3outline
        border.width: dropdown.activeFocus ? 2 : 1

        clip: true

        Behavior on border.color {
            enabled: Config.runtime.appearance.animations.enabled
            ColorAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on border.width {
            enabled: Config.runtime.appearance.animations.enabled
            NumberAnimation {
                duration: Metrics.chronoDuration("small")
                easing.type: Easing.InOutCubic
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.enabled
            hoverEnabled: true

            onClicked: {
                dropdown.popup.visible
                    ? dropdown.popup.close()
                    : dropdown.popup.open()
            }

            Rectangle {
                anchors.fill: parent
                radius: container.radius

                color: Appearance.m3colors.m3primary

                opacity:
                    mouseArea.pressed ? 0.12 :
                    mouseArea.containsMouse ? 0.08 : 0

                Behavior on opacity {
                    enabled: Config.runtime.appearance.animations.enabled
                    NumberAnimation {
                        duration: Metrics.chronoDuration("small")
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Metrics.margin(16)
            anchors.rightMargin: Metrics.margin(12)

            spacing: Metrics.spacing(12)

            StyledText {
                id: labelText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                text: root.currentIndex >= 0
                      ? root.currentText
                      : root.label

                color:
                    root.currentIndex >= 0
                    ? Appearance.m3colors.m3onSurface
                    : ColorUtils.transparentize(
                        Appearance.m3colors.m3onSurfaceVariant,
                        0.7
                      )

                font.pixelSize: Metrics.fontSize(16)
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter

                icon:
                    dropdown.popup.visible
                    ? "arrow_drop_up"
                    : "arrow_drop_down"

                iconSize: Metrics.iconSize(20)
                color: Appearance.m3colors.m3onSurfaceVariant
            }
        }
    }

    ComboBox {
        id: dropdown
        visible: false

        model: root.model
        currentIndex: root.currentIndex >= 0 ? root.currentIndex : -1
        enabled: root.enabled
        textRole: root.textRole

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                root.currentIndex = currentIndex
                root.selectedIndexChanged(currentIndex)
            }
        }

        popup: Popup {
            y: root.height + 6
            width: root.width
            padding: 0

            background: Rectangle {
                radius: Metrics.radius(16)

                color: Appearance.m3colors.m3surfaceContainer

                border.color: Appearance.m3colors.m3outline
                border.width: 1

                layer.enabled: true

                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: ColorUtils.transparentize(
                        Appearance.m3colors.m3shadow, 0.25)
                    shadowBlur: 0.4
                    shadowVerticalOffset: 8
                    shadowHorizontalOffset: 0
                }
            }

            contentItem: ListView {
                id: listView

                clip: true

                implicitHeight: Math.min(contentHeight, 300)

                model: dropdown.popup.visible ? dropdown.model : []

                currentIndex: Math.max(0, dropdown.currentIndex)

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: ItemDelegate {
                    width: listView.width
                    height: 48

                    background: Rectangle {

                        radius: Metrics.radius(10)

                        color: {
                            if (itemMouse.pressed)
                                return ColorUtils.transparentize(
                                    Appearance.m3colors.m3primaryContainer,0.12)

                            if (itemMouse.containsMouse)
                                return ColorUtils.transparentize(
                                    Appearance.m3colors.m3primaryContainer,0.08)

                            if (index === root.currentIndex)
                                return ColorUtils.transparentize(
                                    Appearance.m3colors.m3primaryContainer,0.08)

                            return "transparent"
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Metrics.chronoDuration("small")
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    contentItem: StyledText {
                        text: modelData

                        color:
                            index === root.currentIndex
                            ? Appearance.m3colors.m3primary
                            : Appearance.m3colors.m3onSurface

                        font.pixelSize: Metrics.fontSize(16)
                        verticalAlignment: Text.AlignVCenter

                        leftPadding: Metrics.margin(16)
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            dropdown.currentIndex = index
                            dropdown.popup.close()
                        }
                    }
                }
            }

            enter: Transition {
                enabled: Config.runtime.appearance.animations.enabled

                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Metrics.chronoDuration("small")
                    easing.type: Easing.InOutCubic
                }

                NumberAnimation {
                    property: "scale"
                    from: 0.95
                    to: 1
                    duration: Metrics.chronoDuration("small")
                    easing.type: Easing.InOutCubic
                }
            }

            exit: Transition {
                enabled: Config.runtime.appearance.animations.enabled

                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Metrics.chronoDuration("small")
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    focus: true

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Space ||
            event.key === Qt.Key_Return) {

            dropdown.popup.visible
                ? dropdown.popup.close()
                : dropdown.popup.open()

            event.accepted = true
        }
    }
}
