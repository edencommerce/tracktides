import Charts
import SwiftUI

// MARK: - Chart Section

enum ChartSection: String, CaseIterable {
    case weight
    case weightChange
    case injectionPain
}

// MARK: - Time Range

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case day = "D"
    case week = "W"
    case month = "M"
    case sixMonths = "6M"
    case year = "Y"

    var id: String {
        rawValue
    }

    var visibleDomainLength: TimeInterval {
        switch self {
        case .day: 3_600 * 24
        case .week: 3_600 * 24 * 7
        case .month: 3_600 * 24 * 30
        case .sixMonths: 3_600 * 24 * 180
        case .year: 3_600 * 24 * 365
        }
    }

    func dateRangeText(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        switch self {
        case .day:
            formatter.dateFormat = "EEE, MMM d, yyyy"
            return formatter.string(from: endDate)
        case .week:
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: endDate)
            return "\(start)–\(end), \(year)"
        case .month:
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startDate)
            formatter.dateFormat = "MMM d, yyyy"
            let end = formatter.string(from: endDate)
            return "\(start)–\(end)"
        case .sixMonths:
            formatter.dateFormat = "MMM d, yyyy"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "\(start)–\(end)"
        case .year:
            formatter.dateFormat = "MMM yyyy"
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            return "\(start)–\(end)"
        }
    }
}

// MARK: - Chart Data Point

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isAggregate: Bool

    init(date: Date, value: Double, isAggregate: Bool = false) {
        self.date = date
        self.value = value
        self.isAggregate = isAggregate
    }
}

// MARK: - Data Aggregation

enum ChartDataAggregator {
    static func aggregateByWeek(_ data: [ChartDataPoint]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var weeklyGroups: [Date: [Double]] = [:]

        for point in data {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: point.date)?.start else {
                continue
            }
            weeklyGroups[weekStart, default: []].append(point.value)
        }

        return weeklyGroups.map { weekStart, values in
            let average = values.reduce(0, +) / Double(values.count)
            let midWeek = calendar.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart
            return ChartDataPoint(date: midWeek, value: average, isAggregate: true)
        }.sorted { $0.date < $1.date }
    }

    static func aggregateByMonth(_ data: [ChartDataPoint]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var monthlyGroups: [Date: [Double]] = [:]

        for point in data {
            guard let monthStart = calendar.dateInterval(of: .month, for: point.date)?.start else {
                continue
            }
            monthlyGroups[monthStart, default: []].append(point.value)
        }

        return monthlyGroups.map { monthStart, values in
            let average = values.reduce(0, +) / Double(values.count)
            let midMonth = calendar.date(byAdding: .day, value: 14, to: monthStart) ?? monthStart
            return ChartDataPoint(date: midMonth, value: average, isAggregate: true)
        }.sorted { $0.date < $1.date }
    }
}

// MARK: - Native Chart Card

struct NativeChartCard: View {
    let title: String
    let data: [ChartDataPoint]
    let allData: [ChartDataPoint]
    let yRange: ClosedRange<Double>
    let unit: String
    let color: Color
    let timeRange: ChartTimeRange
    let average: Double
    var minYValue: Double?

    @State private var selectedDate: Date?
    @State private var scrollPosition: Date = .init()

    // MARK: - Computed Properties

    private var chartDisplayData: [ChartDataPoint] {
        switch timeRange {
        case .day, .week, .month:
            allData
        case .sixMonths:
            ChartDataAggregator.aggregateByWeek(allData)
        case .year:
            ChartDataAggregator.aggregateByMonth(allData)
        }
    }

    private var selectedPoint: ChartDataPoint? {
        guard let selectedDate else { return nil }
        return chartDisplayData.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })
    }

    private var visibleStartDate: Date {
        scrollPosition.addingTimeInterval(-timeRange.visibleDomainLength)
    }

    private var visibleEndDate: Date {
        scrollPosition
    }

    private var visibleData: [ChartDataPoint] {
        chartDisplayData.filter { $0.date >= visibleStartDate && $0.date <= visibleEndDate }
    }

    private var visibleAverage: Double {
        guard !visibleData.isEmpty else { return average }
        return visibleData.map(\.value).reduce(0, +) / Double(visibleData.count)
    }

    private var visibleYRange: ClosedRange<Double> {
        let values = visibleData.map(\.value)
        guard let minVal = values.min(), let maxVal = values.max() else {
            return yRange
        }
        let padding = max((maxVal - minVal) * 0.1, 5)
        let lowerBound = if let minY = minYValue {
            max(minVal - padding, minY)
        } else {
            minVal - padding
        }
        return lowerBound...(maxVal + padding)
    }

    private var showAverageLabel: Bool {
        if let point = selectedPoint {
            return point.isAggregate
        }
        return true
    }

    private var displayValue: Double {
        selectedPoint?.value ?? visibleAverage
    }

    private var displayDateText: String {
        if let point = selectedPoint {
            return formatSelectedDate(point.date)
        }
        return timeRange.dateRangeText(from: visibleStartDate, to: visibleEndDate)
    }

    private var xAxisStride: Calendar.Component {
        switch timeRange {
        case .day: .hour
        case .week: .day
        case .month: .day
        case .sixMonths: .month
        case .year: .month
        }
    }

    private var xAxisCount: Int {
        switch timeRange {
        case .day: 6
        case .week: 1
        case .month: 7
        case .sixMonths: 1
        case .year: 1
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            summarySection

            chartView
                .frame(height: 220)
        }
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
        .onAppear {
            scrollPosition = Date()
        }
        .onChange(of: timeRange) { _, _ in
            scrollPosition = Date()
            selectedDate = nil
        }
    }

    // MARK: - Subviews

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("AVERAGE")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .opacity(showAverageLabel ? 1 : 0)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatValue(displayValue))
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(unit)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text(displayDateText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var chartView: some View {
        Chart {
            ForEach(chartDisplayData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .symbol {
                    Circle()
                        .strokeBorder(color, lineWidth: 2)
                        .background(Circle().fill(Color(uiColor: .systemBackground)))
                        .frame(width: 8, height: 8)
                }
            }

            if let selectedDate {
                RuleMark(x: .value("Selected", selectedDate))
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1))
            }

            if let point = selectedPoint {
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .symbol {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                }
            }
        }
        .chartYScale(domain: visibleYRange)
        .chartXAxis {
            AxisMarks(values: .stride(by: xAxisStride, count: xAxisCount)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    .foregroundStyle(.secondary.opacity(0.3))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(formatAxisLabel(date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    .foregroundStyle(.secondary.opacity(0.3))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(doubleValue))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: timeRange.visibleDomainLength)
        .chartScrollPosition(x: $scrollPosition)
        .chartXSelection(value: $selectedDate)
    }

    // MARK: - Formatting Helpers

    private func formatAxisLabel(_ date: Date) -> String {
        let formatter = DateFormatter()

        switch timeRange {
        case .day:
            formatter.dateFormat = "ha"
            return formatter.string(from: date).lowercased()
        case .week:
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        case .month:
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        case .sixMonths:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "MMMMM"
            return formatter.string(from: date)
        }
    }

    private func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()

        switch timeRange {
        case .day:
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        case .week:
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        case .month, .sixMonths:
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        case .year:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }

    private func formatValue(_ value: Double) -> String {
        if value == floor(value) {
            String(format: "%.0f", value)
        } else {
            String(format: "%.1f", value)
        }
    }
}
