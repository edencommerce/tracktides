@preconcurrency import Inject
import SwiftUI

// MARK: - Appearance Setting

enum AppAppearance: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

@main
struct TracktidesApp: App {
    @AppStorage("appAppearance") private var appearanceSetting: Int = 0
    @State private var showSplash = true

    private var colorScheme: ColorScheme? {
        AppAppearance(rawValue: appearanceSetting)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(colorScheme)
            .onAppear {
                #if DEBUG
                    InjectConfiguration.animation = .interactiveSpring()
                #endif
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
