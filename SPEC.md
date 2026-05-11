# FIRE Calculator India — Project Spec

> **Purpose of this document:** A complete technical and product specification for the iOS app. Written so an AI agent can read it cold and immediately understand the architecture, data model, design system, and where/how to safely add new features.

---

## 1. Project Overview

**App name:** FIRE Calculator India  
**Platform:** iOS (SwiftUI, native)  
**Deployment target:** iOS 16+  
**Swift version:** 5.9+  
**Bundle ID:** `in.swapnilsalunke.Fire-Calculator-India`  
**GitHub:** `git@github.com:swapnil-salunke/Fire-Calculator-India.git`  

**What it does:** Calculates the corpus (savings) a user needs to retire early in India, given their current age, expenses, existing savings, and investment style. Also generates a monthly SIP plan with India-specific investment vehicles.

**What makes it India-specific:**
- 6% default inflation rate (vs 2–3% in the West)
- PPF, NPS, ELSS, Sovereign Gold Bonds as investment vehicles
- Section 80C / 80CCD tax-saving recommendations
- Indian number formatting (₹1.50 Cr, ₹25.00 L)
- Lean / FIRE / Fat FIRE corpus multipliers calibrated for India's SWR debate

---

## 2. File Structure

```
Fire Calculator India/
├── Fire Calculator India.xcodeproj/   ← Xcode project (PBXFileSystemSynchronizedRootGroup)
└── Fire Calculator India/             ← all source files, auto-included in build
    ├── Fire_Calculator_IndiaApp.swift  ← @main entry, launch screen logic
    ├── ContentView.swift               ← NavigationStack root, AppRoute enum
    ├── FIREModels.swift                ← ALL data models, calculator, formatting, colors
    ├── InputScreen.swift               ← Screen 1: user inputs
    ├── ResultScreen.swift              ← Screen 2: FIRE numbers & metrics
    ├── InvestmentScreen.swift          ← Screen 3: SIP plan & allocation
    ├── LaunchScreen.swift              ← Custom launch screen (shown 1.2s on cold open)
    └── Assets.xcassets/
        ├── AppIcon.appiconset/
        └── LaunchBackground.colorset/
```

> **Important:** The project uses `PBXFileSystemSynchronizedRootGroup`. Any new `.swift` file dropped into the `Fire Calculator India/` directory is **automatically compiled** — no project.pbxproj edits needed.

---

## 3. Navigation Architecture

**Pattern:** `NavigationStack` with typed routes (`AppRoute` enum).

```
ContentView (NavigationStack root)
    └── InputScreen          → user taps "Calculate My FIRE Number"
        └── ResultScreen     → user taps "See Investment Plan"
            └── InvestmentScreen
```

**AppRoute enum** (in `ContentView.swift`):
```swift
enum AppRoute: Hashable {
    case result
    case investment
}
```

**To add a new screen:**
1. Add a case to `AppRoute`
2. Add a `navigationDestination` branch in `ContentView`
3. The back button is free from `NavigationStack`

**State flow:** `FIREInputs` is a `@State` in `ContentView` and passed as `@Binding` through all screens. This means any screen can mutate inputs and ResultScreen will recompute live.

---

## 4. Data Models (`FIREModels.swift`)

### 4.1 FIREInputs
The single source of truth for all user inputs.

```swift
struct FIREInputs {
    var currentAge: Double       // 18–60, slider, default 30
    var retirementAge: Double    // currentAge+1 to 70, slider, default 45
    var monthlyExpenses: Double  // ₹/month, text field, default ₹50,000
    var existingSavings: Double  // ₹ total invested today, text field, default ₹5,00,000
    var inflationRate: Double    // 0.03–0.12, slider, default 0.06 (6%)
}
```

> **Note:** `FIREInputs` does NOT contain `InvestmentMode` or `FIRETarget` — those are local `@State` on `InvestmentScreen` because they only affect the investment plan, not the FIRE number.

### 4.2 FIREResult
Output of `FIRECalculator.calculate()`. Pure computed value — never stored.

```swift
struct FIREResult {
    let leanFIRE: Double                    // annual × 20  (5% SWR)
    let fireNumber: Double                  // annual × 25  (4% SWR) ← primary
    let fatFIRE: Double                     // annual × 33  (3% SWR)
    let currentAnnualExpense: Double        // monthlyExpenses × 12
    let futureAnnualExpense: Double         // inflation-adjusted at retirement
    let existingCorpusAtRetirement: Double  // existing savings compounded
    let totalCorpusAtRetirement: Double     // existing + SIP accumulation
    let shortfall: Double                   // target corpus − existing corpus
    let monthlySIPNeeded: Double            // monthly investment to cover shortfall
    let yearsToRetirement: Int
    var isAlreadyFIRE: Bool                 // shortfall <= 0
}
```

### 4.3 InvestmentMode
Controls expected return rate and equity/debt/gold/emergency allocation.

| Mode | Equity | Debt | Gold | Emergency | Return |
|------|--------|------|------|-----------|--------|
| Conservative | 40% | 45% | 10% | 5% | 9% |
| Balanced | 60% | 25% | 10% | 5% | 12% |
| Aggressive | 80% | 10% | 5% | 5% | 14% |

### 4.4 FIRETarget
Determines which FIRE number to use for SIP calculation.

| Target | Multiplier | Withdrawal Rate |
|--------|-----------|-----------------|
| Lean FIRE | ×20 | 5% SWR |
| FIRE | ×25 | 4% SWR |
| Fat FIRE | ×33 | 3% SWR |

---

## 5. Calculation Engine (`FIRECalculator`)

All logic lives in `FIRECalculator.calculate(inputs:mode:target:)`. It is a pure static function — no side effects, no state.

### Step-by-step:

```
1. years = retirementAge − currentAge  (min 1)

2. futureAnnualExpense = monthlyExpenses × 12 × (1 + inflationRate)^years

3. Lean FIRE  = futureAnnualExpense × 20
   FIRE       = futureAnnualExpense × 25
   Fat FIRE   = futureAnnualExpense × 33

4. existingAtRetirement = existingSavings × (1 + mode.expectedReturn)^years

5. shortfall = max(0, targetCorpus − existingAtRetirement)
   where targetCorpus = leanFIRE | fireNumber | fatFIRE depending on FIRETarget

6. monthlySIP = shortfall × r / ((1 + r)^n − 1)
   where r = expectedReturn / 12, n = years × 12

7. totalCorpus = existingAtRetirement + SIP accumulation
```

**Key assumption:** The same `mode.expectedReturn` is used for both existing savings growth AND SIP accumulation. This is intentional simplification.

---

## 6. Design System

### 6.1 Color Palette

All colors are defined as `static let` on `Color` extension in `FIREModels.swift`.

| Name | Hex | Usage |
|------|-----|-------|
| `fireIndigo` | `#6366F1` | Primary CTA, sliders, active states |
| `fireEmerald` | `#10B981` | Success, "on track", Balanced mode, Debt category |
| `fireAmber` | `#F59E0B` | Tip cards, Gold category, warnings |
| `fireSky` | `#0EA5E9` | Lean FIRE, Emergency category |
| `fireRose` | `#F43F5E` | Aggressive mode, "need more SIP" |
| `firePurple` | `#8B5CF6` | Fat FIRE, corpus charts |

**Background layers** use semantic iOS system colors:
- Screen background: `Color(.systemGroupedBackground)`
- Card background: `Color(.secondarySystemGroupedBackground)`

These automatically adapt to dark mode — never use hardcoded light/dark hex for backgrounds.

### 6.2 Navigation Bar

All three screens share identical navigation bar styling:

```swift
.toolbarBackground(
    LinearGradient(
        colors: [Color(hex: "6366F1"), Color(hex: "7C3AED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    ),
    for: .navigationBar
)
.toolbarBackground(.visible, for: .navigationBar)
.toolbarColorScheme(.dark, for: .navigationBar)
```

The `ContentView` also sets `.tint(.white)` on the `NavigationStack` so the back chevron is white.

### 6.3 Typography

All text uses SF Pro (system default). Key sizes:
- Screen hero values: `.system(size: 44, weight: .bold, design: .rounded)`
- Card titles / primary labels: `.subheadline.bold()`
- Section headers: `.caption.bold()` + `.textCase(.uppercase)` + `.tracking(0.5)`
- Body: `.subheadline`
- Captions / subtitles: `.caption`, `.caption2`

### 6.4 Card Pattern

Every grouped section of content uses this pattern:

```swift
VStack(spacing: 14) { content() }
    .padding(16)
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(14)
```

Section label above the card:
```swift
Label(title, systemImage: icon)
    .font(.caption.bold())
    .foregroundColor(.secondary)
    .textCase(.uppercase)
    .tracking(0.5)
```

### 6.5 CTA Button (Sticky)

All primary action buttons are sticky at the bottom with a fade-out gradient above:

```swift
VStack(spacing: 0) {
    LinearGradient(colors: [bg.opacity(0), bg], startPoint: .top, endPoint: .bottom)
        .frame(height: 24)
    Button { action() } label: {
        // label
        .frame(maxWidth: .infinity).padding(.vertical, 17)
        .background(Color.fireIndigo).cornerRadius(14)
    }
    .padding(.horizontal, 16).padding(.bottom, 34)
    .background(bg)
}
```

### 6.6 Metric Tile

Reusable tile used in `ResultScreen.metricsGrid`:

```swift
func metricTile(icon: String, iconColor: Color, label: String, value: String, unit: String) -> some View
```

Icon is shown in a 32×32 rounded square with `iconColor.opacity(0.12)` background.

### 6.7 Donut Chart

Custom `DonutChart` view in `InvestmentScreen.swift`. Uses `Canvas` (no third-party dependencies).

```swift
struct DonutChart: View {
    let segments: [(fraction: Double, color: Color)]
}
```

Inner radius = 58% of outer radius. Starts at top (−π/2).

---

## 7. Screen Reference

### Screen 1 — InputScreen

**File:** `InputScreen.swift`  
**Entry:** Root of `NavigationStack`  
**Output:** Calls `onCalculate: () -> Void` → pushes `.result` route  

**Inputs collected:**
| Field | Type | Control | Range / Default |
|-------|------|---------|-----------------|
| Current Age | `Double` | Slider | 18–60, step 1, default 30 |
| Target Retirement Age | `Double` | Slider | currentAge+1 to 70, step 1, default 45 |
| Monthly Expenses | `Double` | Currency text field | Any positive ₹, default ₹50,000 |
| Existing Savings | `Double` | Currency text field | Any positive ₹, default ₹5,00,000 |
| Inflation Rate | `Double` | Slider | 3–12%, step 1%, default 6% |

**Currency field behaviour:** `@FocusState` tracks active field. `ScrollViewReader` auto-scrolls to the focused field. Text field shows raw digits; `₹` prefix is a separate `Text` beside it. `onChange` parses digits only.

**Methodology Note** at bottom explains all three FIRE multipliers — always keep this in sync with the calculator logic.

---

### Screen 2 — ResultScreen

**File:** `ResultScreen.swift`  
**Route:** `.result`  
**Output:** Calls `onSeeInvestment: () -> Void` → pushes `.investment` route  

**Key behaviour:** Has a local `@State private var retirementAge: Double` independent from `inputs.retirementAge`. The adjust-card slider changes only this local value, updating `result` live without writing back to inputs. This is intentional — the user can explore "what if I retire at 55?" without losing their original input.

**Cards (top to bottom):**
1. `expenseProjectionCard` — today's vs retirement monthly expense side-by-side
2. `fireVariantsCard` — all three FIRE numbers (Lean / FIRE / Fat) with the FIRE variant highlighted as PRIMARY
3. `metricsGrid` — 2×2 grid: Years to FIRE, Monthly SIP, Total Corpus, Existing Grows To
4. `adjustCard` — retirement age slider (local state, live recalculation)

---

### Screen 3 — InvestmentScreen

**File:** `InvestmentScreen.swift`  
**Route:** `.investment`  

**Local state (not persisted to FIREInputs):**
- `@State private var selectedTarget: FIRETarget = .fire`
- `@State private var selectedMode: InvestmentMode = .balanced`

Changing either triggers `.animation(.easeInOut(duration: 0.25))` — all cards update live.

**Cards (top to bottom):**
1. `targetPicker` — 3-button row: Lean FIRE / FIRE / Fat FIRE
2. `modePicker` — 3-button row: Conservative / Balanced / Aggressive
3. `heroCard` — monthly SIP amount + age / target / return summary
4. `chartCard` — `DonutChart` + legend
5. 4× `categoryCard` — Equity, Debt, Gold, Emergency (allocation adapts to mode)
6. `recommendationsCard` — 5 static India-specific tips
7. `disclaimerNote` — legal disclaimer

**Equity vehicles** vary by mode (more aggressive → more mid/small cap + international).

---

### LaunchScreen

**File:** `LaunchScreen.swift`  
**Shown for:** 1.2 seconds then fades out (controlled in `Fire_Calculator_IndiaApp.swift`)  
**Design:** Full-screen indigo→purple gradient, centred flame icon in frosted rounded-square, "FIRE Calculator" + "INDIA" lettering.

---

## 8. Formatting Conventions

All monetary display uses extensions on `Double` (in `FIREModels.swift`):

| Method | Output example | When to use |
|--------|---------------|-------------|
| `.inrCompact` | `₹2.50 Cr`, `₹15.25 L`, `₹45000` | Hero numbers, metric tiles |
| `.inrFull` | `₹2,50,00,000` | Secondary sub-labels under compact value |

Indian grouping: secondary group size = 2 (e.g. `1,23,45,678`), done via `NumberFormatter.secondaryGroupingSize = 2`.

---

## 9. What Is Intentionally Absent

These are deliberate omissions — do not add without discussion:

- **No persistence / UserDefaults** — inputs are in-memory only; reopening the app resets to defaults
- **No charts framework dependency** — donut chart is drawn with `Canvas`
- **No city tier / home ownership / dependents** — those fields existed in an earlier design but were removed to simplify the model
- **No portfolio tracking** — this is a calculator, not a portfolio manager
- **No backend / API calls** — fully offline

---

## 10. Extension Points — How to Add New Features

### 10.1 Adding a new input field

1. Add a property to `FIREInputs` in `FIREModels.swift`
2. Add the UI control to the relevant `section()` in `InputScreen.swift`
3. Update `FIRECalculator.calculate()` to use the new value
4. Update `FIREResult` if the calculation produces a new output value

### 10.2 Adding a new screen

1. Add a case to `AppRoute` in `ContentView.swift`
2. Add a `navigationDestination` branch in `ContentView.body`
3. Create the new `View` file — it will be auto-included in the build
4. Pass `@Binding var inputs: FIREInputs` if the screen needs to read/write inputs
5. Use the standard navbar gradient modifier (copy from any existing screen)

### 10.3 Adding a new investment mode or FIRE target

- `InvestmentMode` and `FIRETarget` are `CaseIterable` enums in `FIREModels.swift`
- Add a new case + implement the required computed properties (`allocations`, `expectedReturn`, `icon`, `color`, `description` / `multiplier`, `withdrawalRate`)
- The picker UI in `InvestmentScreen` iterates `allCases` — it will pick up the new case automatically

### 10.4 Adding a chart / graph screen (e.g. corpus growth over time)

- Compute a `[Double]` array of corpus values year-by-year inside `FIRECalculator` or as a helper function
- Render with SwiftUI `Charts` (iOS 16+) — `LineMark` / `AreaMark`
- Add as a new card inside `ResultScreen` or as a fourth route `AppRoute.chart`

### 10.5 Adding persistence (save/load inputs)

- Make `FIREInputs` conform to `Codable`
- Save to `UserDefaults` using a `@AppStorage`-backed wrapper, or write to a JSON file in the Documents directory
- Restore in `ContentView.init()` or via `.onAppear`

### 10.6 Adding share / export

- Render a summary `View` and use `ImageRenderer` (iOS 16+) to produce a `UIImage`
- Present via `ShareLink` (iOS 16+) — no UIKit needed

---

## 11. Code Conventions

- **No comments on obvious code** — only comment WHY (hidden constraint, non-obvious invariant)
- **No third-party packages** — keep zero dependencies
- **View decomposition:** Each logical card / section is a `var someCard: some View {}` computed property or a `func someRow(...) -> some View {}` helper on the same `View` struct
- **MARK sections** used in every file: `// MARK: - SectionName`
- **No force unwraps** — use `?? 0` / `?? ""` fallbacks
- **Animations:** `.easeInOut(duration: 0.25)` for mode/target switches, `.easeOut(duration: 0.3)` for scroll, `.easeOut(duration: 0.4)` for launch fade
- **onChange:** Always use the two-parameter `{ _, newValue in }` form (iOS 17+ API)
- **Dark mode:** Always use semantic system colors for backgrounds; never hardcode white/black

---

## 12. India-Specific Financial Assumptions

These are baked into the UI copy and recommendations — keep them consistent:

| Assumption | Value | Rationale |
|------------|-------|-----------|
| Default inflation | 6% | RBI long-run target / historical average |
| Conservative return | 9% | Debt-heavy portfolio |
| Balanced return | 12% | Standard Indian large-cap equity CAGR |
| Aggressive return | 14% | Mid/small cap tilt |
| 80C limit | ₹1.5L/year | Income Tax Act |
| 80CCD(1B) NPS | ₹50K/year | Additional NPS deduction |
| SGB interest | 2.5% | Current RBI rate on Sovereign Gold Bonds |
| Emergency buffer | 6 months expenses | Standard PF advice |
| Term insurance | 20× annual income | Standard India PF recommendation |
