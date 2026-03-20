pragma Singleton
import QtQuick
import Quickshell

/**
 * Visibilities: per-screen visibility state registry.
 *
 * barPanels: map of screenName → bar panel object.
 *   Bar windows can register themselves here so the dock can read
 *   their `pinned` state to coordinate exclusive zones.
 *   Falls back gracefully (barPinned = true) when not registered.
 *
 * getForScreen(screenName): lazily returns a per-screen QtObject with:
 *   overview: bool  (toggled by the dock's overview button)
 */
Singleton {
    id: root

    property var barPanels: ({})
    property var _screenStates: ({})

    function getForScreen(screenName) {
        if (!root._screenStates[screenName]) {
            root._screenStates[screenName] = stateFactory.createObject(root, { screenName: screenName })
            root._screenStatesChanged()
        }
        return root._screenStates[screenName]
    }

    Component {
        id: stateFactory
        QtObject {
            property string screenName: ""
            property bool overview: false
        }
    }
}
