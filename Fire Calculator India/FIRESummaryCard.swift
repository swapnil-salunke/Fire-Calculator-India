import SwiftUI

// MARK: - FIRESummaryCard
// Rendered to UIImage via ImageRenderer for sharing. Fixed 360pt width.

struct FIRESummaryCard: View {
    let result: FIREResult
    let inputs: FIREInputs

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            footer
        }
        .frame(width: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.title2.bold())
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("FIRE Calculator India")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("My FIRE Summary")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 16) {
            fireNumberRow
            Divider()
            metricsRow
            Divider()
            expensesRow
        }
        .padding(20)
    }

    private var fireNumberRow: some View {
        VStack(spacing: 4) {
            Text("FIRE Number")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(result.fireNumber.inrCompact)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.fireIndigo)
            Text(result.fireNumber.inrFull)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("4% SWR · ×25 multiplier")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }

    private var metricsRow: some View {
        HStack(spacing: 0) {
            summaryMetric(label: "Monthly SIP", value: result.isAlreadyFIRE ? "₹0" : result.monthlySIPNeeded.inrCompact, color: result.isAlreadyFIRE ? .fireEmerald : .fireRose)
            Divider().frame(height: 40)
            summaryMetric(label: "Years to FIRE", value: "\(result.yearsToRetirement)", color: .fireIndigo)
            Divider().frame(height: 40)
            summaryMetric(label: "Total Corpus", value: result.totalCorpusAtRetirement.inrCompact, color: .fireAmber)
        }
    }

    private func summaryMetric(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var expensesRow: some View {
        HStack(spacing: 0) {
            expenseBlock(label: "Today's Expenses", value: (result.currentAnnualExpense / 12).inrCompact)
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)
            expenseBlock(label: "At Retirement", value: (result.futureAnnualExpense / 12).inrCompact, highlight: true)
        }
    }

    private func expenseBlock(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(highlight ? .fireIndigo : .primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text("Age \(Int(inputs.currentAge)) → \(Int(inputs.retirementAge)) · \(String(format: "%.0f%%", inputs.inflationRate * 100)) inflation")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer()
            Text("firecalc.in")
                .font(.caption2.bold())
                .foregroundColor(.fireIndigo.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
    }
}
