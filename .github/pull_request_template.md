## Summary

<!-- What does this change do and why? 1–3 sentences. -->

## Type of Change

- [ ] New feature / screen
- [ ] Bug fix
- [ ] Refactor (no behaviour change)
- [ ] Calculator logic / assumptions change
- [ ] Tests only
- [ ] Docs only

## Changes

<!-- Bullet the files/areas touched. -->

-

## Screenshots

<!-- Light and dark mode for any UI change. Delete if not applicable. -->

| Light | Dark |
|-------|------|
|       |      |

## Testing

- [ ] Builds with no warnings
- [ ] Unit tests pass
- [ ] UI tests pass (if navigation or screens changed)
- [ ] Verified on simulator in light and dark mode

## Project Rules Checklist

- [ ] No external dependencies (no Swift Packages / CocoaPods)
- [ ] No force unwraps (`?? 0` / `?? ""` fallbacks used)
- [ ] `onChange` uses the two-parameter form `{ _, newValue in }`
- [ ] No hardcoded white/black backgrounds; system colors used
- [ ] Colors come from the palette in `FIREModels.swift` (no raw hex in views)
- [ ] Models, calculator logic, formatting and colors live in `FIREModels.swift` only
- [ ] `FIRECalculator.calculate()` is still a pure static function
- [ ] New screens use an `AppRoute` case + `navigationDestination` branch
- [ ] Navigation bar gradient applied on every new screen
- [ ] Currency shown via `.inrCompact` / `.inrFull`, not `String(format:)`
- [ ] No persistence, networking or analytics added

## India Assumptions

- [ ] Constants (inflation, returns, FIRE multipliers) unchanged
- [ ] If changed, `SPEC.md` is updated in this PR

## Notes for Reviewer

<!-- Anything non-obvious: trade-offs, follow-ups, areas needing extra attention. -->
