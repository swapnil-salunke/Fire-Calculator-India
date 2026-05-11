# 🔥 FIRE Calculator India

A native iOS app to calculate your **Financial Independence, Retire Early (FIRE)** number — built specifically for the Indian market with inflation rates, investment vehicles, and tax-saving instruments relevant to India.

## Screenshots

> Coming soon

## Features

- **Three FIRE Targets** — Lean FIRE (×20), FIRE (×25), Fat FIRE (×33)
- **Investment Modes** — Conservative, Balanced, Aggressive with different equity/debt allocations
- **India-specific defaults** — 6% inflation, PPF, NPS, ELSS, Sovereign Gold Bonds
- **Inflation-adjusted projections** — expenses calculated at retirement-day value
- **Monthly SIP calculator** — exact amount needed to hit your FIRE number
- **Investment allocation breakdown** — Equity, Debt, Gold, Emergency with recommended vehicles
- **Custom donut chart** — visual allocation breakdown, no third-party dependencies

## Screens

| Input | Results | Investment Plan |
|-------|---------|-----------------|
| Age, expenses, savings, inflation rate | Lean / FIRE / Fat FIRE numbers, SIP needed, corpus progress | Allocation breakdown, India-specific vehicles, key recommendations |

## FIRE Calculation

```
Future Annual Expense = Monthly Expenses × 12 × (1 + inflation)^years

Lean FIRE  = Future Annual Expense × 20   (5% withdrawal rate)
FIRE       = Future Annual Expense × 25   (4% withdrawal rate)
Fat FIRE   = Future Annual Expense × 33   (3% withdrawal rate)

Monthly SIP = Shortfall × r / ((1 + r)^n − 1)
```

Where `r` = monthly return rate and `n` = months to retirement.

## Investment Modes & Returns

| Mode | Equity | Debt | Gold | Emergency | Expected Return |
|------|--------|------|------|-----------|-----------------|
| Conservative | 40% | 45% | 10% | 5% | 9% |
| Balanced | 60% | 25% | 10% | 5% | 12% |
| Aggressive | 80% | 10% | 5% | 5% | 14% |

## Recommended Investment Vehicles

- **Equity** — Nifty 50 Index Fund, Mid Cap Index Fund, ELSS (80C benefit)
- **Debt** — PPF (EEE, ₹1.5L/yr), NPS Tier 1 (80CCD), Short Duration Debt Fund
- **Gold** — Sovereign Gold Bonds (2.5% interest + appreciation), Gold ETF
- **Emergency** — Liquid Mutual Funds, Sweep-in Fixed Deposits

## Requirements

- iOS 16+
- Xcode 15+
- Swift 5.9+

## Installation

1. Clone the repo
   ```bash
   git clone git@github.com:swapnil-salunke/Fire-Calculator-India.git
   ```
2. Open `Fire Calculator India.xcodeproj` in Xcode
3. Select a simulator or device and hit **Run**

No external dependencies — pure SwiftUI.

## License

MIT
