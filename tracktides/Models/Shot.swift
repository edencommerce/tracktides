import Foundation

struct Shot: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let medication: String
    let dosage: String
    let injectionSite: String
    let painLevel: Int
    let notes: String

    init(
        id: UUID = UUID(),
        date: Date,
        medication: String,
        dosage: String,
        injectionSite: String = "",
        painLevel: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.medication = medication
        self.dosage = dosage
        self.injectionSite = injectionSite
        self.painLevel = painLevel
        self.notes = notes
    }
}

struct DayEntry: Identifiable {
    let id: UUID
    let date: Date
    var shot: Shot?
    var weight: Double?
    var calories: Int?
    var protein: Int?
    var sideEffects: [String]
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date,
        shot: Shot? = nil,
        weight: Double? = nil,
        calories: Int? = nil,
        protein: Int? = nil,
        sideEffects: [String] = [],
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.shot = shot
        self.weight = weight
        self.calories = calories
        self.protein = protein
        self.sideEffects = sideEffects
        self.notes = notes
    }
}
