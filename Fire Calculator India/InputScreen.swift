import SwiftUI

struct InputScreen: View {
    @Binding var inputs: FIREInputs
    var onCalculate: () -> Void

    @FocusState private var focused: FocusedField?

    enum FocusedField { case expenses, savings }

    // Derive text directly from inputs so edits always round-trip correctly.
    // We use a local committed string only to allow free typing; on commit we
    // parse and write back to inputs.
    @State private var expensesText = ""
    @State private var savingsText  = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        headerBanner
                        formBody
                            .padding(.bottom, 110)
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .scrollDismissesKeyboard(.immediately)
                .onChange(of: focused) { _, newField in
                    guard let newField else { return }
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(newField, anchor: .center)
                    }
                }
            }

            calculateButton
        }
        .navigationTitle("FIRE Calculator")
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
        .onAppear {
            // Always sync text fields from the current inputs value,
            // including when navigating back from the result screen.
            expensesText = String(Int(inputs.monthlyExpenses))
            savingsText  = String(Int(inputs.existingSavings))
        }
        .onChange(of: inputs.monthlyExpenses) { _, val in
            let asString = String(Int(val))
            if expensesText != asString { expensesText = asString }
        }
        .onChange(of: inputs.existingSavings) { _, val in
            let asString = String(Int(val))
            if savingsText != asString { savingsText = asString }
        }
    }

    // MARK: - Header Banner

    var headerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Financial Independence, Retire Early")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("Find your FIRE number and monthly SIP")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Form

    var formBody: some View {
        VStack(spacing: 20) {

            // Personal Details
            section(title: "Personal Details", icon: "person.fill") {
                labeledSlider(
                    label: "Current Age",
                    value: $inputs.currentAge,
                    range: 18...60,
                    step: 1,
                    display: { "\(Int($0)) yrs" }
                )
                Divider().padding(.vertical, 4)
                labeledSlider(
                    label: "Target Retirement Age",
                    value: $inputs.retirementAge,
                    range: min(inputs.currentAge + 1, 69)...70,
                    step: 1,
                    display: { "\(Int($0)) yrs" }
                )
            }

            // Financial Details
            section(title: "Financial Details", icon: "indianrupeesign.circle.fill") {
                currencyRow(
                    label: "Monthly Expenses",
                    subtitle: "Your current lifestyle cost",
                    text: $expensesText,
                    field: .expenses
                ) { val in inputs.monthlyExpenses = val }
                .id(FocusedField.expenses)
                Divider().padding(.vertical, 4)
                currencyRow(
                    label: "Existing Savings",
                    subtitle: "Total invested corpus today",
                    text: $savingsText,
                    field: .savings
                ) { val in inputs.existingSavings = val }
                .id(FocusedField.savings)
            }

            // Assumptions
            section(title: "Assumptions", icon: "chart.line.uptrend.xyaxis") {
                labeledSlider(
                    label: "Inflation Rate",
                    value: $inputs.inflationRate,
                    range: 0.03...0.12,
                    step: 0.01,
                    display: { String(format: "%.0f%%", $0 * 100) }
                )
            }

            methodologyNote
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: - Calculate Button

    var calculateButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 24)

            Button(action: {
                focused = nil
                onCalculate()
            }) {
                HStack(spacing: 8) {
                    Text("Calculate My FIRE Number")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
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

    // MARK: - Reusable Builders

    @ViewBuilder
    func section<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(spacing: 14) {
                content()
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }

    func labeledSlider(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        display: @escaping (Double) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                Text(display(value.wrappedValue))
                    .font(.subheadline.bold())
                    .foregroundColor(.fireIndigo)
                    .monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
                .tint(.fireIndigo)
        }
    }

    func currencyRow(
        label: String,
        subtitle: String,
        text: Binding<String>,
        field: FocusedField,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Text("₹")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($focused, equals: field)
                    .font(.subheadline.bold())
                    .frame(width: 120)
                    .onChange(of: text.wrappedValue) { _, val in
                        // numberPad already prevents non-numeric input.
                        // Parse what's there; treat empty as 0.
                        let digits = val.filter { $0.isNumber }
                        onChange(Double(digits) ?? 0)
                    }
            }
        }
    }

    var methodologyNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Methodology", systemImage: "info.circle.fill")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                noteRow("Lean FIRE = annual expense at retirement × 20 (5% SWR)")
                noteRow("FIRE = annual expense × 25 (4% SWR — primary)")
                noteRow("Fat FIRE = annual expense × 33 (3% SWR — luxury lifestyle)")
                noteRow("SIP fills the gap between FIRE number and existing savings")
                noteRow("Expected return (9–14%) is set by investment style on the next screen")
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    func noteRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(Color.fireIndigo.opacity(0.5))
                .frame(width: 4, height: 4)
                .padding(.top, 5)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
