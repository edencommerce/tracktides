import Foundation

// MARK: - Charts View Model

@MainActor
@Observable
final class ChartsViewModel {
    // MARK: - State

    var entries: [DayEntry] = [] {
        didSet { invalidateEntriesCache() }
    }

    var selectedTimeRange: ChartTimeRange = .month {
        didSet { invalidateFilteredCache() }
    }

    // MARK: - Cached Data

    private var _cachedAllWeightData: [ChartDataPoint]?
    private var _cachedAllPainData: [ChartDataPoint]?
    private var _cachedAllWeightChangeData: [ChartDataPoint]?
    private var _cachedStartingWeight: Double?
    private var _cachedWeightData: [ChartDataPoint]?
    private var _cachedPainData: [ChartDataPoint]?
    private var _cachedWeightChangeData: [ChartDataPoint]?

    private func invalidateEntriesCache() {
        _cachedAllWeightData = nil
        _cachedAllPainData = nil
        _cachedAllWeightChangeData = nil
        _cachedStartingWeight = nil
        invalidateFilteredCache()
    }

    private func invalidateFilteredCache() {
        _cachedWeightData = nil
        _cachedPainData = nil
        _cachedWeightChangeData = nil
    }

    // MARK: - Computed Data (with caching)

    var allWeightData: [ChartDataPoint] {
        if let cached = _cachedAllWeightData { return cached }
        let result = entries.compactMap { entry -> ChartDataPoint? in
            guard let weight = entry.weight else { return nil }
            return ChartDataPoint(date: entry.date, value: weight)
        }.sorted { $0.date < $1.date }
        _cachedAllWeightData = result
        return result
    }

    var allPainData: [ChartDataPoint] {
        if let cached = _cachedAllPainData { return cached }
        let result = entries.compactMap { entry -> ChartDataPoint? in
            guard let shot = entry.shot, shot.painLevel > 0 else { return nil }
            return ChartDataPoint(date: entry.date, value: Double(shot.painLevel))
        }.sorted { $0.date < $1.date }
        _cachedAllPainData = result
        return result
    }

    var startingWeight: Double {
        if let cached = _cachedStartingWeight { return cached }
        let result = allWeightData.first?.value ?? 180
        _cachedStartingWeight = result
        return result
    }

    var allWeightChangeData: [ChartDataPoint] {
        if let cached = _cachedAllWeightChangeData { return cached }
        let starting = startingWeight
        let result = allWeightData.map { point in
            ChartDataPoint(
                date: point.date,
                value: point.value - starting,
                isAggregate: point.isAggregate
            )
        }
        _cachedAllWeightChangeData = result
        return result
    }

    // MARK: - Visible Data (filtered by time range, cached)

    var weightData: [ChartDataPoint] {
        if let cached = _cachedWeightData { return cached }
        let result = filterByTimeRange(allWeightData)
        _cachedWeightData = result
        return result
    }

    var painData: [ChartDataPoint] {
        if let cached = _cachedPainData { return cached }
        let result = filterByTimeRange(allPainData)
        _cachedPainData = result
        return result
    }

    var weightChangeData: [ChartDataPoint] {
        if let cached = _cachedWeightChangeData { return cached }
        let result = filterByTimeRange(allWeightChangeData)
        _cachedWeightChangeData = result
        return result
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
