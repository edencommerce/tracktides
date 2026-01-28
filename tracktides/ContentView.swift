import Inject
import SwiftUI
import UIKit

struct ContentView: View {
    @ObserveInjection var inject
    @State private var selectedTab: AppTab = .home
    @State private var scrollToChartSection: ChartSection?

    /// Reusable haptic generator - prepared once for responsive feedback
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView(
                    selectedTab: $selectedTab,
                    scrollToChartSection: $scrollToChartSection
                )
            }

            Tab("Calendar", systemImage: "calendar", value: .calendar) {
                CalendarView()
            }

            Tab("Charts", systemImage: "chart.line.uptrend.xyaxis", value: .charts) {
                ChartsView(scrollToSection: $scrollToChartSection)
            }

            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileView()
            }
        }
        .onAppear {
            hapticGenerator.prepare()
        }
        .onChange(of: selectedTab) {
            hapticGenerator.impactOccurred()
        }
        .enableInjection()
    }
}

#Preview {
    ContentView()
}
