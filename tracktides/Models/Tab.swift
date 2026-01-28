import Foundation

enum AppTab {
    case home, profile

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .profile: "Profile"
        }
    }
}
