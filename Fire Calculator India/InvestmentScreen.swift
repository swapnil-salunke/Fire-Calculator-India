import SwiftUI

// MARK: - Donut Chart

struct DonutChart: View {
    let segments: [(fraction: Double, color: Color)]

    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outer = min(size.width, size.height) / 2 - 4
            let inner = outer * 0.58
            var start = -Double.pi / 2

            for seg in segments {
                let sweep = seg.fraction * 2 * Double.pi
                let end = start + sweep
                var path = Path()
                path.addArc(center: center, radius: outer, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                path.addArc(center: center, radius: inner, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
                path.closeSubpath()
                ctx.fill(path, with: .color(seg.color))
                start = end
            }
        }
    }
}

// MARK: - Investment Category

struct InvestmentCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let fraction: Double
    let vehicles: [String]
    let tip: String
    var monthlyAmount: Double
}

// MARK: - Investment Screen

struct InvestmentScreen: View {
    @Binding var inputs: FIREInputs
    @State private var selectedTarget: FIRETarget = .fire
    @State private var selectedMode: InvestmentMode = .balanced

    var result: FIREResult {
        FIRECalculator.calculate(inputs: inputs, mode: selectedMode, target: selectedTarget)
    }

    var categories: [InvestmentCategory] {
        let sip = result.monthlySIPNeeded
        let alloc = selectedMode.allocations
        return [
            .init(
                name: "Equity",
                icon: "chart.line.uptrend.xyaxis",
                color: .fireIndigo,
                fraction: alloc.equity,
                vehicles: equityVehicles,
                tip: "Core wealth builder. Stay invested through market cycles.",
                monthlyAmount: sip * alloc.equity
            ),
            .init(
                name: "Debt",
                icon: "shield.lefthalf.filled",
                color: .fireEmerald,
                fraction: alloc.debt,
                vehicles: ["PPF (EEE, ₹1.5L/yr)", "NPS Tier 1 (extra 80CCD)", "Short Duration Debt Fund"],
                tip: "Tax-efficient stability. PPF is unbeatable for long-term debt.",
                monthlyAmount: sip * alloc.debt
            ),
            .init(
                name: "Gold",
                icon: "sparkles",
                color: .fireAmber,
                fraction: alloc.gold,
                vehicles: ["Sovereign Gold Bonds (2.5% interest)", "Gold ETF (liquid)"],
                tip: "SGBs beat physical gold — you earn interest AND gold appreciation.",
                monthlyAmount: sip * alloc.gold
            ),
            .init(
                name: "Emergency",
                icon: "drop.fill",
                color: .fireSky,
                fraction: alloc.emergency,
                vehicles: ["Liquid Mutual Funds", "Sweep-in Fixed Deposits"],
                tip: "Maintain 6 months of expenses as emergency buffer.",
                monthlyAmount: sip * alloc.emergency
            )
        ]
    }

    // Equity vehicles vary by mode
    var equityVehicles: [String] {
        switch selectedMode {
        case .conservative:
            return ["Nifty 50 Index Fund", "ELSS (80C benefit)"]
        case .balanced:
            return ["Nifty 50 Index Fund", "Mid Cap Index Fund", "ELSS (80C benefit)"]
        case .aggressive:
            return ["Nifty 50 Index Fund", "Mid & Small Cap Index Fund", "ELSS (80C benefit)", "International Fund (diversify)"]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                targetPicker
                modePicker
                heroCard
                chartCard
                ForEach(categories) { cat in
                    categoryCard(cat)
                }
                recommendationsCard
                disclaimerNote
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .padding(.bottom, 34)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Investment Plan")
        .navigationBarTitleDisplayMode(.inline)
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
        .animation(.easeInOut(duration: 0.25), value: selectedMode)
        .animation(.easeInOut(duration: 0.25), value: selectedTarget)
    }

    // MARK: - FIRE Target Picker

    var targetPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FIRE Target")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 10) {
                ForEach(FIRETarget.allCases, id: \.self) { target in
                    Button {
                        selectedTarget = target
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: target.icon)
                                .font(.title3)
                                .foregroundColor(selectedTarget == target ? .white : target.color)
                            Text(target.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(selectedTarget == target ? .white : .primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTarget == target ? target.color : target.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }

            Text(selectedTarget.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Mode Picker

    var modePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Investment Style")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 10) {
                ForEach(InvestmentMode.allCases, id: \.self) { mode in
                    Button {
                        selectedMode = mode
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mode.icon)
                                .font(.title3)
                                .foregroundColor(selectedMode == mode ? .white : mode.color)
                            Text(mode.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(selectedMode == mode ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMode == mode ? mode.color : mode.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }

            Text(selectedMode.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Hero Card

    var heroCard: some View {
        VStack(spacing: 6) {
            Text("Monthly SIP Required")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if result.isAlreadyFIRE {
                Text("Already on track!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.fireEmerald)
                Text("Your existing corpus will reach FIRE without additional SIP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text(result.monthlySIPNeeded.inrCompact)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text(result.monthlySIPNeeded.inrFull + " per month")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 20) {
                VStack(spacing: 2) {
                    Text("FIRE by")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Age \(Int(inputs.retirementAge))")
                        .font(.caption.bold())
                }
                Divider().frame(height: 24)
                VStack(spacing: 2) {
                    Text(selectedTarget.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(result.totalCorpusAtRetirement.inrCompact)
                        .font(.caption.bold())
                        .foregroundColor(selectedTarget.color)
                }
                Divider().frame(height: 24)
                VStack(spacing: 2) {
                    Text("Expected return")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.0f%% p.a.", selectedMode.expectedReturn * 100))
                        .font(.caption.bold())
                        .foregroundColor(selectedMode.color)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Chart Card

    var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended Allocation")
                .font(.subheadline.bold())

            HStack(spacing: 20) {
                DonutChart(segments: categories.map { ($0.fraction, $0.color) })
                    .frame(width: 130, height: 130)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(categories) { cat in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cat.color)
                                .frame(width: 10, height: 10)
                            Text(cat.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(cat.fraction * 100))%")
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Category Cards

    func categoryCard(_ cat: InvestmentCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: cat.icon)
                    .font(.title3)
                    .foregroundColor(cat.color)
                    .frame(width: 40, height: 40)
                    .background(cat.color.opacity(0.12))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(cat.name)
                        .font(.subheadline.bold())
                    Text("\(Int(cat.fraction * 100))% of SIP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(cat.monthlyAmount.inrCompact)
                        .font(.subheadline.bold())
                        .foregroundColor(cat.color)
                    Text("/ month")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Where to invest")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
                ForEach(cat.vehicles, id: \.self) { v in
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(cat.color)
                            .padding(.top, 1)
                        Text(v)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }

            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.fireAmber)
                Text(cat.tip)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .background(Color.fireAmber.opacity(0.08))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Recommendations Card

    var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Key Recommendations", systemImage: "star.fill")
                .font(.subheadline.bold())
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 10) {
                recommendation(
                    icon: "building.columns.fill",
                    color: .fireIndigo,
                    text: "Maximize Section 80C (₹1.5L via ELSS + PPF) and 80CCD(1B) (₹50K via NPS) every year."
                )
                recommendation(
                    icon: "chart.bar.fill",
                    color: .fireEmerald,
                    text: "Step up your SIP by 10–15% every year to match salary increments."
                )
                recommendation(
                    icon: "arrow.triangle.2.circlepath",
                    color: .fireAmber,
                    text: "Rebalance your portfolio annually to stay on target allocation."
                )
                recommendation(
                    icon: "house.fill",
                    color: .fireSky,
                    text: "Keep 6 months of expenses in a liquid fund as emergency buffer before investing."
                )
                recommendation(
                    icon: "heart.fill",
                    color: .fireRose,
                    text: "Get term insurance (20× annual income) and health insurance before anything else."
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    func recommendation(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1))
                .cornerRadius(6)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Disclaimer

    var disclaimerNote: some View {
        Text("These are educational estimates based on historical averages. Consult a SEBI-registered financial advisor before investing. Past performance does not guarantee future returns.")
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}
