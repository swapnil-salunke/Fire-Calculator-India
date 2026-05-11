# GitHub Copilot Instructions — FIRE Calculator India

Read SPEC.md for full architecture, data models, design system, and extension points.

## Project
Native iOS SwiftUI app. FIRE (Financial Independence, Retire Early) calculator for India. No backend, no third-party packages.

## Files
- `FIREModels.swift` — all models, calculator, colors, formatting. Add new model code here only.
- `ContentView.swift` — NavigationStack root + AppRoute enum.
- `InputScreen.swift` — Screen 1: user inputs.
- `ResultScreen.swift` — Screen 2: FIRE numbers and metrics.
- `InvestmentScreen.swift` — Screen 3: SIP plan and allocation.
- New `.swift` files in `Fire Calculator India/` are auto-compiled (no pbxproj edits needed).

## Key Rules

**Architecture:**
- `FIREInputs` is `@Binding` through all screens — the single source of truth.
- `FIRECalculator.calculate()` is a pure static function. Never add state or side effects to it.
- `InvestmentMode` / `FIRETarget` are local state on `InvestmentScreen` — never add them to `FIREInputs`.

**SwiftUI:**
- Use `onChange(of:) { _, newValue in }` — two-parameter form only (iOS 17+).
- No force unwraps. Use `?? 0` / `?? ""` fallbacks.
- All backgrounds use semantic colors: `Color(.systemGroupedBackground)`, `Color(.secondarySystemGroupedBackground)`.
- Never hardcode white/black for backgrounds — dark mode must work.

**Design:**
- Primary color: `Color.fireIndigo` (#6366F1). Use for CTAs, sliders, active states.
- All new colors must be added as `static let` on `Color` in `FIREModels.swift`.
- Every new screen needs the indigo→purple navigation bar gradient.
- Cards: `.padding(16)` + `.background(Color(.secondarySystemGroupedBackground))` + `.cornerRadius(14)`.

**Formatting:**
- Currency hero values: `.inrCompact` (e.g. ₹2.50 Cr).
- Currency sub-labels: `.inrFull` (e.g. ₹2,50,00,000).

**India constants — do not change:**
- Inflation default: 6%
- FIRE multipliers: ×20 (Lean), ×25 (FIRE), ×33 (Fat FIRE)
- Returns: 9% conservative, 12% balanced, 14% aggressive

## Never
- Add Swift packages, CocoaPods, or any external dependency.
- Add networking or remote API calls.
- Use Charts framework — donut chart uses Canvas.
- Add persistence unless explicitly requested.
