import SwiftUI

struct AddShotView: View {
    @Environment(\.dismiss) private var dismiss

    let isEditing: Bool
    let initialDate: Date

    private let dosages: [String] = ["2.5mg", "5mg", "7.5mg", "10mg", "12.5mg", "15mg", "Custom"]
    private let injectionSites: [String] = [
        "Stomach - Upper Left",
        "Stomach - Upper Right",
        "Stomach - Lower Left",
        "Stomach - Lower Right",
        "Thigh - Left",
        "Thigh - Right",
        "Arm - Left",
        "Arm - Right"
    ]
    private let commonSideEffects: [String] = [
        "Nausea",
        "Vomiting",
        "Diarrhea",
        "Constipation",
        "Abdominal pain",
        "Acid reflux",
        "Loss of appetite",
        "Fatigue",
        "Headache",
        "Dizziness",
        "Injection site reaction"
    ]

    @State private var selectedDate: Date
    @State private var timeTaken: Date
    @State private var selectedMedicationID: String
    @State private var dosageStrength: String
    @State private var customDosage: String
    @State private var injectionSite: String
    @State private var painLevel: Double
    @State private var shotNotes: String
    @State private var selectedSideEffects: Set<String>
    @State private var sideEffectSeverities: [String: Int]
    @State private var sideEffectNotes: String
    @State private var showingDeleteConfirmation: Bool = false
    @State private var medicationPreferences = MedicationPreferences()

    private var maxAllowedTime: Date {
        if Calendar.current.isDateInToday(selectedDate) {
            Date()
        } else {
            Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? Date()
        }
    }

    private var enabledMedications: [Medication] {
        medicationPreferences.enabledMedications
    }

    init(isEditing: Bool = false, date: Date = Date()) {
        self.isEditing = isEditing
        self.initialDate = date
        _selectedDate = State(initialValue: date)
        _timeTaken = State(initialValue: date)
        _selectedMedicationID = State(initialValue: MedicationDatabase.tirzepatide.id)
        _dosageStrength = State(initialValue: "15mg")
        _customDosage = State(initialValue: "")
        _injectionSite = State(initialValue: "Stomach - Lower Left")
        _painLevel = State(initialValue: 0)
        _shotNotes = State(initialValue: "")
        _selectedSideEffects = State(initialValue: [])
        _sideEffectSeverities = State(initialValue: [:])
        _sideEffectNotes = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                dateSection
                timeSection
                detailsSection
                sideEffectsSection
                notesSection

                if isEditing {
                    deleteSection
                }
            }
            .navigationTitle(isEditing ? "Edit Shot" : "Add Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedDate) {
                if Calendar.current.isDateInToday(selectedDate), timeTaken > Date() {
                    timeTaken = Date()
                }
            }
            .alert("Delete Shot", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this shot? This action cannot be undone.")
            }
        }
    }

    // MARK: - Sections

    private var dateSection: some View {
        Section("Date") {
            HStack {
                Button {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)

                Spacer()

                ZStack {
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .opacity(Calendar.current.isDateInToday(selectedDate) ? 0.011 : 1)

                    if Calendar.current.isDateInToday(selectedDate) {
                        Text("Today")
                            .fontWeight(.medium)
                            .allowsHitTesting(false)
                    }
                }

                Spacer()

                Button {
                    let tomorrow: Date = Calendar.current
                        .date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    if tomorrow <= Date() {
                        selectedDate = tomorrow
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .disabled(Calendar.current.isDateInToday(selectedDate))
            }
        }
    }

    private var timeSection: some View {
        Section("Time") {
            DatePicker(
                "Time Taken",
                selection: $timeTaken,
                in: ...maxAllowedTime,
                displayedComponents: .hourAndMinute
            )
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            Picker("Medication", selection: $selectedMedicationID) {
                ForEach(enabledMedications) { medication in
                    MedicationPickerLabel(medication: medication)
                        .tag(medication.id)
                }
            }

            Picker("Dosage Strength", selection: $dosageStrength) {
                ForEach(dosages, id: \.self) { dosage in
                    Text(dosage).tag(dosage)
                }
            }

            if dosageStrength == "Custom" {
                HStack {
                    Text("Custom Dosage")
                    Spacer()
                    TextField("e.g. 20", text: $customDosage)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                    Text("mg")
                        .foregroundStyle(.secondary)
                }
            }

            Picker("Injection Site", selection: $injectionSite) {
                ForEach(injectionSites, id: \.self) { site in
                    Text(site).tag(site)
                }
            }

            HStack {
                Text("Pain Level")
                Slider(value: $painLevel, in: 0...10, step: 1)
                Text("\(Int(painLevel))")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var sideEffectsSection: some View {
        Section {
            ForEach(commonSideEffects, id: \.self) { effect in
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

            if !selectedSideEffects.isEmpty {
                TextField("Additional notes about side effects...", text: $sideEffectNotes, axis: .vertical)
                    .lineLimit(2...4)
            }
        } header: {
            Text("Side Effects")
        } footer: {
            Text("Select any side effects you experienced after this shot.")
        }
    }

    private var notesSection: some View {
        Section("Shot Notes") {
            TextField("Add notes", text: $shotNotes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Shot")
                    Spacer()
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleSideEffect(_ effect: String) {
        if selectedSideEffects.contains(effect) {
            selectedSideEffects.remove(effect)
            sideEffectSeverities.removeValue(forKey: effect)
        } else {
            selectedSideEffects.insert(effect)
            sideEffectSeverities[effect] = 1
        }
    }
}

// MARK: - Medication Picker Label

private struct MedicationPickerLabel: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 6) {
            Text(medication.name)

            if !medication.brandNames.isEmpty {
                Text("(\(medication.brandNames.first ?? ""))")
                    .foregroundStyle(.secondary)
            }

            if medication.isFDAApproved {
                Text("FDA")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview("Add Shot") {
    AddShotView()
}

#Preview("Edit Shot") {
    AddShotView(isEditing: true, date: Date())
}
