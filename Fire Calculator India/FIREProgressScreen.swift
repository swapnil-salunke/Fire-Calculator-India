import SwiftUI

// MARK: - FIRE Progress Screen

struct FIREProgressScreen: View {
    @Binding var inputs: FIREInputs
    @State private var selectedMode: InvestmentMode = .balanced
    @State private var selectedTarget: FIRETarget = .fire

    private var result: FIREResult {
        FIRECalculator.calculate(inputs: inputs, mode: selectedMode, target: selectedTarget)
    }

    private var fireDateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: result.projectedFIREDate)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                progressBarCard
                targetPicker
                modePicker
                corpusCard
                timelineCard
                statusCard
                disclaimerNote
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .padding(.bottom, 34)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("FIRE Progress")
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

    // MARK: - Progress Bar Card

    var progressBarCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Corpus Progress", systemImage: "chart.bar.fill")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            GeometryReader { geo in
                let barWidth = geo.size.width
                let fillWidth = barWidth * min(result.progressPercentage / 100, 1.0)

                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 24)

                    // Filled portion
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.fireIndigo, Color(hex: "7C3AED")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, fillWidth), height: 24)
                        .animation(.easeOut(duration: 0.8), value: result.progressPercentage)

                    // Milestone markers at 25 / 50 / 75 / 100%
                    ForEach([25, 50, 75, 100], id: \.self) { milestone in
                        let x = barWidth * (Double(milestone) / 100.0)
                        Rectangle()
                            .fill(Color(.systemGroupedBackground))
                            .frame(width: 2, height: 24)
                            .offset(x: x - 1)
                    }

                    // Current percentage pill
                    if fillWidth > 36 {
                        Text("\(Int(result.progressPercentage))%")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.fireIndigo.opacity(0.7))
                            .cornerRadius(6)
                            .offset(x: max(0, fillWidth - 34))
                            .animation(.easeOut(duration: 0.8), value: result.progressPercentage)
                    }
                }
            }
            .frame(height: 24)

            // Milestone labels
            HStack {
                ForEach([0, 25, 50, 75, 100], id: \.self) { m in
                    Text("\(m)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if m < 100 { Spacer() }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
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

    // MARK: - Corpus Card

    var corpusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Corpus Breakdown", systemImage: "indianrupeesign.circle.fill")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(spacing: 12) {
                corpusRow(
                    label: "Current Corpus at Retirement",
                    amount: result.existingCorpusAtRetirement,
                    color: .fireIndigo
                )
                Divider()
                corpusRow(
                    label: "FIRE Target",
                    amount: result.fireNumber,
                    color: .primary
                )
                Divider()

                let gap = result.fireNumber - result.existingCorpusAtRetirement
                HStack {
                    Text(gap <= 0 ? "Surplus" : "Shortfall")
                        .font(.subheadline.bold())
                        .foregroundColor(gap <= 0 ? .fireEmerald : .fireRose)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(abs(gap).inrCompact)
                            .font(.subheadline.bold())
                            .foregroundColor(gap <= 0 ? .fireEmerald : .fireRose)
                        Text(abs(gap).inrFull)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    func corpusRow(label: String, amount: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(amount.inrCompact)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                Text(amount.inrFull)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Timeline Card

    var timelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Timeline", systemImage: "calendar.badge.clock")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Projected FIRE Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(fireDateFormatted)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.fireIndigo)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 44)

                VStack(spacing: 4) {
                    Text("Years to Retirement")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(result.yearsToRetirement)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.fireIndigo)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Status Card

    var statusCard: some View {
        VStack(spacing: 14) {
            Label("Motivational Status", systemImage: "trophy.fill")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(result.motivationalColor.opacity(0.15))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: statusIcon)
                        .font(.system(size: 30))
                        .foregroundColor(result.motivationalColor)
                )

            Text(result.motivationalStatus)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("Next milestone: \(result.nextMilestonePercent)%")
                .font(.subheadline)
                .foregroundColor(result.motivationalColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(result.motivationalColor.opacity(0.1))
                .cornerRadius(20)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    private var statusIcon: String {
        switch result.progressPercentage {
        case 0..<25:   return "seedling"
        case 25..<50:  return "arrow.up.right.circle.fill"
        case 50..<75:  return "flame.fill"
        case 75..<100: return "bolt.fill"
        default:       return "star.fill"
        }
    }

    // MARK: - Disclaimer

    var disclaimerNote: some View {
        Text("Progress is based on your existing savings compounded at the selected investment style's expected return. Actual results may vary. This is for educational purposes only.")
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}
