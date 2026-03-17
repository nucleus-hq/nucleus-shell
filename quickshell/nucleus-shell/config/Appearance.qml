import qs.modules.functions
import QtQuick
import Quickshell
pragma Singleton
pragma ComponentBehavior: Bound 

Singleton {
    id: root
    property QtObject m3colors
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject margin
    property QtObject moduleLayouts
    property QtObject animation
    property string syntaxHighlightingTheme

    readonly property bool darkmode: Config.runtime.appearance.theme === "dark"
    readonly property bool transparentize: Config.runtime.appearance.transparency.enabled 
    readonly property double alpha: Config.runtime.appearance.transparency.alpha

    colors: QtObject {
        property color colSubtext: m3colors.m3outline
        property color colLayer0: m3colors.m3background
        property color colLayer0Border: ColorUtils.mix(root.m3colors.m3outlineVariant, colLayer0, 0.4)
        property color colLayer1: m3colors.m3surfaceContainerLow
        property color colOnLayer1: m3colors.m3onSurfaceVariant
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45)
        property color colLayer1Hover: ColorUtils.mix(colLayer1, colOnLayer1, 0.92)
        property color colLayer1Active: ColorUtils.mix(colLayer1, colOnLayer1, 0.85)
        property color colLayer2: m3colors.m3surfaceContainer
        property color colOnLayer2: m3colors.m3onSurface
        property color colLayer2Hover: ColorUtils.mix(colLayer2, colOnLayer2, 0.90)
        property color colLayer2Active: ColorUtils.mix(colLayer2, colOnLayer2, 0.80)
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        property color colTooltip: m3colors.m3inverseSurface
        property color colOnTooltip: m3colors.m3inverseOnSurface
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutline: m3colors.m3outline
    }

    m3colors: QtObject {
        function t(c) {
            return root.transparentize
                ? ColorUtils.transparentize(c, root.alpha)
                : c
        }

        function tH(c) {
            return root.transparentize
                ? ColorUtils.transparentize(c, root.alpha + .2)
                : c
        }

        readonly property color m3background: t(MaterialColors.colors.background)
        readonly property color m3paddingContainer: t(Config.runtime.bar.modules.paddingColor)
        readonly property color m3surface: t(MaterialColors.colors.surface)
        readonly property color m3surfaceDim: t(MaterialColors.colors.surface_dim)
        readonly property color m3surfaceBright: t(MaterialColors.colors.surface_bright)

        readonly property color m3surfaceContainerLowest: tH(MaterialColors.colors.surface_container_lowest)
        readonly property color m3surfaceContainerLow: tH(MaterialColors.colors.surface_container_low)
        readonly property color m3surfaceContainer: tH(MaterialColors.colors.surface_container)
        readonly property color m3surfaceContainerHigh: tH(MaterialColors.colors.surface_container_high)
        readonly property color m3surfaceContainerHighest: tH(MaterialColors.colors.surface_container_highest)

        readonly property color m3onSurface: t(MaterialColors.colors.on_surface)
        readonly property color m3surfaceVariant: t(MaterialColors.colors.surface_variant)
        readonly property color m3onSurfaceVariant: t(MaterialColors.colors.on_surface_variant)

        readonly property color m3inverseSurface: t(MaterialColors.colors.inverse_surface)
        readonly property color m3inverseOnSurface: t(MaterialColors.colors.inverse_on_surface)

        readonly property color m3outline: t(MaterialColors.colors.outline)
        readonly property color m3outlineVariant: t(MaterialColors.colors.outline_variant)
        readonly property color m3shadow: t(MaterialColors.colors.shadow)
        readonly property color m3scrim: t(MaterialColors.colors.scrim)
        readonly property color m3surfaceTint: t(MaterialColors.colors.surface_tint)

        readonly property color m3primary: t(MaterialColors.colors.primary)
        readonly property color m3onPrimary: t(MaterialColors.colors.on_primary)
        readonly property color m3primaryContainer: t(MaterialColors.colors.primary_container)
        readonly property color m3onPrimaryContainer: t(MaterialColors.colors.on_primary_container)
        readonly property color m3inversePrimary: t(MaterialColors.colors.inverse_primary)

        readonly property color m3secondary: t(MaterialColors.colors.secondary)
        readonly property color m3onSecondary: t(MaterialColors.colors.on_secondary)
        readonly property color m3secondaryContainer: t(MaterialColors.colors.secondary_container)
        readonly property color m3onSecondaryContainer: t(MaterialColors.colors.on_secondary_container)

        readonly property color m3tertiary: t(MaterialColors.colors.tertiary)
        readonly property color m3onTertiary: t(MaterialColors.colors.on_tertiary)
        readonly property color m3tertiaryContainer: t(MaterialColors.colors.tertiary_container)
        readonly property color m3onTertiaryContainer: t(MaterialColors.colors.on_tertiary_container)

        readonly property color m3error: t(MaterialColors.colors.error)
        readonly property color m3onError: t(MaterialColors.colors.on_error)
        readonly property color m3errorContainer: t(MaterialColors.colors.error_container)
        readonly property color m3onErrorContainer: t(MaterialColors.colors.on_error_container)

        readonly property color m3primaryFixed: t(MaterialColors.colors.primary_fixed)
        readonly property color m3primaryFixedDim: t(MaterialColors.colors.primary_fixed_dim)
        readonly property color m3onPrimaryFixed: t(MaterialColors.colors.on_primary_fixed)
        readonly property color m3onPrimaryFixedVariant: t(MaterialColors.colors.on_primary_fixed_variant)

        readonly property color m3secondaryFixed: t(MaterialColors.colors.secondary_fixed)
        readonly property color m3secondaryFixedDim: t(MaterialColors.colors.secondary_fixed_dim)
        readonly property color m3onSecondaryFixed: t(MaterialColors.colors.on_secondary_fixed)
        readonly property color m3onSecondaryFixedVariant: t(MaterialColors.colors.on_secondary_fixed_variant)

        readonly property color m3tertiaryFixed: t(MaterialColors.colors.tertiary_fixed)
        readonly property color m3tertiaryFixedDim: t(MaterialColors.colors.tertiary_fixed_dim)
        readonly property color m3onTertiaryFixed: t(MaterialColors.colors.on_tertiary_fixed)
        readonly property color m3onTertiaryFixedVariant: t(MaterialColors.colors.on_tertiary_fixed_variant)

    }


    margin: QtObject {
        property int supertiny: 2
        property int tinier: 3
        property int tiny: 6
        property int verysmall: 8
        property int small: 12
        property int normal: 16
        property int large: 22
        property int verylarge: 30
        property int extraLarge: 35
    }

    animation: QtObject {

        property var easing: Easing.OutExpo

        property QtObject durations: QtObject {
            property int supershort: 100
            property int small: 200
            property int normal: 400
            property int large: 600
            property int extraLarge: 1000
            property int expressiveFastSpatial: 350
            property int expressiveDefaultSpatial: 500
            property int expressiveEffects: 200
        }

        property QtObject curves: QtObject {
            readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
            readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
            readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
            readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
            readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
            readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
            readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
            readonly property real expressiveFastSpatialDuration: 350
            readonly property real expressiveDefaultSpatialDuration: 500
            readonly property real expressiveSlowSpatialDuration: 650
            readonly property real expressiveEffectsDuration: 200
        }

        property QtObject elementMove: QtObject {
            property int duration: animation.curves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation.curves.expressiveDefaultSpatial
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation.curves.emphasizedDecel
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: animation.curves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation.curves.expressiveEffects
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
        }

    }

    rounding: QtObject {
        property int unsharpen: 2 * Config.runtime.appearance.rounding.factor
        property int unsharpenmore: 6 * Config.runtime.appearance.rounding.factor
        property int verysmall: 8 * Config.runtime.appearance.rounding.factor
        property int small: 12 * Config.runtime.appearance.rounding.factor
        property int normal: 17 * Config.runtime.appearance.rounding.factor
        property int large: 23 * Config.runtime.appearance.rounding.factor
        property int verylarge: 30 * Config.runtime.appearance.rounding.factor
        property int childish: 50 * Config.runtime.appearance.rounding.factor // Idk why did I named this childish
        property int full: 9999
        property int screenRounding: large
        property int windowRounding: 18 * Config.runtime.appearance.rounding.factor
    }

    font: QtObject {
        property QtObject family: QtObject {
            property string main: Config.runtime.appearance.font.families.main
            property string title: Config.runtime.appearance.font.families.title
            property string materialIcons: Config.runtime.appearance.font.families.materialIcons
            property string nerdIcons: Config.runtime.appearance.font.families.nerdFonts
            property string monospace: Config.runtime.appearance.font.families.monospace
            property string reading: Config.runtime.appearance.font.families.reading
            property string expressive: Config.runtime.appearance.font.families.expressive
        }
        property QtObject size: QtObject {
            property int smallest: 10
            property int smaller: 12
            property int smallie: 13
            property int small: 15
            property int normal: 16
            property int large: 17
            property int larger: 19
            property int big: 21
            property int huge: 22
            property int hugeass: 23
            property int wildass: 40
            property int title: huge

            property QtObject icon: QtObject {
                property int smallest: 10
                property int smaller: 12
                property int small: 14
                property int normal: 16
                property int large: 17
                property int larger: 19
                property int huge: 22
                property int hugeass: 23
            }
        }
    }

    syntaxHighlightingTheme: darkmode ? '#f1ebeb' : "#141333"
}
