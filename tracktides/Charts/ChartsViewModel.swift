import Foundation

// MARK: - Charts View Model

@MainActor
@Observable
final class ChartsViewModel {
    // MARK: - State

    var entries: [DayEntry] = []
    var selectedTimeRange: ChartTimeRange = .month

    // MARK: - Computed Data (cached via @Observable)

    var allWeightData: [ChartDataPoint] {
        entries.compactMap { entry in
            guard let weight = entry.weight else { return nil }
            return ChartDataPoint(date: entry.date, value: weight)
        }.sorted { $0.date < $1.date }
    }

    var allPainData: [ChartDataPoint] {
        entries.compactMap { entry in
            guard let shot = entry.shot, shot.painLevel > 0 else { return nil }
            return ChartDataPoint(date: entry.date, value: Double(shot.painLevel))
        }.sorted { $0.date < $1.date }
    }

    var startingWeight: Double {
        allWeightData.first?.value ?? 180
    }

    var allWeightChangeData: [ChartDataPoint] {
        allWeightData.map { point in
            ChartDataPoint(
                date: point.date,
                value: point.value - startingWeight,
                isAggregate: point.isAggregate
            )
        }
    }

    // MARK: - Visible Data (filtered by time range)

    var weightData: [ChartDataPoint] {
        filterByTimeRange(allWeightData)
    }

    var painData: [ChartDataPoint] {
        filterByTimeRange(allPainData)
    }

    var weightChangeData: [ChartDataPoint] {
        filterByTimeRange(allWeightChangeData)
    }

    // MARK: - Ranges

    var weightRange: ClosedRange<Double> {
        calculateRange(for: weightData, fallback: 150...200)
    }

    var weightChangeRange: ClosedRange<Double> {
        calculateRange(for: weightChangeData, fallback: -30...5, minPadding: 2)
    }

    // MARK: - Averages

    var weightAverage: Double {
        calculateAverage(for: weightData)
    }

    var painAverage: Double {
        calculateAverage(for: painData)
    }

    var weightChangeAverage: Double {
        calculateAverage(for: weightChangeData)
    }

    // MARK: - Data Loading

    func loadSampleData() {
        let calendar = Calendar.current
        let today = Date()

        entries = (0..<400).compactMap { dayOffset -> DayEntry? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return nil
            }

            // Skip some days randomly for realistic data
            if Int.random(in: 0..<10) < 2 { return nil }

            let hasShot = dayOffset % 7 == 0
            let shot: Shot? = hasShot
                ? Shot(
                    date: date,
                    medication: "Tirzepatide",
                    dosage: "2.5mg",
                    injectionSite: "Abdomen",
                    painLevel: Int.random(in: 1...5)
                )
                : nil

            let baseWeight = 180.0 - Double(dayOffset) * 0.03
            let variation = Double.random(in: -1.5...1.5)

            return DayEntry(
                date: date,
                shot: shot,
                weight: baseWeight + variation,
                sideEffects: [],
                notes: ""
            )
        }
    }

    // MARK: - Private Helpers

    private func filterByTimeRange(_ data: [ChartDataPoint]) -> [ChartDataPoint] {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-selectedTimeRange.visibleDomainLength)
        return data.filter { $0.date >= startDate && $0.date <= endDate }
    }

    private func calculateRange(
        for data: [ChartDataPoint],
        fallback: ClosedRange<Double>,
        minPadding: Double = 5
    ) -> ClosedRange<Double> {
        let values = data.map(\.value)
        guard let minVal = values.min(), let maxVal = values.max() else {
            return fallback
        }
        let padding = max((maxVal - minVal) * 0.1, minPadding)
        return (minVal - padding)...(maxVal + padding)
    }

    private func calculateAverage(for data: [ChartDataPoint]) -> Double {
        guard !data.isEmpty else { return 0 }
        return data.map(\.value).reduce(0, +) / Double(data.count)
    }
}
