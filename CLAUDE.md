# FIRE Calculator India — Claude Instructions

> Read SPEC.md for full architecture, data models, design system, and extension points.
> This file contains the rules you must follow when working in this repo.

## Project Identity

Native iOS SwiftUI app. India-specific FIRE (Financial Independence, Retire Early) calculator. No backend, no third-party packages, fully offline.

## Investigation Rules

- **Always trace end-to-end flows before drawing conclusions.** When a new or changed file is observed, read every file that could plausibly reference it — screens, entry points, models — before commenting on whether something is wired up, connected, or missing.
- Never state that a feature is "not connected" or "needs to be wired up" without having verified all referencing files first.

## Hard Rules

- **Zero external dependencies.** Never add a Swift Package or CocoaPod. Every feature must be built with SwiftUI + Foundation only.
- **No project.pbxproj edits needed.** The project uses `PBXFileSystemSynchronizedRootGroup` — new `.swift` files dropped into `Fire Calculator India/` are auto-compiled.
- **No force unwraps.** Use `?? 0` / `?? ""` fallbacks.
- **onChange always uses two-parameter form:** `{ _, newValue in }` — the single-parameter form is deprecated in iOS 17+.
- **Dark mode must work.** Never hardcode white/black for backgrounds. Always use `Color(.systemGroupedBackground)` / `Color(.secondarySystemGroupedBackground)`.
- **No persistence unless explicitly asked.** Inputs are in-memory only.

## Architecture Rules

- All data models, calculator logic, formatting, and colors live in **`FIREModels.swift`** only. Do not scatter model code into view files.
- `FIREInputs` is the single source of truth — passed as `@Binding` through all screens.
- `FIRECalculator.calculate()` must stay a pure static function. No side effects.
- Navigation uses `NavigationStack` + typed `AppRoute` enum in `ContentView.swift`. To add a screen: add an `AppRoute` case + `navigationDestination` branch + new view file.
- `InvestmentMode` and `FIRETarget` are local `@State` on `InvestmentScreen` only — they do NOT belong in `FIREInputs`.

## Design System — Always Follow

**Colors** (defined in `FIREModels.swift`, use these, never raw hex in views):
- Primary / CTA / sliders: `.fireIndigo` (`#6366F1`)
- Success / on-track: `.fireEmerald` (`#10B981`)
- Warnings / tips: `.fireAmber` (`#F59E0B`)
- Lean FIRE / Emergency: `.fireSky` (`#0EA5E9`)
- Aggressive / deficit: `.fireRose` (`#F43F5E`)
- Fat FIRE: `.firePurple` (`#8B5CF6`)

**Navigation bar gradient** — every screen must have:
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

**Section label above a card:**
```swift
Label(title, systemImage: icon)
    .font(.caption.bold())
    .foregroundColor(.secondary)
    .textCase(.uppercase)
    .tracking(0.5)
```

**Primary CTA button** — always sticky at bottom with fade gradient above, `Color.fireIndigo` fill, `.cornerRadius(14)`, `.padding(.vertical, 17)`.

**Sliders** — always `.tint(.fireIndigo)`. Show current value as `Text` on the trailing side in `.fireIndigo.bold()`.

**Hero numbers** — use `.system(size: 44, weight: .bold, design: .rounded)`.

## Number Formatting

- Large amounts → `.inrCompact` (e.g. `₹2.50 Cr`, `₹15.25 L`)
- Secondary sub-labels → `.inrFull` (e.g. `₹2,50,00,000`)
- Never use plain `String(format:)` for currency in the UI — use these extensions.

## Code Style

- No comments on obvious code. Only comment WHY — hidden constraints, non-obvious invariants.
- View decomposition: each card = a `var someCard: some View {}` computed property or `func someRow() -> some View {}` helper on the same struct.
- Use `// MARK: - SectionName` in every file.
- Animations: `.easeInOut(duration: 0.25)` for picker switches, `.easeOut(duration: 0.3)` for scroll.

## India-Specific Assumptions — Do Not Change Without Updating SPEC.md

| Constant | Value |
|----------|-------|
| Default inflation | 6% |
| Conservative return | 9% |
| Balanced return | 12% |
| Aggressive return | 14% |
| Lean FIRE multiplier | ×20 (5% SWR) |
| FIRE multiplier | ×25 (4% SWR) |
| Fat FIRE multiplier | ×33 (3% SWR) |

## What NOT to Do

- Do not add city tier, home ownership, or dependents fields — they were deliberately removed.
- Do not use `Charts` framework for the donut chart — it is drawn with `Canvas` intentionally.
- Do not add networking, analytics, or any remote calls.
- Do not create new color constants without adding them to the palette in `FIREModels.swift`.
- Do not split `FIREModels.swift` into multiple files unless it exceeds ~600 lines.
