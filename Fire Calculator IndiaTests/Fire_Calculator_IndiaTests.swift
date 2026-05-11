import Testing
import Foundation
@testable import Fire_Calculator_India

// MARK: - FIRE Calculator Unit Tests

struct FIRECalculatorTests {

    // MARK: - FIRE Number Variants

    @Test func fireNumberUsesCorrectMultipliers() {
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 50_000
        inputs.inflationRate = 0.0   // zero inflation to isolate multiplier logic
        inputs.currentAge = 30
        inputs.retirementAge = 31    // 1 year — minimal compounding

        let result = FIRECalculator.calculate(inputs: inputs)
        let annualExpense = 50_000.0 * 12.0

        // With 0% inflation, futureAnnual == currentAnnual
        #expect(abs(result.leanFIRE   - annualExpense * 20) < 1)
        #expect(abs(result.fireNumber - annualExpense * 25) < 1)
        #expect(abs(result.fatFIRE    - annualExpense * 33) < 1)
    }

    @Test func inflationCorrectlyIncreasesFireNumber() {
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 50_000
        inputs.inflationRate = 0.06
        inputs.currentAge = 30
        inputs.retirementAge = 40    // 10 years
        inputs.existingSavings = 0

        let result = FIRECalculator.calculate(inputs: inputs)
        let expectedFutureAnnual = 50_000 * 12.0 * pow(1.06, 10.0)
        let expectedFIRE = expectedFutureAnnual * 25.0

        #expect(abs(result.fireNumber - expectedFIRE) < 1)
    }

    // MARK: - SIP Calculation

    @Test func sipAccumulationMatchesFireNumber() {
        // If SIP is invested monthly, existing + SIP accumulation must equal FIRE number
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 50_000
        inputs.inflationRate = 0.06
        inputs.currentAge = 30
        inputs.retirementAge = 45
        inputs.existingSavings = 5_00_000

        let result = FIRECalculator.calculate(inputs: inputs, mode: .balanced, target: .fire)

        // totalCorpusAtRetirement = existingGrowth + SIPaccumulation must equal fireNumber
        #expect(abs(result.totalCorpusAtRetirement - result.fireNumber) < 10)
    }

    @Test func sipIsZeroWhenAlreadyFIRE() {
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 10_000   // very low expenses
        inputs.existingSavings = 100_00_00_000  // ₹100 Cr — way more than needed
        inputs.currentAge = 30
        inputs.retirementAge = 45

        let result = FIRECalculator.calculate(inputs: inputs)

        #expect(result.monthlySIPNeeded == 0)
        #expect(result.isAlreadyFIRE == true)
        #expect(result.shortfall == 0)
    }

    @Test func sipForLeanFireIsLessThanFire() {
        // Lean FIRE needs a smaller corpus, so SIP should be lower
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 50_000
        inputs.existingSavings = 0
        inputs.currentAge = 30
        inputs.retirementAge = 45

        let leanResult = FIRECalculator.calculate(inputs: inputs, mode: .balanced, target: .lean)
        let fireResult = FIRECalculator.calculate(inputs: inputs, mode: .balanced, target: .fire)
        let fatResult  = FIRECalculator.calculate(inputs: inputs, mode: .balanced, target: .fat)

        #expect(leanResult.monthlySIPNeeded < fireResult.monthlySIPNeeded)
        #expect(fireResult.monthlySIPNeeded < fatResult.monthlySIPNeeded)
    }

    @Test func aggressiveModeRequiresLessSIPThanConservative() {
        // Higher return = less SIP needed for same target
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 50_000
        inputs.existingSavings = 0
        inputs.currentAge = 30
        inputs.retirementAge = 45

        let conservative = FIRECalculator.calculate(inputs: inputs, mode: .conservative)
        let aggressive   = FIRECalculator.calculate(inputs: inputs, mode: .aggressive)

        #expect(aggressive.monthlySIPNeeded < conservative.monthlySIPNeeded)
    }

    // MARK: - Corpus Projections

    @Test func existingCorpusGrowsAtExpectedReturn() {
        var inputs = FIREInputs()
        inputs.existingSavings = 10_00_000  // ₹10L
        inputs.currentAge = 30
        inputs.retirementAge = 40           // 10 years

        let result = FIRECalculator.calculate(inputs: inputs, mode: .balanced)
        let expected = 10_00_000.0 * pow(1.12, 10.0)

        #expect(abs(result.existingCorpusAtRetirement - expected) < 1)
    }

    // MARK: - Expense Projections

    @Test func currentAndFutureExpensesAreCorrect() {
        var inputs = FIREInputs()
        inputs.monthlyExpenses = 60_000
        inputs.inflationRate = 0.06
        inputs.currentAge = 30
        inputs.retirementAge = 40  // 10 years

        let result = FIRECalculator.calculate(inputs: inputs)

        #expect(abs(result.currentAnnualExpense - 60_000 * 12) < 1)
        let expectedFutureAnnual = 60_000 * 12.0 * pow(1.06, 10.0)
        #expect(abs(result.futureAnnualExpense - expectedFutureAnnual) < 1)
    }

    // MARK: - Edge Cases

    @Test func yearsToRetirementIsAtLeastOne() {
        var inputs = FIREInputs()
        inputs.currentAge = 40
        inputs.retirementAge = 40  // same age

        let result = FIRECalculator.calculate(inputs: inputs)
        #expect(result.yearsToRetirement >= 1)
    }

    @Test func yearsToRetirementWithRetirementBeforeCurrentAge() {
        var inputs = FIREInputs()
        inputs.currentAge = 50
        inputs.retirementAge = 30  // past

        let result = FIRECalculator.calculate(inputs: inputs)
        #expect(result.yearsToRetirement >= 1)
    }

    // MARK: - Formatting

    @Test func inrCompactFormatsLakhs() {
        #expect((1_50_000.0).inrCompact == "₹1.50 L")
        #expect((10_00_000.0).inrCompact == "₹10.00 L")
    }

    @Test func inrCompactFormatsCrores() {
        #expect((1_00_00_000.0).inrCompact == "₹1.00 Cr")
        #expect((12_50_00_000.0).inrCompact == "₹12.50 Cr")
    }

    @Test func inrCompactFormatsSmallAmounts() {
        #expect((500.0).inrCompact == "₹500")
        #expect((99_999.0).inrCompact == "₹99999")
    }

    // MARK: - Investment Mode

    @Test func investmentModeAllocationsAddUpToOne() {
        for mode in InvestmentMode.allCases {
            let a = mode.allocations
            let total = a.equity + a.debt + a.gold + a.emergency
            #expect(abs(total - 1.0) < 0.0001, "Allocations for \(mode.rawValue) don't sum to 1")
        }
    }

    @Test func investmentModeReturnsAreInExpectedRange() {
        for mode in InvestmentMode.allCases {
            #expect(mode.expectedReturn > 0.05)
            #expect(mode.expectedReturn < 0.20)
        }
    }

    // MARK: - FIRE Target

    @Test func fireTargetMultipliersAreOrdered() {
        #expect(FIRETarget.lean.multiplier < FIRETarget.fire.multiplier)
        #expect(FIRETarget.fire.multiplier < FIRETarget.fat.multiplier)
    }
}
