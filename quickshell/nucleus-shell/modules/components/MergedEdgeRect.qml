import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick
import QtQuick.Shapes

Item {
  id: root

  default property alias content: content.data

  property color color: Appearance.m3colors.m3background
  property real cornerRadius: 10
  property real cornerRadiusX: Math.min(cornerRadius, root.implicitWidth / 2.5)
  property real cornerRadiusY: Math.min(cornerRadius, root.implicitHeight / 2.5)

  readonly property bool anchoredTop: anchors.top === parent.top
  readonly property bool anchoredRight: anchors.right === parent.right
  readonly property bool anchoredLeft: anchors.left === parent.left
  readonly property bool anchoredBottom: anchors.bottom === parent.bottom
  readonly property bool topLeftSharp: anchoredTop && anchoredLeft
  readonly property bool topLeftRounded: !anchoredTop && !anchoredLeft
  readonly property bool topLeftMergingLeft: !anchoredTop && anchoredLeft
  readonly property bool topLeftMergingTop: anchoredTop && !anchoredLeft
  readonly property bool topRightSharp: anchoredTop && anchoredRight
  readonly property bool topRightRounded: !anchoredTop && !anchoredRight
  readonly property bool topRightMergingRight: !anchoredTop && anchoredRight
  readonly property bool topRightMergingTop: anchoredTop && !anchoredRight
  readonly property bool bottomRightSharp: anchoredBottom && anchoredRight
  readonly property bool bottomRightRounded: !anchoredBottom && !anchoredRight
  readonly property bool bottomRightMergingRight: !anchoredBottom && anchoredRight
  readonly property bool bottomRightMergingBottom: anchoredBottom && !anchoredRight
  readonly property bool bottomLeftSharp: anchoredBottom && anchoredLeft
  readonly property bool bottomLeftRounded: !anchoredBottom && !anchoredLeft
  readonly property bool bottomLeftMergingLeft: !anchoredBottom && anchoredLeft
  readonly property bool bottomLeftMergingBottom: anchoredBottom && !anchoredLeft



  /*
   * Two consecutive anchors = no rounded corner
   * One anchor followed by no anchor = outtie corner
   * No anchor followed by an anchor = outtie corner
   * No anchors twice in a row = innie corner
  */
  Shape {
    id: shape

    anchors {
      left: anchoredLeft ? root.left : undefined
      right: anchoredRight ? root.right : undefined
      top: anchoredTop ? root.top : undefined
      bottom: anchoredBottom ? root.bottom : undefined
    }

    ShapePath {
      strokeWidth: -1
      fillColor: root.color

      // Top left Corner
      startX: (topLeftRounded || topLeftMergingLeft ? cornerRadiusX : 0) + (topRightMergingRight && !topLeftMergingLeft ? cornerRadiusX : 0)
      startY: (topLeftMergingLeft ? cornerRadiusY : 0) + (topRightMergingRight && !topLeftMergingLeft ? cornerRadiusY : 0)
      // Top Right Corner
      PathLine { 
        x: root.implicitWidth - (topRightRounded || topRightMergingRight ? cornerRadiusX : 0) - (bottomRightMergingBottom && !topRightMergingTop ? cornerRadiusX : 0)
        relativeY: 0
      }
      PathArc {
          relativeX: topRightSharp ? 0 : (topRightMergingTop ? -cornerRadiusX : cornerRadiusX)
          relativeY: topRightSharp ? 0 : (topRightMergingRight ? -cornerRadiusY : cornerRadiusY)
          radiusX: topRightSharp ? 0 : cornerRadiusX
          radiusY: topRightSharp ? 0 : cornerRadiusY
          direction: topRightSharp
              ? PathArc.Clockwise
              : (topRightMergingRight || topRightMergingTop ? PathArc.Counterclockwise : PathArc.Clockwise)
      }


      // Bottom Right Corner
      PathLine {
          relativeX: 0
          y: root.implicitHeight - (bottomRightRounded || bottomRightMergingBottom ? cornerRadiusY : 0) - (bottomLeftMergingLeft && !bottomRightMergingRight ? cornerRadiusY : 0)
      }
      PathArc {
          relativeX: bottomRightSharp ? 0 : (bottomRightMergingBottom ? cornerRadiusX : -cornerRadiusX)
          relativeY: bottomRightSharp ? 0 : (bottomRightMergingRight ? -cornerRadiusY : cornerRadiusY)
          radiusX: bottomRightSharp ? 0 : cornerRadiusX
          radiusY: bottomRightSharp ? 0 : cornerRadiusY
          direction: bottomRightSharp
              ? PathArc.Clockwise
              : (bottomRightMergingBottom || bottomRightMergingRight ? PathArc.Counterclockwise : PathArc.Clockwise)
      }


      // Bottom Left Corner
      PathLine { 
        x: (bottomLeftRounded || bottomLeftMergingLeft ? cornerRadiusX : 0) + (topLeftMergingTop && !bottomLeftMergingBottom ? cornerRadiusX : 0);
        relativeY: 0;
      }
      PathArc {
        relativeX: bottomLeftMergingBottom ? cornerRadiusX : -cornerRadiusX
        relativeY: bottomLeftMergingLeft ? cornerRadiusY : -cornerRadiusY
        radiusX: bottomLeftSharp ? 0 : cornerRadiusX
        radiusY: bottomLeftSharp ? 0 : cornerRadiusY
        direction: bottomLeftMergingLeft || bottomLeftMergingBottom ? PathArc.Counterclockwise : PathArc.Clockwise
      }

      // Top Left Corner
      PathLine { 
        relativeX: 0;
        y: (topLeftRounded || topLeftMergingTop ? cornerRadiusY : 0) + (topRightMergingRight && !topLeftMergingLeft ? cornerRadiusY : 0);
      }
      PathArc {
        relativeX: topLeftMergingTop ? -cornerRadiusX : cornerRadiusX
        relativeY: topLeftMergingLeft ? cornerRadiusY : -cornerRadiusY
        radiusX: topLeftSharp ? 0 : cornerRadiusX
        radiusY: topLeftSharp ? 0 : cornerRadiusY
        direction: topLeftMergingTop || topLeftMergingLeft ? PathArc.Counterclockwise : PathArc.Clockwise
      }
    }
  }

  Rectangle {
    id: content

    color: "transparent"
    implicitWidth: root.implicitWidth
    implicitHeight: root.implicitHeight

    anchors {
      fill: shape

      left: anchoredLeft ? root.left : undefined
      right: anchoredRight ? root.right : undefined
      top: anchoredTop ? root.top : undefined
      bottom: anchoredBottom ? root.bottom : undefined
      leftMargin: topLeftMergingTop || bottomLeftMergingBottom 
        ? cornerRadiusX * 2
        : topLeftRounded || bottomLeftRounded 
          ? cornerRadiusX
          : 0
      rightMargin: topRightMergingTop || bottomRightMergingBottom 
        ? cornerRadiusX * 2
        : topRightRounded || bottomRightRounded 
          ? cornerRadiusX
          : 0
      topMargin: topLeftMergingLeft || topRightMergingRight
        ? cornerRadiusY * 2
        : topLeftRounded || topRightRounded
          ? cornerRadiusY
          : 0

      bottomMargin: bottomLeftMergingLeft || bottomRightMergingRight
        ? cornerRadiusY * 2
        : bottomLeftRounded || bottomRightRounded
          ? cornerRadiusY
          : 0
    }
  }
}