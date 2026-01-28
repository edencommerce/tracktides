import Charts
import SwiftUI

// MARK: - Weight Change Detail View

struct WeightChangeDetailView: View {
    /// Generate weight change data showing loss over time
    private let weightChangeData: [WeightEntry] = {
        let calendar = Calendar.current
        var entries: [WeightEntry] = []
        let startWeight = 250.0
        var currentWeight = startWeight

        for dayOffset in stride(from: -90, through: 0, by: 1) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                // Simulate gradual weight loss with some variation
                currentWeight = max(startWeight - Double(abs(dayOffset)) * 0.22 + Double.random(in: -1...1), 225)
                entries.append(WeightEntry(date: date, weight: currentWeight))
            }
        }
        return entries
    }()

    private var milestones: [WeightMilestone] {
        let calendar = Calendar.current
        let today = Date()
        return [
            WeightMilestone(
                date: calendar.date(byAdding: .day, value: -90, to: today) ?? today,
                weight: 250,
                label: "Starting"
            ),
            WeightMilestone(
                date: calendar.date(byAdding: .day, value: -60, to: today) ?? today,
                weight: 245,
                label: "-5 lb"
            ),
            WeightMilestone(
                date: calendar.date(byAdding: .day, value: -30, to: today) ?? today,
                weight: 238,
                label: "-12 lb"
            ),
            WeightMilestone(date: today, weight: 230, label: "-20 lb")
        ]
    }

    private var startWeight: Double {
        250.0
    }

    private var currentWeight: Double {
        230.0
    }

    private var totalLoss: Double {
        startWeight - currentWeight
    }

    private var weeklyRate: Double {
        totalLoss / 13.0
    } // ~13 weeks

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summarySection
                chartSection
                milestonesSection
            }
            .padding()
            .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Weight Change")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                StatCard(title: "Lost", value: "\(Int(totalLoss))", unit: "lb", color: .green)
                StatCard(title: "Rate", value: String(format: "%.1f", weeklyRate), unit: "lb/wk", color: .blue)
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .green) {
                Chart(weightChangeData) { entry in
                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.green.opacity(0.15))
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.green.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 220...255)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 220)
            }
        }
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(milestones.reversed()) { milestone in
                HealthDetailCard(color: .green) {
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                        VStack(alignment: .leading) {
                            Text(milestone.label)
                                .font(.headline)
                            Text(milestone.date.formatted(.dateTime.month().day().year()))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Int(milestone.weight)) lb")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Weight Change Detail") {
    NavigationStack {
        WeightChangeDetailView()
    }
}
