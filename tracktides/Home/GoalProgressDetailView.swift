import SwiftUI

// MARK: - Goal Progress Detail View

struct GoalProgressDetailView: View {
    private let startWeight: Double = 250
    private let currentWeight: Double = 230
    private let goalWeight: Double = 180

    private var progress: Double {
        (startWeight - currentWeight) / (startWeight - goalWeight)
    }

    private var remaining: Double {
        currentWeight - goalWeight
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                progressSection
                projectionSection
                statsSection
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Goal Progress")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .blue) {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 20)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))

                        VStack {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("Complete")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 180, height: 180)

                    HStack {
                        VStack {
                            Text("\(Int(startWeight))")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Start")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("\(Int(currentWeight))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                            Text("Current")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("\(Int(goalWeight))")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Goal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }

    private var projectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projection")
                .font(.title2)
                .fontWeight(.bold)

            HealthDetailCard(color: .blue) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text("Estimated Goal Date")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("May 2026")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    Text("~14 weeks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                StatCard(title: "Lost", value: "20", unit: "lb", color: .green)
                StatCard(title: "Remaining", value: "\(Int(remaining))", unit: "lb", color: .blue)
            }
        }
    }
}

// MARK: - Preview

#Preview("Goal Progress Detail") {
    NavigationStack {
        GoalProgressDetailView()
    }
}
