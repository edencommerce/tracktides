import SwiftUI

// MARK: - Health Card Component

struct HealthCard<Content: View>: View {
    let title: String
    let color: Color
    let timestamp: String
    let showChevron: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(color)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text(timestamp)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            // Content
            content
        }
        .padding()
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - Next Shot Countdown

struct NextShotCountdown: View {
    let targetDate: Date
    let isOverdue: Bool

    @State private var timeRemaining: TimeInterval = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if isOverdue {
                let overdueDays = Int(abs(timeRemaining) / 86_400)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(overdueDays)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    Text(overdueDays == 1 ? "day overdue" : "days overdue")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            } else {
                let days = Int(timeRemaining / 86_400)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(days)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text(days == 1 ? "day" : "days")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            timeRemaining = targetDate.timeIntervalSince(Date())
        }
        .onReceive(timer) { _ in
            timeRemaining = targetDate.timeIntervalSince(Date())
        }
    }
}

// MARK: - Sparkline Charts

struct WeightSparkline: View {
    let color: Color

    /// Sample weight data points (last 7 days trend)
    private let dataPoints: [CGFloat] = [0.9, 0.85, 0.88, 0.82, 0.78, 0.75, 0.72]

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<dataPoints.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == dataPoints.count - 1 ? color : color.opacity(0.3))
                    .frame(width: 6, height: 40 * dataPoints[index])
            }
        }
        .frame(height: 40)
    }
}

struct WeightLossSparkline: View {
    let color: Color

    var body: some View {
        ZStack {
            // Downward trend line
            Path { path in
                path.move(to: CGPoint(x: 0, y: 5))
                path.addCurve(
                    to: CGPoint(x: 60, y: 35),
                    control1: CGPoint(x: 20, y: 10),
                    control2: CGPoint(x: 40, y: 30)
                )
            }
            .stroke(color.opacity(0.3), lineWidth: 2)

            // End dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .offset(x: 26, y: 12)
        }
        .frame(width: 60, height: 40)
    }
}

struct ShotHistoryBars: View {
    let shotCount: Int
    let color: Color

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<min(shotCount, 8), id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == min(shotCount, 8) - 1 ? color : color.opacity(0.3))
                    .frame(width: 6, height: CGFloat.random(in: 15...35))
            }
        }
        .frame(height: 40)
    }
}

// MARK: - Goal Progress Ring

struct GoalProgressRing: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 6)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: 50, height: 50)
    }
}

// MARK: - BMI Gauge

struct BMIGauge: View {
    let bmi: Double
    let color: Color

    private var normalizedBMI: Double {
        // Map BMI 15-40 to 0-1
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
            // Background arc
            Circle()
                .trim(from: 0.25, to: 0.75)
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                .rotationEffect(.degrees(90))

            // Colored segments
            Circle()
                .trim(from: 0.25, to: 0.25 + normalizedBMI * 0.5)
                .stroke(bmiColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(90))
        }
        .frame(width: 50, height: 50)
    }
}
