import XCTest

// MARK: - FIRE Calculator UI Tests
//
// These tests cover the full user flow:
//   1. App launches showing InputScreen
//   2. User can interact with sliders and text fields
//   3. Tapping "Calculate" navigates to ResultScreen
//   4. ResultScreen shows correct screen elements
//   5. "See Investment Plan" navigates to InvestmentScreen
//   6. Investment pickers are interactive
//   7. Back navigation returns to previous screens

final class Fire_Calculator_IndiaUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch & Input Screen

    /// App opens on the InputScreen and shows the key UI elements.
    @MainActor
    func testInputScreenLoadsWithRequiredElements() throws {
        // Navigation title
        XCTAssertTrue(app.navigationBars["FIRE Calculator"].exists)

        // Header banner text
        XCTAssertTrue(app.staticTexts["Financial Independence, Retire Early"].exists)

        // Section headers (label text from section() builder)
        XCTAssertTrue(app.staticTexts["Personal Details"].exists)
        XCTAssertTrue(app.staticTexts["Financial Details"].exists)
        XCTAssertTrue(app.staticTexts["Assumptions"].exists)

        // Slider labels
        XCTAssertTrue(app.staticTexts["Current Age"].exists)
        XCTAssertTrue(app.staticTexts["Target Retirement Age"].exists)
        XCTAssertTrue(app.staticTexts["Inflation Rate"].exists)

        // Currency row labels
        XCTAssertTrue(app.staticTexts["Monthly Expenses"].exists)
        XCTAssertTrue(app.staticTexts["Existing Savings"].exists)

        // Calculate button
        XCTAssertTrue(app.buttons["Calculate My FIRE Number"].exists)
    }

    /// The Calculate button is enabled on launch (default values are valid).
    @MainActor
    func testCalculateButtonIsEnabledByDefault() throws {
        let button = app.buttons["Calculate My FIRE Number"]
        XCTAssertTrue(button.isEnabled)
    }

    /// Tapping Calculate navigates to the ResultScreen.
    @MainActor
    func testTappingCalculateNavigatesToResultScreen() throws {
        app.buttons["Calculate My FIRE Number"].tap()

        let resultNav = app.navigationBars["Your FIRE Plan"]
        XCTAssertTrue(resultNav.waitForExistence(timeout: 3))
    }

    // MARK: - Result Screen

    /// ResultScreen displays the key structural elements.
    @MainActor
    func testResultScreenShowsFireNumbers() throws {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))

        // FIRE variants card heading
        XCTAssertTrue(app.staticTexts["Your FIRE Numbers"].exists)

        // Three variant row labels
        XCTAssertTrue(app.staticTexts["Lean FIRE"].exists)
        XCTAssertTrue(app.staticTexts["FIRE"].exists)
        XCTAssertTrue(app.staticTexts["Fat FIRE"].exists)

        // Metrics grid labels
        XCTAssertTrue(app.staticTexts["Years to FIRE"].exists)
        XCTAssertTrue(app.staticTexts["Monthly SIP"].exists)
        XCTAssertTrue(app.staticTexts["Total Corpus"].exists)
        XCTAssertTrue(app.staticTexts["Existing Grows to"].exists)
    }

    /// ResultScreen shows the Adjust Retirement Age slider.
    @MainActor
    func testResultScreenShowsAdjustSlider() throws {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))

        XCTAssertTrue(app.staticTexts["Adjust Retirement Age"].exists)
        XCTAssertTrue(app.staticTexts["Retire at age"].exists)
    }

    /// The sticky "See Investment Plan" button is present on the ResultScreen.
    @MainActor
    func testResultScreenHasSeeInvestmentPlanButton() throws {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))

        XCTAssertTrue(app.buttons["See Investment Plan"].exists)
    }

    /// Tapping "See Investment Plan" navigates to InvestmentScreen.
    @MainActor
    func testTappingSeeInvestmentPlanNavigatesToInvestmentScreen() throws {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))

        app.buttons["See Investment Plan"].tap()

        let investNav = app.navigationBars["Investment Plan"]
        XCTAssertTrue(investNav.waitForExistence(timeout: 3))
    }

    // MARK: - Investment Screen

    /// InvestmentScreen displays all three FIRE target buttons.
    @MainActor
    func testInvestmentScreenShowsFIRETargetPicker() throws {
        navigateToInvestmentScreen()

        // .textCase(.uppercase) renders the header as uppercase in the accessibility tree.
        XCTAssertTrue(app.staticTexts["FIRE TARGET"].waitForExistence(timeout: 3))
        // Picker button labels: rawValue strings rendered as-is inside VStack buttons.
        XCTAssertTrue(app.staticTexts["Lean FIRE"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Fat FIRE"].waitForExistence(timeout: 2))
    }

    /// InvestmentScreen displays all three investment style buttons.
    @MainActor
    func testInvestmentScreenShowsInvestmentStylePicker() throws {
        navigateToInvestmentScreen()

        // .textCase(.uppercase) renders the header as uppercase in the accessibility tree.
        XCTAssertTrue(app.staticTexts["INVESTMENT STYLE"].waitForExistence(timeout: 3))
        // Picker button labels: rawValue strings rendered as-is inside VStack buttons.
        XCTAssertTrue(app.staticTexts["Conservative"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Balanced"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Aggressive"].waitForExistence(timeout: 2))
    }

    /// InvestmentScreen shows the Monthly SIP hero card.
    @MainActor
    func testInvestmentScreenShowsMonthlySIPCard() throws {
        navigateToInvestmentScreen()

        XCTAssertTrue(app.staticTexts["Monthly SIP Required"].exists)
    }

    /// InvestmentScreen shows the allocation chart section.
    @MainActor
    func testInvestmentScreenShowsAllocationChart() throws {
        navigateToInvestmentScreen()

        XCTAssertTrue(app.staticTexts["Recommended Allocation"].exists)
        // Category legend labels
        XCTAssertTrue(app.staticTexts["Equity"].exists)
        XCTAssertTrue(app.staticTexts["Debt"].exists)
        XCTAssertTrue(app.staticTexts["Gold"].exists)
        XCTAssertTrue(app.staticTexts["Emergency"].exists)
    }

    /// Tapping a FIRE target button updates the selected state (no crash).
    @MainActor
    func testTappingFIRETargetButtonDoesNotCrash() throws {
        navigateToInvestmentScreen()

        app.buttons["Lean FIRE"].tap()
        app.buttons["Fat FIRE"].tap()
        app.buttons["FIRE"].tap()

        // If we reach here without a crash the test passes.
        XCTAssertTrue(app.navigationBars["Investment Plan"].exists)
    }

    /// Tapping an investment style button updates the mode (no crash).
    @MainActor
    func testTappingInvestmentStyleButtonDoesNotCrash() throws {
        navigateToInvestmentScreen()

        app.buttons["Conservative"].tap()
        app.buttons["Aggressive"].tap()
        app.buttons["Balanced"].tap()

        XCTAssertTrue(app.navigationBars["Investment Plan"].exists)
    }

    // MARK: - Back Navigation

    /// Back from ResultScreen returns to InputScreen.
    @MainActor
    func testBackFromResultScreenReturnsToInputScreen() throws {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))

        app.navigationBars.buttons.firstMatch.tap()

        XCTAssertTrue(app.navigationBars["FIRE Calculator"].waitForExistence(timeout: 3))
    }

    /// Back from InvestmentScreen returns to ResultScreen.
    @MainActor
    func testBackFromInvestmentScreenReturnsToResultScreen() throws {
        navigateToInvestmentScreen()

        app.navigationBars.buttons.firstMatch.tap()

        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))
    }

    // MARK: - Input Field Interaction

    /// Clearing Monthly Expenses and entering a new value shows the result without crashing.
    @MainActor
    func testEnteringMonthlyExpensesFlowsThrough() throws {
        let expensesField = app.textFields["0"].firstMatch
        expensesField.tap()
        expensesField.clearAndEnterText("75000")

        // Dismiss keyboard and calculate
        app.buttons["Calculate My FIRE Number"].tap()

        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))
    }

    // MARK: - FIRE Progress Screen

    /// Navigating through InvestmentScreen to ProgressScreen shows the correct nav title.
    @MainActor
    func testProgressScreenLoads() throws {
        navigateToProgressScreen()
        XCTAssertTrue(app.navigationBars["FIRE Progress"].exists)
    }

    /// ProgressScreen shows the Corpus Progress bar card.
    @MainActor
    func testProgressScreenShowsProgressBarCard() throws {
        navigateToProgressScreen()
        // .textCase(.uppercase) → "CORPUS PROGRESS" in accessibility tree
        XCTAssertTrue(app.staticTexts["CORPUS PROGRESS"].waitForExistence(timeout: 3))
    }

    /// ProgressScreen shows the FIRE target picker.
    @MainActor
    func testProgressScreenShowsFIRETargetPicker() throws {
        navigateToProgressScreen()
        XCTAssertTrue(app.staticTexts["FIRE TARGET"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lean FIRE"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Fat FIRE"].waitForExistence(timeout: 2))
    }

    /// ProgressScreen shows the investment style picker.
    @MainActor
    func testProgressScreenShowsInvestmentStylePicker() throws {
        navigateToProgressScreen()
        XCTAssertTrue(app.staticTexts["INVESTMENT STYLE"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Conservative"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Balanced"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Aggressive"].waitForExistence(timeout: 2))
    }

    /// ProgressScreen shows corpus breakdown and timeline cards.
    @MainActor
    func testProgressScreenShowsCorpusAndTimelineCards() throws {
        navigateToProgressScreen()
        // Scroll down to reveal cards below the pickers
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["CORPUS BREAKDOWN"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["TIMELINE"].waitForExistence(timeout: 3))
    }

    /// ProgressScreen shows the motivational status card.
    @MainActor
    func testProgressScreenShowsStatusCard() throws {
        navigateToProgressScreen()
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["MOTIVATIONAL STATUS"].waitForExistence(timeout: 3))
    }

    /// Tapping FIRE target buttons on ProgressScreen does not crash.
    @MainActor
    func testProgressScreenFIRETargetPickerDoesNotCrash() throws {
        navigateToProgressScreen()
        app.staticTexts["Lean FIRE"].tap()
        app.staticTexts["Fat FIRE"].tap()
        app.staticTexts["FIRE"].tap()
        XCTAssertTrue(app.navigationBars["FIRE Progress"].exists)
    }

    /// Tapping investment style buttons on ProgressScreen does not crash.
    @MainActor
    func testProgressScreenInvestmentStylePickerDoesNotCrash() throws {
        navigateToProgressScreen()
        app.staticTexts["Conservative"].tap()
        app.staticTexts["Aggressive"].tap()
        app.staticTexts["Balanced"].tap()
        XCTAssertTrue(app.navigationBars["FIRE Progress"].exists)
    }

    /// Back from ProgressScreen returns to InvestmentScreen.
    @MainActor
    func testBackFromProgressScreenReturnsToInvestmentScreen() throws {
        navigateToProgressScreen()
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Investment Plan"].waitForExistence(timeout: 3))
    }

    // MARK: - Helpers

    private func navigateToInvestmentScreen() {
        app.buttons["Calculate My FIRE Number"].tap()
        XCTAssertTrue(app.navigationBars["Your FIRE Plan"].waitForExistence(timeout: 3))
        app.buttons["See Investment Plan"].tap()
        XCTAssertTrue(app.navigationBars["Investment Plan"].waitForExistence(timeout: 3))
    }

    private func navigateToProgressScreen() {
        navigateToInvestmentScreen()
        // "View FIRE Progress" is a NavigationLink — accessible as a staticText inside it
        app.swipeUp()
        app.staticTexts["View FIRE Progress"].tap()
        XCTAssertTrue(app.navigationBars["FIRE Progress"].waitForExistence(timeout: 3))
    }
}

// MARK: - XCUIElement helper

extension XCUIElement {
    /// Clears existing text and types new text into a text field.
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            typeText(text)
            return
        }
        // Select all and delete
        let deleteCount = stringValue.count
        if deleteCount > 0 {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: deleteCount)
            typeText(deleteString)
        }
        typeText(text)
    }
}
