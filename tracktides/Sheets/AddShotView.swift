import SwiftUI

struct AddShotView: View {
    @Environment(\.dismiss) private var dismiss: DismissAction

    // MARK: - State

    @State private var selectedDate: Date = .init()
    @State private var timeTaken: Date = .init()
    @State private var medicationName: String = "Tirzepatide"
    @State private var dosageStrength: String = "15mg"
    @State private var customDosage: String = ""
    @State private var injectionSite: String = "Stomach - Lower Left"
    @State private var painLevel: Double = 0
    @State private var notes: String = ""

    private let medications: [String] = ["Tirzepatide", "Semaglutide", "Retatrutide", "BPC-157", "Other"]
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                dateSection
                timeSection
                detailsSection
                notesSection
            }
            .navigationTitle("Add Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save action
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedDate) {
                // Clamp time if switching to today and time is in the future
                if Calendar.current.isDateInToday(selectedDate), timeTaken > Date() {
                    timeTaken = Date()
                }
            }
        }
    }
}

// MARK: - Sections

private extension AddShotView {
    var dateSection: some View {
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

    var timeSection: some View {
        Section("Time") {
            DatePicker(
                "Time Taken",
                selection: $timeTaken,
                in: ...maxAllowedTime,
                displayedComponents: .hourAndMinute
            )
        }
    }

    var maxAllowedTime: Date {
        if Calendar.current.isDateInToday(selectedDate) {
            Date()
        } else {
            // For past dates, allow any time (end of that day)
            Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? Date()
        }
    }

    var detailsSection: some View {
        Section("Details") {
            Picker("Medication Name", selection: $medicationName) {
                ForEach(medications, id: \.self) { medication in
                    Text(medication).tag(medication)
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

    var notesSection: some View {
        Section("Shot Notes") {
            TextField("Add notes", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}

#Preview {
    AddShotView()
}
