import SwiftUI

struct ResultScreen: View {
    @Binding var inputs: FIREInputs
    var onSeeInvestment: () -> Void

    @State private var retirementAge: Double

    init(inputs: Binding<FIREInputs>, onSeeInvestment: @escaping () -> Void) {
        self._inputs = inputs
        self.onSeeInvestment = onSeeInvestment
        self._retirementAge = State(initialValue: inputs.wrappedValue.retirementAge)
    }

    var result: FIREResult {
        var adj = inputs
        adj.retirementAge = retirementAge
        return FIRECalculator.calculate(inputs: adj)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    expenseProjectionCard
                    fireVariantsCard
                    metricsGrid
                    adjustCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 110)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())

            stickyButton
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Your FIRE Plan")
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
    }

    // MARK: - Expense Projection Card

    var expenseProjectionCard: some View {
        VStack(spacing: 12) {
            HStack {
                expenseBlock(
                    label: "Monthly Expense Today",
                    value: (result.currentAnnualExpense / 12).inrCompact
                )
                Divider().frame(height: 44)
                expenseBlock(
                    label: "Monthly Expense at \(Int(retirementAge))",
                    value: (result.futureAnnualExpense / 12).inrCompact,
                    highlight: true
                )
            }
            .padding(.horizontal, 8)

            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Inflated at \(String(format: "%.0f", inputs.inflationRate * 100))% per year for \(result.yearsToRetirement) years")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    func expenseBlock(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(highlight ? .fireIndigo : .primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - FIRE Variants Card

    var fireVariantsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Your FIRE Numbers", systemImage: "flame.fill")
                .font(.subheadline.bold())
                .foregroundColor(.primary)

            VStack(spacing: 10) {
                fireVariantRow(
                    label: "Lean FIRE",
                    subtitle: "×20 multiplier · 5% withdrawal rate",
                    value: result.leanFIRE,
                    color: .fireSky,
                    isPrimary: false
                )
                fireVariantRow(
                    label: "FIRE",
                    subtitle: "×25 multiplier · 4% withdrawal rate",
                    value: result.fireNumber,
                    color: .fireIndigo,
                    isPrimary: true
                )
                fireVariantRow(
                    label: "Fat FIRE",
                    subtitle: "×33 multiplier · 3% withdrawal rate",
                    value: result.fatFIRE,
                    color: .firePurple,
                    isPrimary: false
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    func fireVariantRow(label: String, subtitle: String, value: Double, color: Color, isPrimary: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 4)
                .frame(minHeight: 44)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(label)
                        .font(isPrimary ? .subheadline.bold() : .subheadline)
                        .foregroundColor(.primary)
                    if isPrimary {
                        Text("PRIMARY")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(color)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.12))
                            .cornerRadius(4)
                    }
                }
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(value.inrCompact)
                    .font(isPrimary ? .subheadline.bold() : .subheadline)
                    .foregroundColor(isPrimary ? color : .primary)
                Text(value.inrFull)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(isPrimary ? color.opacity(0.06) : Color.clear)
        .cornerRadius(10)
    }

    // MARK: - Metrics Grid

    var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metricTile(
                icon: "calendar.badge.clock",
                iconColor: .fireIndigo,
                label: "Years to FIRE",
                value: "\(result.yearsToRetirement)",
                unit: "years"
            )
            metricTile(
                icon: "arrow.up.circle.fill",
                iconColor: result.isAlreadyFIRE ? .fireEmerald : .fireRose,
                label: "Monthly SIP",
                value: result.isAlreadyFIRE ? "₹0" : result.monthlySIPNeeded.inrCompact,
                unit: result.isAlreadyFIRE ? "Already on track!" : "per month"
            )
            metricTile(
                icon: "banknote.fill",
                iconColor: .fireAmber,
                label: "Total Corpus",
                value: result.totalCorpusAtRetirement.inrCompact,
                unit: "at retirement"
            )
            metricTile(
                icon: "chart.line.uptrend.xyaxis",
                iconColor: .fireSky,
                label: "Existing Grows to",
                value: result.existingCorpusAtRetirement.inrCompact,
                unit: "without SIP"
            )
        }
    }

    func metricTile(icon: String, iconColor: Color, label: String, value: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Adjust Card

    var adjustCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Adjust Retirement Age", systemImage: "slider.horizontal.3")
                .font(.subheadline.bold())
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Retire at age")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(retirementAge)) yrs")
                        .font(.subheadline.bold())
                        .foregroundColor(.fireIndigo)
                        .monospacedDigit()
                }
                Slider(
                    value: $retirementAge,
                    in: max(inputs.currentAge + 1, 30)...70,
                    step: 1
                )
                .tint(.fireIndigo)
                HStack {
                    Text("Earlier = more SIP needed")
                    Spacer()
                    Text("Later = less SIP")
                }
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Sticky Button

    var stickyButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)

            Button(action: onSeeInvestment) {
                HStack(spacing: 8) {
                    Text("See Investment Plan")
                        .font(.headline)
                    Image(systemName: "chart.pie.fill")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.fireIndigo)
                .cornerRadius(14)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 34)
            .background(Color(.systemGroupedBackground))
        }
    }
}
