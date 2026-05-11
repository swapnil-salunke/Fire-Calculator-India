import Foundation
import SwiftUI

// MARK: - Investment Mode

enum InvestmentMode: String, CaseIterable {
    case conservative = "Conservative"
    case balanced     = "Balanced"
    case aggressive   = "Aggressive"

    // Equity / Debt / Gold / Emergency allocation fractions
    var allocations: (equity: Double, debt: Double, gold: Double, emergency: Double) {
        switch self {
        case .conservative: return (0.40, 0.45, 0.10, 0.05)
        case .balanced:     return (0.60, 0.25, 0.10, 0.05)
        case .aggressive:   return (0.80, 0.10, 0.05, 0.05)
        }
    }

    // Blended expected annual return for each mode
    var expectedReturn: Double {
        switch self {
        case .conservative: return 0.09   // 9%  — debt-heavy
        case .balanced:     return 0.12   // 12% — standard Indian equity mix
        case .aggressive:   return 0.14   // 14% — equity-heavy
        }
    }

    var icon: String {
        switch self {
        case .conservative: return "shield.fill"
        case .balanced:     return "scalemass.fill"
        case .aggressive:   return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .conservative: return .fireEmerald
        case .balanced:     return .fireIndigo
        case .aggressive:   return .fireRose
        }
    }

    var description: String {
        switch self {
        case .conservative: return "Lower risk · 9% return · 40% equity"
        case .balanced:     return "Moderate risk · 12% return · 60% equity"
        case .aggressive:   return "Higher risk · 14% return · 80% equity"
        }
    }
}

// MARK: - FIRE Target

enum FIRETarget: String, CaseIterable {
    case lean = "Lean FIRE"
    case fire = "FIRE"
    case fat  = "Fat FIRE"

    var multiplier: Double {
        switch self {
        case .lean: return 20.0
        case .fire: return 25.0
        case .fat:  return 33.0
        }
    }

    var withdrawalRate: String {
        switch self {
        case .lean: return "5% SWR"
        case .fire: return "4% SWR"
        case .fat:  return "3% SWR"
        }
    }

    var icon: String {
        switch self {
        case .lean: return "leaf.fill"
        case .fire: return "flame.fill"
        case .fat:  return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .lean: return .fireSky
        case .fire: return .fireIndigo
        case .fat:  return .firePurple
        }
    }

    var description: String {
        switch self {
        case .lean: return "Minimal lifestyle · ×20 corpus"
        case .fire: return "Comfortable lifestyle · ×25 corpus"
        case .fat:  return "Luxury lifestyle · ×33 corpus"
        }
    }
}

// MARK: - Models

struct FIREInputs {
    var currentAge: Double = 30
    var retirementAge: Double = 45
    var monthlyExpenses: Double = 50_000
    var existingSavings: Double = 5_00_000
    var inflationRate: Double = 0.06   // 6% default
}

struct FIREResult {
    // Core FIRE variants (inflation-adjusted annual expense × multiplier)
    let leanFIRE: Double    // annual × 20  (5% withdrawal — minimal lifestyle)
    let fireNumber: Double  // annual × 25  (4% withdrawal — primary)
    let fatFIRE: Double     // annual × 33  (3% withdrawal — luxury lifestyle)

    // Expense projections
    let currentAnnualExpense: Double
    let futureAnnualExpense: Double   // inflation-adjusted at retirement

    // Corpus projections
    let existingCorpusAtRetirement: Double   // existing savings compounded
    let totalCorpusAtRetirement: Double      // existing + SIP accumulation
    let shortfall: Double                    // fireNumber − existingCorpus

    // SIP
    let monthlySIPNeeded: Double
    let yearsToRetirement: Int

    var isAlreadyFIRE: Bool { shortfall <= 0 }
}

// MARK: - Calculator

enum FIRECalculator {

    static func calculate(
        inputs: FIREInputs,
        mode: InvestmentMode = .balanced,
        target: FIRETarget = .fire
    ) -> FIREResult {
        let years = max(1, Int(inputs.retirementAge) - Int(inputs.currentAge))
        let n = Double(years)

        // ── Step 1: Inflate monthly expenses to retirement-day value ──────────
        let futureMonthly = inputs.monthlyExpenses * pow(1.0 + inputs.inflationRate, n)
        let futureAnnual  = futureMonthly * 12.0
        let currentAnnual = inputs.monthlyExpenses * 12.0

        // ── Step 2: FIRE number variants ──────────────────────────────────────
        let leanFIRE   = futureAnnual * 20.0   // 5% WR
        let fireNumber = futureAnnual * 25.0   // 4% WR
        let fatFIRE    = futureAnnual * 33.0   // 3% WR

        // ── Step 3: Grow existing savings using the mode's blended return ─────
        let returnRate = mode.expectedReturn
        let existingAtRetirement = inputs.existingSavings * pow(1.0 + returnRate, n)

        // ── Step 4: Shortfall against the chosen FIRE target ──────────────────
        let targetCorpus: Double
        switch target {
        case .lean: targetCorpus = leanFIRE
        case .fire: targetCorpus = fireNumber
        case .fat:  targetCorpus = fatFIRE
        }
        let shortfall = max(0.0, targetCorpus - existingAtRetirement)

        // ── Step 5: Monthly SIP to cover shortfall ────────────────────────────
        var sip = 0.0
        if shortfall > 0 {
            let r = returnRate / 12.0
            let months = Double(years * 12)
            sip = shortfall * r / (pow(1.0 + r, months) - 1.0)
        }

        // ── Step 6: Total projected corpus (existing growth + SIP growth) ─────
        let sipAccumulation: Double
        if sip > 0 {
            let r = returnRate / 12.0
            let months = Double(years * 12)
            sipAccumulation = sip * (pow(1.0 + r, months) - 1.0) / r
        } else {
            sipAccumulation = 0
        }
        let totalCorpus = existingAtRetirement + sipAccumulation

        return FIREResult(
            leanFIRE: leanFIRE,
            fireNumber: fireNumber,
            fatFIRE: fatFIRE,
            currentAnnualExpense: currentAnnual,
            futureAnnualExpense: futureAnnual,
            existingCorpusAtRetirement: existingAtRetirement,
            totalCorpusAtRetirement: totalCorpus,
            shortfall: shortfall,
            monthlySIPNeeded: sip,
            yearsToRetirement: years
        )
    }
}

// MARK: - Formatting

extension Double {
    var inrCompact: String {
        if self >= 1_00_00_000 { return String(format: "₹%.2f Cr", self / 1_00_00_000) }
        if self >= 1_00_000    { return String(format: "₹%.2f L",  self / 1_00_000) }
        return "₹\(Int(self))"
    }

    var inrFull: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.groupingSize = 3
        f.secondaryGroupingSize = 2
        f.usesGroupingSeparator = true
        f.maximumFractionDigits = 0
        return "₹" + (f.string(from: NSNumber(value: self)) ?? "0")
    }
}

// MARK: - Colors

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:  (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }

    static let fireIndigo  = Color(hex: "6366F1")
    static let fireEmerald = Color(hex: "10B981")
    static let fireAmber   = Color(hex: "F59E0B")
    static let fireSky     = Color(hex: "0EA5E9")
    static let fireRose    = Color(hex: "F43F5E")
    static let firePurple  = Color(hex: "8B5CF6")
}
