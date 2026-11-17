//
//  ForEach.swift
//  
//
//  Created by Mihael Isaev on 31.12.2022.
//

public class ForEach<Item>: BaseElement, ScrollHandleable, AlignAttrable where Item: Hashable {
    nonisolated public override class var name: String { Div.name }
    
    public typealias Handler = @MainActor (Int, Item) -> DOMContent
    public typealias HandlerValue = @MainActor (Item) -> DOMContent
    public typealias HandlerSimple = @MainActor () -> DOMContent
    
    let items: State<[Item]>
    let block: Handler
    
    required public init() {
        self.items = State(wrappedValue: [])
        self.block = { _,_ in
            DOM.none
        }
        super.init()
        _postInit()
    }
    
    public init (_ items: [Item], @DOM block: @escaping Handler) {
        self.items = State(wrappedValue: items)
        self.block = block
        super.init()
        _postInit()
    }
    
    public init (_ items: [Item], @DOM block: @escaping HandlerValue) {
        self.items = State(wrappedValue: items)
        self.block = { _, v in
            block(v)
        }
        super.init()
        _postInit()
    }
    
    public init (_ items: [Item], @DOM block: @escaping HandlerSimple) {
        self.items = State(wrappedValue: items)
        self.block = { _,_ in
            block()
        }
        super.init()
        _postInit()
    }
    
    public init (_ items: State<[Item]>, @DOM block: @escaping Handler) {
        self.items = items
        self.block = block
        super.init()
        _postInit()
    }
    
    public init (_ items: State<[Item]>, @DOM block: @escaping HandlerValue) {
        self.items = items
        self.block = { _, v in
            block(v)
        }
        super.init()
        _postInit()
    }
    
    public init (_ items: State<[Item]>, @DOM block: @escaping HandlerSimple) {
        self.items = items
        self.block = { _,_ in
            block()
        }
        super.init()
        _postInit()
    }
    
    private var addedToDOM = false
    
    func _postInit() {
        onDidAddToDOM { [weak self] in
            guard let self, !self.addedToDOM else { return }
            self.addedToDOM = true
            self.renderItems(self.items.wrappedValue)
            self.items.listen { [weak self] _, _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.renderItems(self.items.wrappedValue)
                }
            }
        }
    }

    @MainActor
    private func renderItems(_ snapshot: [Item]) {
        for child in Array(properties.subElements) {
            child.remove()
        }
        #if !arch(wasm32)
        properties.subElements.removeAll()
        #endif

        for (index, item) in snapshot.enumerated() {
            parseDOMItem(block(index, item).domContentItem)
        }
    }
    
    func parseDOMItem(_ item: DOMItem) {
        switch item {
        case .elements(let elements): elements.forEach { appendChild($0) }
        case .items(let items): items.forEach { parseDOMItem($0) }
        case .print(let print): Console.log(print.items)
        case .none: break
        }
    }
    
}

extension ForEach where Item == Int {
    @MainActor
    public convenience init (_ items: ClosedRange<Item>, @DOM block: @escaping Handler) {
        self.init(items.map { $0 }, block: block)
    }
    
    @MainActor
    public convenience init (_ items: ClosedRange<Item>, @DOM block: @escaping HandlerValue) {
        self.init(items.map { $0 }, block: block)
    }
    
    @MainActor
    public convenience init (_ items: ClosedRange<Item>, @DOM block: @escaping HandlerSimple) {
        self.init(items.map { $0 }, block: block)
    }
}

extension Int {
    @MainActor
    public func times(@DOM block: @escaping ForEach<Int>.Handler, file: StaticString = #fileID, line: UInt = #line) -> ForEach<Int> {
        assert(self >= 2, "Should be 2 times and more", file: file, line: line)
        return .init(0...(self - 1), block: block)
    }
    
    @MainActor
    public func times(@DOM block: @escaping ForEach<Int>.HandlerValue, file: StaticString = #fileID, line: UInt = #line) -> ForEach<Int> {
        assert(self >= 2, "Should be 2 times and more", file: file, line: line)
        return .init(0...(self - 1), block: block)
    }
    
    @MainActor
    public func times(@DOM block: @escaping ForEach<Int>.HandlerSimple, file: StaticString = #fileID, line: UInt = #line) -> ForEach<Int> {
        assert(self >= 2, "Should be 2 times and more", file: file, line: line)
        return .init(0...(self - 1), block: block)
    }
}

// TODO: move to separate file

public class BuilderFunction: DOMContent {
    @MainActor
    public var domContentItem: DOMItem { .items([content.domContentItem]) }
    
    let content: DOMContent

    public typealias Content<Value> = @MainActor (Value) -> DOMContent
    
    @MainActor public init (_ valueToPass: String, @DOM content: @escaping Content<String>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Int8, @DOM content: @escaping Content<Int8>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Int16, @DOM content: @escaping Content<Int16>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Int32, @DOM content: @escaping Content<Int32>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Int64, @DOM content: @escaping Content<Int64>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Double, @DOM content: @escaping Content<Double>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: Float, @DOM content: @escaping Content<Float>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: UInt8, @DOM content: @escaping Content<UInt8>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: UInt16, @DOM content: @escaping Content<UInt16>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: UInt32, @DOM content: @escaping Content<UInt32>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init (_ valueToPass: UInt64, @DOM content: @escaping Content<UInt64>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init <Element>(_ valueToPass: Array<Element>, @DOM content: @escaping Content<Array<Element>>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init <Key, Value>(_ valueToPass: Dictionary<Key, Value>, @DOM content: @escaping Content<Dictionary<Key, Value>>) {
        self.content = content(valueToPass)
    }
    
    @MainActor public init <Result>(_ beforeRender: () -> Result, @DOM content: Content<Result>) {
        self.content = content(beforeRender())
    }
}
