import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // Same gradient used throughout the app
            LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Flame icon in a rounded square — matches the app icon aesthetic
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 6) {
                    Text("FIRE Calculator")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("India")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .tracking(4)
                        .textCase(.uppercase)
                }
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
