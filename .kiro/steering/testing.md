---
inclusion: always
---

# Testing Conventions

## Test Targets

| Target | File | Framework | What it covers |
|--------|------|-----------|----------------|
| `Fire Calculator IndiaTests` | `Fire_Calculator_IndiaTests.swift` | **Swift Testing** | Calculator logic, formatting, model invariants |
| `Fire Calculator IndiaUITests` | `Fire_Calculator_IndiaUITests.swift` | **XCTest / XCUITest** | Full user flow, screen navigation, element existence |

---

## Unit Tests — Swift Testing

**Framework:** `import Testing` + `@testable import Fire_Calculator_India`  
**Style:** `struct FIRECalculatorTests` with `@Test func ...()` functions. No `XCTestCase`.  
**Assertions:** `#expect(condition)` — never `XCTAssert`.

### What Is Already Tested
- FIRE number variants use correct multipliers (×20/×25/×33)
- Inflation correctly inflates the FIRE number over time
- SIP accumulation + existing corpus equals the FIRE target
- SIP is zero when existing savings already cover the FIRE number (`isAlreadyFIRE`)
- Lean FIRE SIP < FIRE SIP < Fat FIRE SIP
- Aggressive mode requires less SIP than Conservative
- Existing corpus grows at the mode's expected return
- `currentAnnualExpense` and `futureAnnualExpense` are computed correctly
- `yearsToRetirement` is always at least 1 (edge cases: same age, past retirement age)
- `.inrCompact` formats lakhs, crores, and small amounts correctly
- All `InvestmentMode` allocations sum to 1.0
- All `InvestmentMode` expected returns are in a sensible range (5%–20%)
- `FIRETarget` multipliers are ordered: Lean < FIRE < Fat

### What to Test When Adding New Features
- **New `FIREInputs` field:** Add a test verifying it changes the output correctly (isolate by zeroing other variables)
- **New `FIRECalculator` logic:** Add a test with known inputs and a hand-calculated expected output
- **New `InvestmentMode` case:** Verify allocations sum to 1.0 (the existing loop test will catch it automatically)
- **New `FIRETarget` case:** Verify multiplier ordering is preserved
- **New formatting helper:** Add a test with at least 3 representative values (boundary, typical, edge)

### What NOT to Test in Unit Tests
- SwiftUI view rendering — that belongs in UI tests
- `Color` values or hex parsing — visual, not logic
- `InvestmentCategory` content (vehicle names, tips) — copy, not logic
- `LaunchScreen` — no logic to test

### Unit Test Pattern
```swift
@Test func descriptiveNameOfWhatIsBeingVerified() {
    // Arrange — set up inputs with only the relevant variables changed
    var inputs = FIREInputs()
    inputs.someField = knownValue
    inputs.inflationRate = 0.0  // zero out unrelated variables to isolate

    // Act
    let result = FIRECalculator.calculate(inputs: inputs, mode: .balanced, target: .fire)

    // Assert — use #expect, not XCTAssert
    #expect(abs(result.someOutput - expectedValue) < 1)  // use tolerance for floating point
}
```

---

## UI Tests — XCTest / XCUITest

**Framework:** `import XCTest`, class inherits `XCTestCase`  
**Launch:** `app = XCUIApplication(); app.launch()` in `setUpWithError()`  
**Assertions:** `XCTAssertTrue`, `XCTAssertFalse` — never `#expect`

### What Is Already Tested
- InputScreen loads with all required labels, sliders, text fields, and Calculate button
- Calculate button is enabled with default values
- Tapping Calculate navigates to ResultScreen (`"Your FIRE Plan"` nav title)
- ResultScreen shows all three FIRE variant rows + all four metric grid labels
- ResultScreen shows the Adjust Retirement Age slider
- ResultScreen has the "See Investment Plan" button
- Tapping "See Investment Plan" navigates to InvestmentScreen (`"Investment Plan"` nav title)
- InvestmentScreen shows FIRE target picker (Lean FIRE / FIRE / Fat FIRE)
- InvestmentScreen shows investment style picker (Conservative / Balanced / Aggressive)
- InvestmentScreen shows Monthly SIP hero card
- InvestmentScreen shows allocation chart with all four category labels
- Tapping all FIRE target buttons does not crash
- Tapping all investment style buttons does not crash
- Back from ResultScreen returns to InputScreen
- Back from InvestmentScreen returns to ResultScreen
- Entering a new value in Monthly Expenses flows through to ResultScreen without crash

### What to Test When Adding New Features
- **New screen:** Add navigation test (tap the CTA → assert new nav title exists)
- **New interactive element (picker, toggle, slider):** Add a "does not crash" test for all states
- **New required label / section header:** Add existence assertion in the relevant screen load test
- **Back navigation from new screen:** Add a back-navigation test

### What NOT to Test in UI Tests
- Exact ₹ values displayed — they depend on inputs and will break on assumption changes
- Pixel-level layout or colors — fragile and unrelated to correctness
- Launch screen — it fades away before tests interact with the app
- Slider exact positions — XCUI slider interaction is unreliable; test existence, not value

### UI Test Helpers
`XCUIElement.clearAndEnterText(_ text: String)` is defined at the bottom of the UI test file. Use it for all text field interactions — it selects-all-delete before typing.

```swift
// Navigate to InvestmentScreen — use the private helper, don't repeat the steps
private func navigateToInvestmentScreen() {
    app.buttons["Calculate My FIRE Number"].tap()
    XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))
    app.buttons["See Investment Plan"].tap()
    XCTAssertTrue(app.navigationBars["Investment Plan"].waitForExistence(timeout: 3))
}
```

### Accessibility Labels for UI Tests
UI tests rely on visible text labels (`.staticTexts`) and button titles (`.buttons`). When adding new UI elements that need to be testable:
- Use `.accessibilityLabel("descriptive label")` if the element has no visible text
- Navigation bar titles are found via `app.navigationBars["Title"]`
- Section headers using `.textCase(.uppercase)` appear **uppercased** in the accessibility tree (e.g. `"FIRE TARGET"` not `"Fire Target"`)

---

## Running Tests

```bash
# Unit tests only
xcodebuild test -scheme "Fire Calculator India" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing "Fire Calculator IndiaTests"

# UI tests only
xcodebuild test -scheme "Fire Calculator India" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing "Fire Calculator IndiaUITests"
```

Or use **⌘U** in Xcode to run all tests.
