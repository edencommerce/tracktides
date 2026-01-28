import Foundation

enum AppTab {
    case home, calendar, charts, profile

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .calendar: "calendar"
        case .charts: "chart.line.uptrend.xyaxis"
        case .profile: "person.fill"
        }
    }

    var title: String {
        switch self {
        case .home: "Home"
        case .calendar: "Calendar"
        case .charts: "Charts"
        case .profile: "Profile"
        }
    }
}
