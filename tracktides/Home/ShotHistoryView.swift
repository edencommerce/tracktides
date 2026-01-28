import SwiftUI

// MARK: - Shot History View

struct ShotHistoryView: View {
    let shots: [Shot]

    @State private var selectedShot: Shot?

    private var groupedShots: [(String, [Shot])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: shots) { shot -> String in
            let month = calendar.component(.month, from: shot.date)
            let year = calendar.component(.year, from: shot.date)
            return "\(year)-\(month)"
        }

        return grouped
            .map { key, shots -> (String, [Shot]) in
                let sortedShots = shots.sorted { $0.date > $1.date }
                guard let firstShot = sortedShots.first else {
                    return (key, sortedShots)
                }
                let monthYear = firstShot.date.formatted(.dateTime.month(.wide).year())
                return (monthYear, sortedShots)
            }
            .sorted { first, second in
                guard let firstShot = first.1.first,
                      let secondShot = second.1.first
                else {
                    return false
                }
                return firstShot.date > secondShot.date
            }
    }

    var body: some View {
        ScrollView {
            if shots.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCards
                    historySection
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Injections")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedShot) { shot in
            AddShotView(isEditing: true, date: shot.date)
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "syringe")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)

            Text("No Injections")
                .font(.title2)
                .fontWeight(.bold)

            Text("Your injection history will appear here once you start tracking.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var summaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)

            // Summary Cards in Apple Health style
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Total",
                    value: "\(shots.count)",
                    subtitle: "injections",
                    color: .red
                )

                SummaryCard(
                    title: "Tracking",
                    value: daysSinceFirstShot,
                    subtitle: "days",
                    color: .blue
                )

                SummaryCard(
                    title: "Average",
                    value: averageInterval,
                    subtitle: "interval",
                    color: .green
                )
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(groupedShots, id: \.0) { monthYear, monthShots in
                VStack(alignment: .leading, spacing: 12) {
                    Text(monthYear)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                    ForEach(monthShots) { shot in
                        ShotHistoryCard(shot: shot, shotNumber: shotNumber(for: shot))
                            .onTapGesture {
                                selectedShot = shot
                            }
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Helpers

    private var daysSinceFirstShot: String {
        guard let firstShot = shots.min(by: { $0.date < $1.date }) else {
            return "--"
        }
        let days = Calendar.current.dateComponents([.day], from: firstShot.date, to: Date()).day ?? 0
        return "\(days)"
    }

    private var averageInterval: String {
        guard shots.count > 1 else { return "--" }

        let sortedShots = shots.sorted { $0.date < $1.date }
        var totalInterval: TimeInterval = 0

        for index in 1..<sortedShots.count {
            totalInterval += sortedShots[index].date.timeIntervalSince(sortedShots[index - 1].date)
        }

        let averageDays = Int(totalInterval / Double(shots.count - 1) / 86_400)
        return "\(averageDays)d"
    }

    private func shotNumber(for shot: Shot) -> Int {
        let sortedByDate = shots.sorted { $0.date < $1.date }
        guard let index = sortedByDate.firstIndex(where: { $0.id == shot.id }) else {
            return 0
        }
        return index + 1
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
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

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Shot History Card

private struct ShotHistoryCard: View {
    let shot: Shot
    let shotNumber: Int

    private var sideEffects: [String] {
        if !shot.notes.isEmpty {
            return ["Nausea", "Fatigue"]
        }
        return []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text(shot.medication)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
                Spacer()
                HStack(spacing: 4) {
                    Text(shot.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
            }

            // Content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shot #\(shotNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(shot.dosage)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(shot.injectionSite)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if shot.painLevel > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("\(shot.painLevel)/10")
                                .font(.caption)
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }

            // Side Effects & Notes
            if !sideEffects.isEmpty || !shot.notes.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    if !sideEffects.isEmpty {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 6, height: 6)
                            Text(sideEffects.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !shot.notes.isEmpty {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 6, height: 6)
                            Text(shot.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Previews

#Preview("With Shots") {
    NavigationStack {
        ShotHistoryView(shots: [
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
        ])
    }
}

#Preview("Empty") {
    NavigationStack {
        ShotHistoryView(shots: [])
    }
}
