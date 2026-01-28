import SwiftUI
import UIKit

// MARK: - Calendar Sheet Type

enum CalendarSheetType: Identifiable {
    case addShot(Date)
    case editShot(Date)
    case sideEffects(Date)
    case notes(Date)

    var id: String {
        switch self {
        case let .addShot(date): "addShot-\(date.timeIntervalSince1970)"
        case let .editShot(date): "editShot-\(date.timeIntervalSince1970)"
        case let .sideEffects(date): "sideEffects-\(date.timeIntervalSince1970)"
        case let .notes(date): "notes-\(date.timeIntervalSince1970)"
        }
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    /// Sample shot dates - in production this would come from a data store
    private let shotDates: Set<DateComponents> = {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        return [
            DateComponents(year: year, month: month, day: 13),
            DateComponents(year: year, month: month, day: 14)
        ]
    }()

    @State private var selectedDate: Date = .init()
    @State private var activeSheet: CalendarSheetType?

    private var dayHeaderText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else {
            return selectedDate.formatted(.dateTime.weekday(.wide))
        }
    }

    private var daySubtitleText: String {
        selectedDate.formatted(.dateTime.month(.wide).day())
    }

    private var hasShotOnSelectedDate: Bool {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let day = calendar.component(.day, from: selectedDate)
        let components = DateComponents(year: year, month: month, day: day)
        return shotDates.contains(components)
    }

    private var isSelectedDateInFuture: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected > today
    }

    /// Sample side effects - in production would come from data store
    private var sampleSideEffects: [String] {
        ["Nausea", "Fatigue"]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                GlassEffectContainer {
                    VStack(spacing: 32) {
                        CalendarGridView(
                            selectedDate: $selectedDate,
                            shotDates: shotDates
                        )
                        .frame(height: 340)

                        dayDetailSection
                    }
                    .padding(.top, 64)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    todayButton
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case let .addShot(date):
                    AddShotView(isEditing: false, date: date)
                case let .editShot(date):
                    AddShotView(isEditing: true, date: date)
                case let .sideEffects(date):
                    SideEffectsView(date: date)
                case let .notes(date):
                    NotesView(date: date)
                }
            }
        }
    }

    // MARK: - Subviews

    private var todayButton: some View {
        Button("Today") {
            withAnimation {
                selectedDate = Date()
            }
        }
        .fontWeight(.medium)
    }

    private var dayDetailSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date Header
            VStack(alignment: .leading, spacing: 2) {
                Text(dayHeaderText)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(daySubtitleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Cards
            VStack(spacing: 12) {
                shotCard
                weightCard
                if hasShotOnSelectedDate {
                    sideEffectsCard
                    notesCard
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }

    private var shotCard: some View {
        Button {
            if hasShotOnSelectedDate {
                activeSheet = .editShot(selectedDate)
            } else if !isSelectedDateInFuture {
                activeSheet = .addShot(selectedDate)
            }
        } label: {
            CalendarHealthCard(
                title: "Injection",
                color: .red,
                showChevron: hasShotOnSelectedDate || !isSelectedDateInFuture
            ) {
                if hasShotOnSelectedDate {
                    shotDetailsContent
                } else if isSelectedDateInFuture {
                    futureDateContent
                } else {
                    addShotContent
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isSelectedDateInFuture && !hasShotOnSelectedDate)
    }

    private var shotDetailsContent: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tirzepatide")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("15mg")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Shot #15")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Stomach - Lower Left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var futureDateContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Future Date")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("--")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
        }
    }

    private var addShotContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("No injection logged")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Add")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
            }
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.red)
        }
    }

    private var weightCard: some View {
        Button {
            // Weight entry action
        } label: {
            CalendarHealthCard(
                title: "Weight",
                color: .orange,
                showChevron: true
            ) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recorded")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("230")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                            Text("lb")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    WeightDayIndicator()
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var sideEffectsCard: some View {
        Button {
            activeSheet = .sideEffects(selectedDate)
        } label: {
            CalendarHealthCard(
                title: "Side Effects",
                color: .teal,
                showChevron: true
            ) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reported")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(sampleSideEffects.joined(separator: ", "))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    Spacer()
                    SideEffectIndicator(count: sampleSideEffects.count)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var notesCard: some View {
        Button {
            activeSheet = .notes(selectedDate)
        } label: {
            CalendarHealthCard(
                title: "Notes",
                color: .yellow,
                showChevron: true
            ) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Added")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\"Felt mild nausea...\"")
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 32))
                        .foregroundStyle(.yellow.opacity(0.6))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Calendar Health Card

private struct CalendarHealthCard<Content: View>: View {
    let title: String
    let color: Color
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
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
            }

            // Content
            content
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

// MARK: - Visual Indicators

private struct WeightDayIndicator: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == 4 ? Color.orange : Color.orange.opacity(0.3))
                    .frame(width: 6, height: CGFloat([20, 25, 22, 28, 30][index]))
            }
        }
        .frame(height: 35)
    }
}

private struct SideEffectIndicator: View {
    let count: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.teal.opacity(0.3), lineWidth: 4)
                .frame(width: 40, height: 40)

            Circle()
                .trim(from: 0, to: min(Double(count) / 10.0, 1.0))
                .stroke(Color.teal, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))

            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.teal)
        }
    }
}

// MARK: - Calendar Grid View (UICalendarView Wrapper)

struct CalendarGridView: UIViewRepresentable {
    @Binding var selectedDate: Date
    let shotDates: Set<DateComponents>

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.delegate = context.coordinator
        calendarView.calendar = Calendar.current
        calendarView.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture)
        calendarView.fontDesign = .rounded

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: selectedDate
        )
        calendarView.selectionBehavior = selection

        DispatchQueue.main.async {
            calendarView.reloadDecorations(forDateComponents: Array(self.shotDates), animated: false)
        }

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.shotDates = shotDates
        uiView.reloadDecorations(forDateComponents: Array(shotDates), animated: true)

        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let currentComponents = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: selectedDate
            )
            if selection.selectedDate != currentComponents {
                selection.selectedDate = currentComponents
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarGridView
        var shotDates: Set<DateComponents>

        init(_ parent: CalendarGridView) {
            self.parent = parent
            self.shotDates = parent.shotDates
        }

        func calendarView(
            _: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            let normalizedComponents = DateComponents(
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day
            )

            if shotDates.contains(normalizedComponents) {
                return .default(color: .systemRed, size: .large)
            }

            return nil
        }

        func dateSelection(
            _: UICalendarSelectionSingleDate,
            didSelectDate dateComponents: DateComponents?
        ) {
            guard let dateComponents,
                  let date = Calendar.current.date(from: dateComponents)
            else {
                return
            }
            DispatchQueue.main.async {
                self.parent.selectedDate = date
            }
        }

        func dateSelection(
            _: UICalendarSelectionSingleDate,
            canSelectDate _: DateComponents?
        ) -> Bool {
            true
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
}
