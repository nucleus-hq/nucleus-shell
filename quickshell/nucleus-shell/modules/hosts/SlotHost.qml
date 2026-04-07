pragma ComponentBehavior: Bound
import QtQuick
import qs.services

Item {
    id: root

    property string moduleId: ""

    // Signals emitted when slot state changes so SlotLoaders can react
    signal slotStateChanged(string slotId)
    signal slotInjected(string slotId)

    // Returns the URL that should be loaded for a given slot.
    // Priority: PluginBus replace-intent > slot.override > slot.source
    function resolveSource(slotId) {
        const mod = ModuleRegistry[moduleId]
        if (!mod || !mod.slots[slotId]) return ""

        const intent = PluginBus.getIntent(moduleId, slotId)
        if (intent && intent.mode === "replace") return intent.source

        const slot = mod.slots[slotId]
        return slot.override !== null ? slot.override : slot.source
    }

    // Returns false if PluginBus has a "remove" intent or slot is disabled
    function isActive(slotId) {
        const mod = ModuleRegistry[moduleId]
        if (!mod || !mod.slots[slotId]) {
            // Could be an injected slot — check PluginBus
            const inj = PluginBus.getInjectedSlot(moduleId, slotId)
            return inj !== null
        }
        const intent = PluginBus.getIntent(moduleId, slotId)
        if (intent && intent.mode === "remove") return false
        return mod.slots[slotId].active
    }

    // Resolve source for injected slots (from PluginBus only)
    function resolveInjectedSource(slotId) {
        const inj = PluginBus.getInjectedSlot(moduleId, slotId)
        return inj ? inj.source : ""
    }

    // Toggle a single slot without affecting the rest of the module
    function setSlotActive(slotId, active) {
        const mod = ModuleRegistry[moduleId]
        if (!mod || !mod.slots[slotId]) {
            console.warn("SlotHost.setSlotActive: unknown slot", moduleId, slotId)
            return
        }
        mod.slots[slotId].active = active
        root.slotStateChanged(slotId)
    }

    // Swap a slot's source at runtime without reloading the whole module
    function overrideSlot(slotId, newSource) {
        const mod = ModuleRegistry[moduleId]
        if (!mod || !mod.slots[slotId]) {
            console.warn("SlotHost.overrideSlot: unknown slot", moduleId, slotId)
            return
        }
        mod.slots[slotId].override = Qt.resolvedUrl(newSource)
        root.slotStateChanged(slotId)
    }

    // Restore a slot to its default source    // Returns ordered list of all slot IDs including plugin injections

    function resetSlot(slotId) {
        const mod = ModuleRegistry[moduleId]
        if (mod && mod.slots[slotId]) {
            mod.slots[slotId].override = null
            mod.slots[slotId].active   = true
            root.slotStateChanged(slotId)
        }
    }

    // Returns ordered list of all slot IDs including plugin injections
    function slotIds() {
        const mod    = ModuleRegistry[moduleId]
        const base   = mod ? Object.keys(mod.slots) : []
        const merged = PluginBus.mergeSlotOrder(moduleId, base)
        return merged
    }

    Connections {
        target: PluginBus
        function onIntentRegistered(mId, slotId) {
            if (mId === root.moduleId)
                root.slotStateChanged(slotId)
        }
        function onSlotInjected(mId, slotId) {
            if (mId === root.moduleId)
                root.slotInjected(slotId)
        }
    }
}