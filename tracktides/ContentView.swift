import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isExpanded = false
    @Namespace private var glassNamespace

    var body: some View {
        ZStack {
            // Background content
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Liquid Glass UI layer
            GlassEffectContainer {
                VStack(spacing: 32) {
                    // Header with glass effect
                    VStack(spacing: 12) {
                        Text("tracktides")
                            .font(.system(size: 48, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Built with Liquid Glass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(24)
                    .glassEffect()

                    Spacer()

                    // Interactive glass card
                    if isExpanded {
                        VStack(spacing: 20) {
                            Text("Welcome to iOS 26")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.white)

                            Text("Experience the fluidity and translucence of Apple's Liquid Glass design language")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)

                            HStack(spacing: 16) {
                                Button("Dismiss") {
                                    withAnimation(.smooth) {
                                        isExpanded = false
                                    }
                                }
                                .buttonStyle(.glass)

                                Button("Learn More") {
                                    // Action
                                }
                                .buttonStyle(.glassProminent)
                            }
                        }
                        .padding(32)
                        .glassEffect(.regular.tint(.blue.opacity(0.3)))
                        .glassEffectID("infoCard", in: glassNamespace)
                    } else {
                        Button("Tap to Explore") {
                            withAnimation(.smooth) {
                                isExpanded = true
                            }
                        }
                        .padding(24)
                        .glassEffect(.regular.interactive())
                        .glassEffectID("infoCard", in: glassNamespace)
                    }

                    Spacer()

                    // Bottom navigation with glass tabs
                    HStack(spacing: 40) {
                        TabButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }

                        TabButton(icon: "chart.line.uptrend.xyaxis", title: "Track", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }

                        TabButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .glassEffect(.clear)
                }
                .padding()
            }
        }
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
