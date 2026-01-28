import Charts
import SwiftUI

// MARK: - Weight Detail View

struct WeightDetailView: View {
    /// Sample weight data
    private let weightData: [WeightEntry] = {
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                currentStatsSection
                chartSection
                historySection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var currentStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .orange) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("230")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("lb")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("-20 lb")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                        Text("from start")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .orange) {
                Chart(weightData) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.orange.gradient)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(.orange.opacity(0.1).gradient)
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 220...255)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 200)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(weightData.suffix(7).reversed()) { entry in
                HealthDetailCard(color: .orange) {
                    HStack {
                        Text(entry.date.formatted(.dateTime.weekday(.abbreviated).month().day()))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(entry.weight)) lb")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Weight Detail") {
    NavigationStack {
        WeightDetailView()
    }
}
