import WebFoundation

private struct StateBindingsKey: StorageKey {
    typealias Value = TempStatesHolder
}

extension DOMElement {
    /// Own reactive inputs until the element shuts down or is released.
    var _stateBindings: TempStatesHolder {
        if let holder = storage[StateBindingsKey.self] { return holder }
        let holder = TempStatesHolder()
        storage[StateBindingsKey.self] = holder
        return holder
    }
}
