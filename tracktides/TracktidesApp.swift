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

    private var colorScheme: ColorScheme? {
        AppAppearance(rawValue: appearanceSetting)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
        }
    }
}
