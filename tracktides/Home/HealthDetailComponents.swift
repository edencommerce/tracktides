import SwiftUI

// MARK: - Health Detail Card

struct HealthDetailCard<Content: View>: View {
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - BMI Gauge View

struct BMIGaugeView: View {
    let bmi: Double

    private var normalizedBMI: Double {
        let clamped = min(max(bmi, 15), 40)
        return (clamped - 15) / 25
    }

    private var bmiColor: Color {
        switch bmi {
        case ..<18.5: .blue
        case 18.5..<25: .green
        case 25..<30: .orange
        default: .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 0.75)
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: 0.25, to: 0.25 + normalizedBMI * 0.5)
                .stroke(bmiColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(90))
        }
        .frame(width: 80, height: 80)
    }
}

// MARK: - Data Models

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct WeightMilestone: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let label: String
}

struct BMIRange {
    let name: String
    let range: ClosedRange<Double>
    let color: Color

    var displayText: String {
        let upper = range.upperBound >= 100 ? "40+" : String(Int(range.upperBound))
        return "\(Int(range.lowerBound)) - \(upper)"
    }
}
