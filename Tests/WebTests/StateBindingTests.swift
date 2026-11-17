import XCTest
import Web

#if !arch(wasm32)
final class StateBindingTests: XCTestCase {
    @MainActor
    func testTemporaryMappedInputsUpdateAndReleaseWithElements() async throws {
        let selected = State(wrappedValue: false)
        var text: Div? = Div(selected.map { $0 ? "History" : "New" })
        var pane: Div? = Div().hidden(selected.map { !$0 })
        var styled: Div? = Div().display(selected.map { $0 ? DisplayType.block : .none })
        weak var weakText = text
        weak var weakPane = pane
        weak var weakStyled = styled

        selected.wrappedValue = true
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(text?.innerText, "History")
        XCTAssertNil(pane?.properties.attributes["hidden"])
        XCTAssertEqual(styled?.properties.styles["display"], "block")

        text = nil
        pane = nil
        styled = nil
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertNil(weakText)
        XCTAssertNil(weakPane)
        XCTAssertNil(weakStyled)
    }

    @MainActor
    func testHolderRetainsMappedChainUntilCancellationAndCanBeReused() {
        let holder = TempStatesHolder()
        weak var source: State<Int>?
        weak var mapped: State<String>?
        var token: StateListener?
        var received = ""
        do {
            let input = State(wrappedValue: 1)
            let output = input.map { $0 + 1 }.map { "\($0)" }
            source = input
            mapped = output
            token = output.listen { received = $0 }.hold(in: holder)
        }
        XCTAssertNotNil(source)
        XCTAssertNotNil(mapped)
        source?.wrappedValue = 2
        XCTAssertEqual(received, "3")
        token?.cancel()
        XCTAssertNil(source)
        XCTAssertNil(mapped)

        let replacement = State(wrappedValue: 0)
        replacement.listen { received = "\($0)" }.hold(in: holder)
        replacement.wrappedValue = 4
        XCTAssertEqual(received, "4")
        holder.releaseStates()
        replacement.wrappedValue = 5
        XCTAssertEqual(received, "4")

        weak var selfHeld: State<Int>?
        do {
            let input = State(wrappedValue: 0)
            selfHeld = input
            input.listen {}.hold(in: input)
        }
        XCTAssertNil(selfHeld)
    }

    @MainActor
    func testCSSReplacementAndShutdownIgnoreQueuedUpdates() async throws {
        let selected = State(wrappedValue: false)
        let element = Div().display(selected.map { $0 ? DisplayType.block : .none })
        selected.wrappedValue = true
        element.display(.flex)
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(element.properties.styles["display"], "flex")

        weak var mapped: State<Bool>?
        do {
            let hidden = selected.map { !$0 }
            mapped = hidden
            element.hidden(hidden)
        }
        element.display(selected.map { $0 ? DisplayType.block : .none })
        selected.wrappedValue = false
        element.shutdown()
        XCTAssertNil(mapped)
        let previous = element.properties.styles["display"]
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(element.properties.styles["display"], previous)
        selected.wrappedValue = true
        XCTAssertNotNil(element.properties.attributes["hidden"])
    }

    @MainActor
    func testCSSRuleBuilderAndNumericInputsRetainMappedState() async throws {
        let selected = State(wrappedValue: false)
        var rule: CSSRule? = CSSRule(Class("probe")) {
            DisplayProperty(selected.map { $0 ? DisplayType.block : .none })
        }
        weak var weakRule = rule
        let number = State(wrappedValue: 1)
        var numeric: NumericValueContainer? = NumericValueContainer(number.map { $0 + 1 })
        weak var weakNumeric = numeric
        selected.wrappedValue = true
        number.wrappedValue = 2
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertTrue(rule!.render().contains("display:block"))
        XCTAssertEqual(numeric?.description, "3")
        rule = nil
        numeric = nil
        XCTAssertNil(weakRule)
        XCTAssertNil(weakNumeric)
    }
}
#endif
