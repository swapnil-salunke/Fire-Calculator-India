---
inclusion: always
---

# Project Structure & Architecture

## File Map
```
Fire Calculator India/
├── Fire_Calculator_IndiaApp.swift  — @main, 1.2s launch screen fade
├── ContentView.swift               — NavigationStack root, AppRoute enum
├── FIREModels.swift                — ALL models, calculator, colors, formatting
├── InputScreen.swift               — Screen 1: user inputs form
├── ResultScreen.swift              — Screen 2: FIRE numbers + metrics
├── InvestmentScreen.swift          — Screen 3: SIP plan + allocation
└── LaunchScreen.swift              — Custom launch screen view
```

## Navigation
`NavigationStack` with typed routes. Back button is free.

```
InputScreen → (Calculate) → ResultScreen → (See Investment Plan) → InvestmentScreen
```

**To add a new screen:**
1. Add a case to `AppRoute` in `ContentView.swift`
2. Add a `navigationDestination` branch in `ContentView.body`
3. Create the new view file — auto-compiled

## Data Flow
- `FIREInputs` struct lives as `@State` in `ContentView`, passed as `@Binding` to all screens
- `FIREResult` is computed on-demand — never stored, never persisted
- `InvestmentMode` and `FIRETarget` are `@State` local to `InvestmentScreen` only

## FIREModels.swift — The Single Source of Truth
All of the following live here and ONLY here:
- `FIREInputs` struct (all user inputs)
- `FIREResult` struct (all calculator outputs)
- `InvestmentMode` enum (Conservative / Balanced / Aggressive)
- `FIRETarget` enum (Lean FIRE / FIRE / Fat FIRE)
- `FIRECalculator` enum with `calculate(inputs:mode:target:)` static function
- `Double` extensions: `.inrCompact`, `.inrFull`
- `Color` extensions: `Color(hex:)` init + all named colors

Never scatter model code into view files.

## Architecture Rules
- `FIRECalculator.calculate()` must stay a **pure static function** — no side effects, no state
- `FIREInputs` does NOT contain `InvestmentMode` or `FIRETarget`
- `ResultScreen` has a **local** `@State var retirementAge` for live "what-if" adjustment — it does not write back to `inputs.retirementAge`

## Design System

**Colors** — always use these, never raw hex in views:
| Token | Hex | Use |
|-------|-----|-----|
| `.fireIndigo` | `#6366F1` | Primary CTA, sliders, active states |
| `.fireEmerald` | `#10B981` | Success, on-track |
| `.fireAmber` | `#F59E0B` | Tips, gold, warnings |
| `.fireSky` | `#0EA5E9` | Lean FIRE, emergency |
| `.fireRose` | `#F43F5E` | Aggressive mode, deficit |
| `.firePurple` | `#8B5CF6` | Fat FIRE |

**Navigation bar** — every screen must apply:
```swift
.toolbarBackground(
    LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "7C3AED")],
                   startPoint: .topLeading, endPoint: .bottomTrailing),
    for: .navigationBar
)
.toolbarBackground(.visible, for: .navigationBar)
.toolbarColorScheme(.dark, for: .navigationBar)
```

**Card pattern:**
```swift
VStack(spacing: 14) { content() }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(14)
```

**Section header above a card:**
```swift
Label(title, systemImage: icon)
    .font(.caption.bold())
    .foregroundColor(.secondary)
    .textCase(.uppercase)
    .tracking(0.5)
```

**Primary CTA button** — sticky bottom, `Color.fireIndigo`, `.cornerRadius(14)`, `.padding(.vertical, 17)`, with fade gradient above.

## Code Conventions
- No comments on obvious code — only comment WHY
- Each card = `var someCard: some View {}` computed property or `func someRow() -> some View {}`
- `// MARK: - SectionName` in every file
- New color tokens → add to `Color` extension in `FIREModels.swift` only
