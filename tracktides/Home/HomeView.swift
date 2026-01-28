import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @Binding var scrollToChartSection: ChartSection?

    /// Sample data - in production these would come from a data store
    private let sampleShots: [Shot] = [
        Shot(
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            medication: "Tirzepatide",
            dosage: "15mg",
            injectionSite: "Stomach - Lower Left",
            painLevel: 2,
            notes: "Felt some mild nausea a few hours after."
        ),
        Shot(
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            medication: "Tirzepatide",
            dosage: "12.5mg",
            injectionSite: "Thigh - Right",
            painLevel: 1,
            notes: ""
        ),
        Shot(
            date: Calendar.current.date(byAdding: .day, value: -21, to: Date()) ?? Date(),
            medication: "Tirzepatide",
            dosage: "12.5mg",
            injectionSite: "Stomach - Upper Right",
            painLevel: 3,
            notes: "First dose at this level."
        )
    ]

    // Weight data
    private let startingWeight: Double = 250.0
    private let currentWeight: Double = 230.0
    private let goalWeight: Double = 180.0
    private let heightInches: Double = 70.0

    /// Shot schedule (weekly)
    private let shotIntervalDays: Int = 7

    @State private var showingAddShot: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    pinnedSection
                    resultsSection
                    shotHistorySection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddShot = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Add shot")
                }
            }
            .sheet(isPresented: $showingAddShot) {
                AddShotView()
            }
        }
    }
}

// MARK: - Pinned Section

private extension HomeView {
    var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pinned")
                .font(.title2)
                .fontWeight(.bold)

            nextShotCard
        }
    }

    var nextShotCard: some View {
        let lastShotDate = sampleShots.first?.date
        let nextDate = lastShotDate.flatMap {
            Calendar.current.date(byAdding: .day, value: shotIntervalDays, to: $0)
        }
        let isOverdue = nextDate.map { Date() > $0 } ?? false

        return Button {
            showingAddShot = true
        } label: {
            HealthCard(
                title: "Next Shot",
                color: isOverdue ? .orange : .red,
                timestamp: nextDate?.formatted(.dateTime.month().day()) ?? "Not scheduled",
                showChevron: true
            ) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        if isOverdue {
                            Text("Overdue")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                        } else {
                            Text("Scheduled")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let nextDate {
                            NextShotCountdown(targetDate: nextDate, isOverdue: isOverdue)
                        } else {
                            Text("--")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                        }
                    }
                    Spacer()
                    if isOverdue {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange)
                    } else {
                        Image(systemName: "syringe.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red.opacity(0.3))
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Results Section

private extension HomeView {
    var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Results")
                .font(.title2)
                .fontWeight(.bold)

            // Weight Card - navigates to Charts
            Button {
                scrollToChartSection = .weight
                selectedTab = .charts
            } label: {
                HealthCard(
                    title: "Weight",
                    color: .orange,
                    timestamp: "Today",
                    showChevron: true
                ) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(currentWeight))")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("lb")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        WeightSparkline(color: .orange)
                    }
                }
            }
            .buttonStyle(.plain)

            // Weight Change Card
            Button {
                scrollToChartSection = .weightChange
                selectedTab = .charts
            } label: {
                HealthCard(
                    title: "Weight Change",
                    color: .green,
                    timestamp: "Since Start",
                    showChevron: true
                ) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Loss")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("-\(Int(startingWeight - currentWeight))")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.green)
                                Text("lb")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        WeightLossSparkline(color: .green)
                    }
                }
            }
            .buttonStyle(.plain)

            // Progress to Goal Card
            NavigationLink {
                GoalProgressDetailView()
            } label: {
                HealthCard(
                    title: "Goal Progress",
                    color: .blue,
                    timestamp: "Goal: \(Int(goalWeight)) lb",
                    showChevron: true
                ) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Remaining")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(currentWeight - goalWeight))")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("lb to go")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        GoalProgressRing(
                            progress: (startingWeight - currentWeight) / (startingWeight - goalWeight),
                            color: .blue
                        )
                    }
                }
            }
            .buttonStyle(.plain)

            // BMI Card
            let currentBMI = calculateBMI(weight: currentWeight, heightInches: heightInches)
            NavigationLink {
                BMIDetailView()
            } label: {
                HealthCard(
                    title: "BMI",
                    color: .purple,
                    timestamp: "Current",
                    showChevron: true
                ) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bmiCategory(bmi: currentBMI))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(String(format: "%.1f", currentBMI))
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                            }
                        }
                        Spacer()
                        BMIGauge(bmi: currentBMI, color: .purple)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    func calculateBMI(weight: Double, heightInches: Double) -> Double {
        (weight * 703) / (heightInches * heightInches)
    }

    func bmiCategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: "Underweight"
        case 18.5..<25: "Normal"
        case 25..<30: "Overweight"
        default: "Obese"
        }
    }
}

// MARK: - Shot History Section

private extension HomeView {
    var shotHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Injections")
                .font(.title2)
                .fontWeight(.bold)

            // Last Shot Card
            if let lastShot = sampleShots.first {
                NavigationLink {
                    ShotHistoryView(shots: sampleShots)
                } label: {
                    HealthCard(
                        title: "Last Injection",
                        color: .red,
                        timestamp: lastShot.date.formatted(.dateTime.month().day()),
                        showChevron: true
                    ) {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lastShot.medication)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(lastShot.dosage)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Shot #\(sampleShots.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(lastShot.injectionSite)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            // Total Shots Card
            NavigationLink {
                ShotHistoryView(shots: sampleShots)
            } label: {
                HealthCard(
                    title: "Total Injections",
                    color: .red,
                    timestamp: "All Time",
                    showChevron: true
                ) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Completed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(sampleShots.count)")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("shots")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        ShotHistoryBars(shotCount: sampleShots.count, color: .red)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView(selectedTab: .constant(.home), scrollToChartSection: .constant(nil))
}
