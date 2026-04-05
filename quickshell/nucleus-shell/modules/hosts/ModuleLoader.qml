pragma ComponentBehavior: Bound
import QtQuick

// Root must be Item, not QtObject.
// QtObject has no visual tree, so child Loader IDs are invisible to alias.
Item {
    id: root

    property string moduleId: ""
    property url    source
    property bool   enabled:  true

    // Expose loaded item and status for external inspection
    readonly property alias item:   _loader.item
    readonly property alias status: _loader.status

    signal moduleActivated(string id)
    signal moduleWillDeactivate(string id)
    signal moduleReady(string id)

    // "dormant" | "activating" | "active" | "deactivating"
    property string _state: "dormant"

    // The Loader watches _liveSource exclusively.
    // Nulling then restoring it guarantees a real value change,
    // fixing the resurrection bug (active: false → true with same source).
    property url _liveSource: ""

    function activate() {
        if (_state === "active" || _state === "activating") return
        _state = "activating"
        _liveSource = source
        _state = "active"
        root.moduleActivated(moduleId)
    }

    function deactivate() {
        if (_state === "dormant" || _state === "deactivating") return
        root.moduleWillDeactivate(moduleId)
        _state = "deactivating"
        _liveSource = ""
        Qt.callLater(() => {
            if (_state === "deactivating")
                _state = "dormant"
        })
    }

    function refresh() {
        const s = source
        _liveSource = ""
        Qt.callLater(() => { _liveSource = s })
    }

    onEnabledChanged: enabled ? activate() : deactivate()
    onSourceChanged:  { if (_state === "active") refresh() }
    Component.onCompleted: { if (enabled) activate() }

    // Declared as a direct child of Item — alias can now resolve _loader.
    Loader {
        id: _loader
        anchors.fill: parent
        source:       root._liveSource
        active:       root._state === "active"
        asynchronous: true

        onStatusChanged: {
            if (status === Loader.Ready)
                root.moduleReady(root.moduleId)
            if (status === Loader.Error)
                console.warn("ModuleLoader [" + root.moduleId + "] failed:", source)
        }
    }
}