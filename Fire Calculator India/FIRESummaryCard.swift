import SwiftUI

// MARK: - FIRESummaryCard
// Rendered to UIImage via ImageRenderer for sharing. Fixed 390pt width (iPhone screen width).

#Preview {
    ScrollView {
        FIRESummaryCard(
            result: FIRECalculator.calculate(inputs: FIREInputs()),
            inputs: FIREInputs()
        )
        .padding(16)
    }
    .background(Color(.systemGroupedBackground))
}

struct FIRESummaryCard: View {
    let result: FIREResult
    let inputs: FIREInputs

    var body: some View {
        VStack(spacing: 0) {
            header
            fireNumberSection
            Divider()
            allThreeVariants
            Divider()
            metricsSection
            Divider()
            expenseSection
            footer
        }
        .frame(width: 390)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "flame.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("FIRE Calculator India")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("My FIRE Summary")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Target Age")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(Int(inputs.retirementAge)) yrs")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.fireIndigo, Color.firePurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Primary FIRE Number

    private var fireNumberSection: some View {
        VStack(spacing: 6) {
            Text("PRIMARY FIRE NUMBER")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .tracking(1)

            Text(result.fireNumber.inrCompact)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.fireIndigo)

            Text(result.fireNumber.inrFull)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                Label("4% withdrawal rate", systemImage: "chart.line.downtrend.xyaxis")
                Text("·")
                Text("×25 multiplier")
            }
            .font(.caption2)
            .foregroundStyle(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
    }

    // MARK: - All Three Variants

    private var allThreeVariants: some View {
        VStack(spacing: 0) {
            Text("ALL FIRE VARIANTS")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)

            HStack(spacing: 0) {
                variantColumn(
                    label: "Lean FIRE",
                    subtitle: "×20 · 5% SWR",
                    value: result.leanFIRE,
                    color: .fireSky
                )
                Divider().frame(height: 56)
                variantColumn(
                    label: "FIRE",
                    subtitle: "×25 · 4% SWR",
                    value: result.fireNumber,
                    color: .fireIndigo,
                    isPrimary: true
                )
                Divider().frame(height: 56)
                variantColumn(
                    label: "Fat FIRE",
                    subtitle: "×33 · 3% SWR",
                    value: result.fatFIRE,
                    color: .firePurple
                )
            }
            .padding(.bottom, 16)
        }
    }

    private func variantColumn(label: String, subtitle: String, value: Double, color: Color, isPrimary: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(isPrimary ? .caption.bold() : .caption)
                .foregroundStyle(isPrimary ? color : .secondary)
            Text(value.inrCompact)
                .font(.subheadline.bold())
                .foregroundStyle(isPrimary ? color : .primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundStyle(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(isPrimary ? color.opacity(0.06) : Color.clear)
    }

    // MARK: - Key Metrics

    private var metricsSection: some View {
        VStack(spacing: 0) {
            Text("KEY METRICS")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)

            HStack(spacing: 0) {
                metricColumn(
                    icon: "arrow.up.circle.fill",
                    label: "Monthly SIP",
                    value: result.isAlreadyFIRE ? "Already FIRE!" : result.monthlySIPNeeded.inrFull,
                    color: result.isAlreadyFIRE ? .fireEmerald : .fireRose
                )
                Divider().frame(height: 56)
                metricColumn(
                    icon: "calendar.badge.clock",
                    label: "Years to FIRE",
                    value: "\(result.yearsToRetirement) years",
                    color: .fireIndigo
                )
                Divider().frame(height: 56)
                metricColumn(
                    icon: "banknote.fill",
                    label: "Total Corpus",
                    value: result.totalCorpusAtRetirement.inrCompact,
                    color: .fireAmber
                )
            }
            .padding(.bottom, 16)
        }
    }

    private func metricColumn(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(color)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Expense Section

    private var expenseSection: some View {
        HStack(spacing: 0) {
            expenseBlock(
                icon: "house.fill",
                label: "Monthly Today",
                value: (result.currentAnnualExpense / 12).inrFull,
                highlight: false
            )
            VStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text("\(result.yearsToRetirement) yrs")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            expenseBlock(
                icon: "flag.checkered",
                label: "At Retirement",
                value: (result.futureAnnualExpense / 12).inrCompact,
                highlight: true
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.5))
    }

    private func expenseBlock(icon: String, label: String, value: String, highlight: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(highlight ? Color.fireIndigo : Color.secondary)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(highlight ? Color.fireIndigo : Color.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(.caption2)
                Text("Age \(Int(inputs.currentAge)) → \(Int(inputs.retirementAge))")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.secondary.opacity(0.5))

            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption2)
                Text("\(String(format: "%.0f%%", inputs.inflationRate * 100)) inflation")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)

            Spacer()

            Text("firecalc.in")
                .font(.caption2.bold())
                .foregroundStyle(Color.fireIndigo.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
