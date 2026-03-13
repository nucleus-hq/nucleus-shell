import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.modules.components

Scope {
    id: root

    GothCorners {
        opacity: Config.runtime.bar.gothCorners
                 && !Config.runtime.bar.floating
                 && Config.runtime.bar.enabled
                 && !Config.runtime.bar.merged ? 1 : 0
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            property int rd: Config.runtime.bar.radius * Config.runtime.appearance.rounding.factor
            property int margin: Config.runtime.bar.margins
            property bool floating: Config.runtime.bar.floating
            property bool merged: Config.runtime.bar.merged
            property string pos: Config.runtime.bar.position
            property bool vertical: pos === "left" || pos === "right"

            /* Pill toggle */
            property bool pillOnly: Config.runtime.bar.pill ?? false

            property bool attachedTop: pos === "top"
            property bool attachedBottom: pos === "bottom"
            property bool attachedLeft: pos === "left"
            property bool attachedRight: pos === "right"

            screen: modelData
            visible: Config.runtime.bar.enabled && Config.initialized

            WlrLayershell.namespace: "nucleus:bar"

            exclusiveZone: floating
                ? Config.runtime.bar.density + Metrics.margin("tiny")
                : Config.runtime.bar.density

            implicitHeight: Config.runtime.bar.density
            implicitWidth: Config.runtime.bar.density

            /* Important for pill mode */
            color: "transparent"

            anchors {
                top: pos === "top" || pos === "left" || pos === "right"
                bottom: pos === "bottom" || pos === "left" || pos === "right"
                left: pos === "left" || pos === "top" || pos === "bottom"
                right: pos === "right" || pos === "top" || pos === "bottom"
            }

            margins {
                top: floating || (merged && vertical) ? margin : 0
                bottom: floating || (merged && vertical) ? margin : 0
                left: floating || (merged && !vertical) ? margin : 0
                right: floating || (merged && !vertical) ? margin : 0
            }

            StyledRect {
                id: background

                anchors.fill: parent

                /* Remove background in pill mode */
                color: pillOnly ? "transparent" : Appearance.m3colors.m3background

                /* Optional small padding for pill bars */
                anchors.margins: pillOnly ? Metrics.spacing(2) : 0

                topLeftRadius: {
                    if (pillOnly)
                        return height / 2
                    if (floating)
                        return rd
                    if (!merged)
                        return 0
                    return attachedBottom || attachedRight ? rd : 0
                }

                topRightRadius: {
                    if (pillOnly)
                        return height / 2
                    if (floating)
                        return rd
                    if (!merged)
                        return 0
                    return attachedBottom || attachedLeft ? rd : 0
                }

                bottomLeftRadius: {
                    if (pillOnly)
                        return height / 2
                    if (floating)
                        return rd
                    if (!merged)
                        return 0
                    return attachedTop || attachedRight ? rd : 0
                }

                bottomRightRadius: {
                    if (pillOnly)
                        return height / 2
                    if (floating)
                        return rd
                    if (!merged)
                        return 0
                    return attachedTop || attachedLeft ? rd : 0
                }

                /* Force module background removal when pill mode is active */
                Component.onCompleted: {
                    if (pillOnly) {
                        Config.runtime.bar.modules.paddingColor = "transparent"
                    }
                }

                BarContent {
                    anchors.fill: parent
                }

                Behavior on bottomLeftRadius {
                    enabled: Config.runtime.appearance.animations.enabled
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Behavior on topLeftRadius {
                    enabled: Config.runtime.appearance.animations.enabled
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Behavior on bottomRightRadius {
                    enabled: Config.runtime.appearance.animations.enabled
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

                Behavior on topRightRadius {
                    enabled: Config.runtime.appearance.animations.enabled
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }
    }
}