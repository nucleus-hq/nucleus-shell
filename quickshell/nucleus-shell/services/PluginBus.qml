pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick

// PluginBus is the safe boundary between plugins and the module slot system.
// Plugins never hold references to loaders or SlotHosts.
// They only publish intents here; SlotHost reads and applies them.
QtObject {
    id: root

    // Keyed by "moduleId:slotId"
    // Intent shape: { mode: "replace"|"remove", source: url (replace only) }
    property var _intents: ({})

    // Keyed by moduleId → Array of { slotId, source, after }
    property var _injections: ({})

    signal intentRegistered(string moduleId, string slotId)
    signal slotInjected(string moduleId, string slotId)
    signal intentCleared(string moduleId, string slotId)


    // Replace or remove an existing slot.
    // mode "replace": load newSource instead of the slot's default
    // mode "remove":  disable the slot entirely (SlotLoader won't load it)
    function hookSlot(moduleId, slotId, intent) {
        if (!intent || !intent.mode) {
            console.warn("PluginBus.hookSlot: intent must have a mode property")
            return
        }
        if (intent.mode === "replace" && !intent.source) {
            console.warn("PluginBus.hookSlot: replace intent requires a source")
            return
        }
        const key = moduleId + ":" + slotId
        _intents[key] = {
            mode:   intent.mode,
            source: intent.source ? Qt.resolvedUrl(intent.source) : ""
        }
        root.intentRegistered(moduleId, slotId)
    }

    // Inject a completely new slot into a module.
    // after: slotId to insert after (null = append at end)
    function injectSlot(moduleId, slotId, opts) {
        if (!opts || !opts.source) {
            console.warn("PluginBus.injectSlot: opts must have a source property")
            return
        }
        if (!_injections[moduleId]) _injections[moduleId] = []

        // Prevent duplicate injection
        const existing = _injections[moduleId].findIndex(i => i.slotId === slotId)
        if (existing >= 0) {
            _injections[moduleId][existing] = {
                slotId: slotId,
                source: Qt.resolvedUrl(opts.source),
                after:  opts.after ?? null
            }
        } else {
            _injections[moduleId].push({
                slotId: slotId,
                source: Qt.resolvedUrl(opts.source),
                after:  opts.after ?? null
            })
        }
        root.slotInjected(moduleId, slotId)
    }

    // Remove a previously registered intent
    function clearIntent(moduleId, slotId) {
        const key = moduleId + ":" + slotId
        if (_intents[key]) {
            delete _intents[key]
            root.intentCleared(moduleId, slotId)
        }
    }

    // Remove a previously injected slot
    function removeInjectedSlot(moduleId, slotId) {
        if (!_injections[moduleId]) return
        const idx = _injections[moduleId].findIndex(i => i.slotId === slotId)
        if (idx >= 0) {
            _injections[moduleId].splice(idx, 1)
            root.intentCleared(moduleId, slotId)
        }
    }

    // ── SlotHost query API (internal — called by SlotHost, not plugins) ────

    function getIntent(moduleId, slotId) {
        return _intents[moduleId + ":" + slotId] ?? null
    }

    function getInjectedSlot(moduleId, slotId) {
        const list = _injections[moduleId] ?? []
        return list.find(i => i.slotId === slotId) ?? null
    }

    function injectedSlots(moduleId) {
        return _injections[moduleId] ?? []
    }

    // Merge base slot order with plugin injections, respecting "after" hints
    function mergeSlotOrder(moduleId, baseSlotIds) {
        const injected = _injections[moduleId] ?? []
        const result   = [...baseSlotIds]

        for (const inj of injected) {
            if (result.includes(inj.slotId)) continue   // already in list
            const afterIdx = inj.after ? result.indexOf(inj.after) : -1
            if (afterIdx >= 0) {
                result.splice(afterIdx + 1, 0, inj.slotId)
            } else {
                result.push(inj.slotId)
            }
        }

        return result
    }
}