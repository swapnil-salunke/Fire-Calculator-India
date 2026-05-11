//
//  Fire_Calculator_IndiaApp.swift
//  Fire Calculator India
//
//  Created by Swapnil Salunke on 11/05/26.
//

import SwiftUI

@main
struct Fire_Calculator_IndiaApp: App {
    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if isLaunching {
                    LaunchScreen()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                // Brief delay lets the first frame of ContentView render,
                // then fades the launch screen away.
                try? await Task.sleep(for: .seconds(1.2))
                withAnimation(.easeOut(duration: 0.4)) {
                    isLaunching = false
                }
            }
        }
    }
}
