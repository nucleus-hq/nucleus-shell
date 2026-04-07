pragma ComponentBehavior: Bound
import QtQuick

// Root must be Item for the same reason as ModuleLoader.
Item {
    id: root

    property string   slotId:      ""
    property SlotHost host:        null
    property bool     forceActive: false

    readonly property alias item:   _loader.item
    readonly property alias status: _loader.status

    property url  _liveSource: ""
    property bool _shouldBeActive: (host !== null && host.isActive(slotId)) || forceActive

    onForceActiveChanged: _sync()

    function _sync() {
        if (_shouldBeActive) {
            const src = _resolveSource()
            if (src !== "") _liveSource = src
        } else {
            _liveSource = ""
        }
    }

    function _resolveSource() {
        if (!host) return ""
        const src = host.resolveSource(slotId)
        if (src !== "") return src
        return host.resolveInjectedSource(slotId)
    }

    Connections {
        target: root.host
        function onSlotStateChanged(id) {
            if (id === root.slotId) root._sync()
        }
        function onSlotInjected(id) {
            if (id === root.slotId) root._sync()
        }
    }

    Component.onCompleted: _sync()

    Loader {
        id: _loader
        anchors.fill: parent
        source:       root._liveSource
        active:       root._shouldBeActive && root._liveSource !== ""
        asynchronous: true

        onStatusChanged: {
            if (status === Loader.Error)
                console.warn("SlotLoader [" + root.slotId + "] failed:", source)
        }
    }
}