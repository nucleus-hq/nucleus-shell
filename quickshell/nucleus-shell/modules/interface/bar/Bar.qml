import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services
import qs.modules.components

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            // some exclusiveSpacing so it won't look like its sticking into the window when floating

            id: bar

            required property var modelData
            property string displayName: modelData.name
            property int rd: ConfigResolver.bar(displayName).radius * Config.runtime.appearance.rounding.factor // So it won't be modified when factor is 0
            property int margin: ConfigResolver.bar(displayName).margins
            property bool floating: ConfigResolver.bar(displayName).floating
            property bool merged: ConfigResolver.bar(displayName).merged
            property string pos: ConfigResolver.bar(displayName).position
            property bool vertical: pos === "left" || pos === "right"
            // Simple position properties
            property bool attachedTop: pos === "top"
            property bool attachedBottom: pos === "bottom"
            property bool attachedLeft: pos === "left"
            property bool attachedRight: pos === "right"

            screen: modelData // Show bar on all screens
            visible: ConfigResolver.bar(displayName).enabled && Config.initialized
            WlrLayershell.namespace: "nucleus:bar"
            exclusiveZone: ConfigResolver.bar(displayName).floating ? ConfigResolver.bar(displayName).density + Metrics.margin("tiny") : ConfigResolver.bar(displayName).density
            implicitHeight: ConfigResolver.bar(displayName).density // density === height. (horizontal orientation)
            implicitWidth: ConfigResolver.bar(displayName).density // density === width. (vertical orientation)
            color: "transparent" // Keep panel window's color transparent, so that it can be modified by background rect

            // This is probably a little weird way to set anchors but I think it's the best way. (and it works)
            anchors {
                top: ConfigResolver.bar(displayName).position === "top" || ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right"
                bottom: ConfigResolver.bar(displayName).position === "bottom" || ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "right"
                left: ConfigResolver.bar(displayName).position === "left" || ConfigResolver.bar(displayName).position === "top" || ConfigResolver.bar(displayName).position === "bottom"
                right: ConfigResolver.bar(displayName).position === "right" || ConfigResolver.bar(displayName).position === "top" || ConfigResolver.bar(displayName).position === "bottom"
            }

            margins {
                top: {
                    if (floating)
                        return margin;

                    if (merged && vertical)
                        return margin;

                    return 0;
                }
                bottom: {
                    if (floating)
                        return margin;

                    if (merged && vertical)
                        return margin;

                    return 0;
                }
                left: {
                    if (floating)
                        return margin;

                    if (merged && !vertical)
                        return margin;

                    return 0;
                }
                right: {
                    if (floating)
                        return margin;

                    if (merged && !vertical)
                        return margin;

                    return 0;
                }
            }

            GothCorners {
                opacity: ConfigResolver.bar(bar.displayName).gothCorners && !ConfigResolver.bar(bar.displayName).floating && ConfigResolver.bar(bar.displayName).enabled && !ConfigResolver.bar(bar.displayName).merged ? 1 : 0
            }

            StyledRect {
                id: background
                color: Appearance.m3colors.m3background
                anchors.fill: parent
                topLeftRadius: {
                    if (floating)
                        return rd;

                    if (!merged)
                        return 0;

                    return attachedBottom || attachedRight ? rd : 0;
                }
                topRightRadius: {
                    if (floating)
                        return rd;

                    if (!merged)
                        return 0;

                    return attachedBottom || attachedLeft ? rd : 0;
                }
                bottomLeftRadius: {
                    if (floating)
                        return rd;

                    if (!merged)
                        return 0;

                    return attachedTop || attachedRight ? rd : 0;
                }
                bottomRightRadius: {
                    if (floating)
                        return rd;

                    if (!merged)
                        return 0;

                    return attachedTop || attachedLeft ? rd : 0;
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
