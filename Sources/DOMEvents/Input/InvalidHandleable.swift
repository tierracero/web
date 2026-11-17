//
//  InvalidHandleable.swift
//  DOMEvents
//
//  Created by Mihael Isaev on 29.11.2020.
//

public protocol InvalidHandleable: DOMEventable {
    @discardableResult
    func onInvalid(_ handler: @escaping @MainActor () -> Void) -> Self
}

fileprivate class InvalidContainer: Container<Event>, StorageKey {
    typealias Value = InvalidContainer
}

extension InvalidHandleable {
    /// The oninvalid event occurs when a submittable `<input>` element is invalid.
    ///
    /// Applicable to `<input>`
    ///
    /// [More info →](https://www.w3schools.com/jsref/event_oninvalid.asp)
    @discardableResult
    public func onInvalid(_ handler: @escaping @MainActor (Event, Self) -> Void) -> Self {
        setDOMHandlerIfNeeded("oninvalid", createOrUpdate(InvalidContainer.self) { [weak self] in
            guard let self = self else { return }
            handler($0, self)
        })
    }
    
    /// The oninvalid event occurs when a submittable `<input>` element is invalid.
    @discardableResult
    public func onInvalid(_ handler: @escaping @MainActor (Event) -> Void) -> Self {
        onInvalid { event, _ in
            handler(event)
        }
    }
    
    /// The oninvalid event occurs when a submittable `<input>` element is invalid.
    @discardableResult
    public func onInvalid(_ handler: @escaping @MainActor () -> Void) -> Self {
        onInvalid { _ in handler() }
    }
}
