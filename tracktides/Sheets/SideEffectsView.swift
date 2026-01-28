import SwiftUI

struct SideEffectsView: View {
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let existingSideEffects: Set<String>
    let existingSeverities: [String: Int]
    let existingNotes: String

    private let commonSideEffects: [SideEffectCategory] = [
        SideEffectCategory(name: "Gastrointestinal", effects: [
            "Nausea",
            "Vomiting",
            "Diarrhea",
            "Constipation",
            "Abdominal pain",
            "Acid reflux",
            "Loss of appetite",
            "Bloating"
        ]),
        SideEffectCategory(name: "General", effects: [
            "Fatigue",
            "Headache",
            "Dizziness",
            "Injection site reaction",
            "Injection site pain",
            "Muscle aches"
        ]),
        SideEffectCategory(name: "Other", effects: [
            "Hair loss",
            "Mood changes",
            "Difficulty sleeping",
            "Brain fog"
        ])
    ]

    @State private var selectedSideEffects: Set<String>
    @State private var severities: [String: Int]
    @State private var notes: String

    private var dateHeaderText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, \(date.formatted(.dateTime.month().day()))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, \(date.formatted(.dateTime.month().day()))"
        } else {
            return date.formatted(.dateTime.weekday(.wide).month().day())
        }
    }

    private var isEditing: Bool {
        !existingSideEffects.isEmpty
    }

    init(
        date: Date,
        existingSideEffects: Set<String> = [],
        existingSeverities: [String: Int] = [:],
        existingNotes: String = ""
    ) {
        self.date = date
        self.existingSideEffects = existingSideEffects
        self.existingSeverities = existingSeverities
        self.existingNotes = existingNotes
        _selectedSideEffects = State(initialValue: existingSideEffects)
        _severities = State(initialValue: existingSeverities)
        _notes = State(initialValue: existingNotes)
    }

    var body: some View {
        NavigationStack {
            Form {
                headerSection
                sideEffectsSection
                if !selectedSideEffects.isEmpty {
                    severitySection
                }
                notesSection
            }
            .navigationTitle(isEditing ? "Edit Side Effects" : "Add Side Effects")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSideEffects()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(dateHeaderText)
            }
        }
    }

    private var sideEffectsSection: some View {
        ForEach(commonSideEffects) { category in
            Section(category.name) {
                ForEach(category.effects, id: \.self) { effect in
                    Button {
                        toggleSideEffect(effect)
                    } label: {
                        HStack {
                            Text(effect)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedSideEffects.contains(effect) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.teal)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }

    private var severitySection: some View {
        Section("Severity") {
            ForEach(Array(selectedSideEffects).sorted(), id: \.self) { effect in
                HStack {
                    Text(effect)
                    Spacer()
                    Picker("", selection: severityBinding(for: effect)) {
                        Text("Mild").tag(1)
                        Text("Moderate").tag(2)
                        Text("Severe").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
    }

    private var notesSection: some View {
        Section("Additional Notes") {
            TextField("Describe your symptoms...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Helpers

    private func toggleSideEffect(_ effect: String) {
        if selectedSideEffects.contains(effect) {
            selectedSideEffects.remove(effect)
            severities.removeValue(forKey: effect)
        } else {
            selectedSideEffects.insert(effect)
            severities[effect] = 1 // Default to mild
        }
    }

    private func severityBinding(for effect: String) -> Binding<Int> {
        Binding(
            get: { severities[effect] ?? 1 },
            set: { severities[effect] = $0 }
        )
    }

    private func saveSideEffects() {
        // Save side effects to data store when implemented
    }
}

// MARK: - Supporting Types

private struct SideEffectCategory: Identifiable {
    let id: String
    let name: String
    let effects: [String]

    init(name: String, effects: [String]) {
        self.id = name
        self.name = name
        self.effects = effects
    }
}

// MARK: - Preview

#Preview {
    SideEffectsView(date: Date())
}
