---
inclusion: always
---

# Tech Stack & Constraints

## Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI only. No UIKit unless absolutely unavoidable.
- **Frameworks:** Foundation + SwiftUI. Nothing else.
- **Deployment target:** iOS 16+
- **Dependencies:** Zero. No Swift packages, no CocoaPods, no SPM.

## Xcode Project
- Uses `PBXFileSystemSynchronizedRootGroup` (Xcode 15+)
- Any `.swift` file added to `Fire Calculator India/` is **auto-compiled** — never edit `project.pbxproj` manually

## SwiftUI API Rules
- `onChange` → always use `{ _, newValue in }` (two-parameter form, iOS 17+ API)
- Backgrounds → always `Color(.systemGroupedBackground)` / `Color(.secondarySystemGroupedBackground)` — dark mode must work
- No force unwraps — use `?? 0` / `?? ""` fallbacks
- Animations: `.easeInOut(duration: 0.25)` for picker switches, `.easeOut(duration: 0.3)` for scroll

## Do Not Use
- `Charts` framework — the donut chart is drawn with `Canvas` intentionally (no dependency)
- `UIKit` for layout
- `UserDefaults` / `CoreData` / `SwiftData` unless explicitly asked
- Any networking or remote API

## Number Formatting
All monetary display uses extensions on `Double` defined in `FIREModels.swift`:
- `.inrCompact` → `₹2.50 Cr`, `₹15.25 L` — use for hero numbers and metric tiles
- `.inrFull` → `₹2,50,00,000` (Indian grouping) — use for secondary sub-labels

Never use raw `String(format:)` for currency display in views.
