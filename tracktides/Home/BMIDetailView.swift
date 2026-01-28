import SwiftUI

// MARK: - BMI Detail View

struct BMIDetailView: View {
    private let currentBMI: Double = 33.0
    private let goalBMI: Double = 25.8

    private var bmiRanges: [BMIRange] {
        [
            BMIRange(name: "Underweight", range: 0...18.5, color: .blue),
            BMIRange(name: "Normal", range: 18.5...25, color: .green),
            BMIRange(name: "Overweight", range: 25...30, color: .yellow),
            BMIRange(name: "Obese", range: 30...100, color: .red)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                currentSection
                scaleSection
                infoSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("BMI")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var currentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .purple) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body Mass Index")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", currentBMI))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                        }
                        Text("Obese")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    BMIGaugeView(bmi: currentBMI)
                }
            }
        }
    }

    private var scaleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BMI Scale")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .purple) {
                VStack(spacing: 16) {
                    ForEach(bmiRanges, id: \.name) { bmiRange in
                        HStack {
                            Circle()
                                .fill(bmiRange.color)
                                .frame(width: 12, height: 12)
                            Text(bmiRange.name)
                            Spacer()
                            Text(bmiRange.displayText)
                                .foregroundStyle(.secondary)
                            if bmiRange.range.contains(currentBMI) {
                                Image(systemName: "arrow.left")
                                    .foregroundStyle(bmiRange.color)
                            }
                        }
                    }
                }
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .purple) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Target BMI")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f", goalBMI))
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Overweight (upper)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Reduction needed")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(format: "-%.1f", currentBMI - goalBMI))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("BMI Detail") {
    NavigationStack {
        BMIDetailView()
    }
}
