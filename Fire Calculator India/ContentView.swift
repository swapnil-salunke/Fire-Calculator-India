import SwiftUI

struct ContentView: View {
    @State private var inputs = FIREInputs()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            InputScreen(inputs: $inputs) {
                path.append(AppRoute.result)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .result:
                    ResultScreen(inputs: $inputs) {
                        path.append(AppRoute.investment)
                    }
                case .investment:
                    InvestmentScreen(inputs: $inputs)
                }
            }
        }
        .tint(.white)
    }
}

enum AppRoute: Hashable {
    case result
    case investment
}

#Preview("Light") {
    ContentView()
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
