import Foundation

struct WeekDay: Sendable {
    let shortName: String
    let dayNumber: Int
    let isFuture: Bool
}

func generateWeekDays() -> [WeekDay] {
    let calendar = Calendar.current
    let today = Date()

    guard let startDate: Date = calendar.date(byAdding: .day, value: -5, to: today) else {
        return []
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"

    return (0..<7).compactMap { offset in
        guard let date: Date = calendar.date(byAdding: .day, value: offset, to: startDate) else {
            return nil
        }

        let dayNumber: Int = calendar.component(.day, from: date)
        let shortName: String = formatter.string(from: date)
        let isFuture: Bool = date > today

        return WeekDay(shortName: shortName, dayNumber: dayNumber, isFuture: isFuture)
    }
}
