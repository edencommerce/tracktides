import SwiftUI

struct MedicationsView: View {
    @State private var preferences = MedicationPreferences()
    @State private var showingAddCustom = false

    private var fdaDisclaimer: String {
        """
        Only Tirzepatide (Mounjaro/Zepbound) and Semaglutide (Ozempic/Wegovy) are \
        FDA-approved for weight management. Other peptides are for research or off-label use.
        """
    }

    var body: some View {
        List {
            // Built-in categories
            ForEach(MedicationCategory.allCases) { category in
                Section {
                    categoryContent(for: category)
                } header: {
                    categoryHeader(for: category)
                } footer: {
                    categoryFooter(for: category)
                }
            }

            // Custom medications section
            customMedicationsSection

            disclaimerSection
        }
        .navigationTitle("Medications")
        .sheet(isPresented: $showingAddCustom) {
            AddCustomMedicationView { medication in
                preferences.addCustomMedication(medication)
            }
        }
    }

    // MARK: - Sections

    private var customMedicationsSection: some View {
        Section {
            ForEach(preferences.customMedications) { medication in
                MedicationToggleRow(
                    medication: medication,
                    isEnabled: preferences.isEnabled(medication),
                    isCustom: true
                ) { enabled in
                    preferences.setEnabled(enabled, for: medication)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let medication = preferences.customMedications[index]
                    preferences.deleteCustomMedication(medication)
                }
            }

            Button {
                showingAddCustom = true
            } label: {
                Label("Add Custom Medication", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Custom")
        } footer: {
            if preferences.customMedications.isEmpty {
                Text("Add your own medications not listed above.")
            } else {
                Text("Your custom medications. Swipe to delete.")
            }
        }
    }

    private var disclaimerSection: some View {
        Section {
            Text(fdaDisclaimer)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Helpers

    private func categoryHeader(for category: MedicationCategory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category.rawValue)
        }
    }

    private func categoryFooter(for category: MedicationCategory) -> some View {
        Text(category.description)
    }

    @ViewBuilder
    private func categoryContent(for category: MedicationCategory) -> some View {
        let medications = MedicationDatabase.medications(for: category)
        ForEach(medications) { medication in
            MedicationToggleRow(
                medication: medication,
                isEnabled: preferences.isEnabled(medication),
                isCustom: false
            ) { enabled in
                preferences.setEnabled(enabled, for: medication)
            }
        }
    }
}

// MARK: - Medication Toggle Row

private struct MedicationToggleRow: View {
    let medication: Medication
    let isEnabled: Bool
    var isCustom: Bool = false
    let onToggle: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(
            get: { isEnabled },
            set: { onToggle($0) }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(medication.name)
                        .fontWeight(.medium)

                    if medication.isFDAApproved {
                        Text("FDA")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }

                    if isCustom {
                        Text("Custom")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }

                if !medication.brandNames.isEmpty {
                    Text(medication.brandNames.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(.accentColor)
    }
}

// MARK: - Add Custom Medication View

struct AddCustomMedicationView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Medication) -> Void

    @State private var name = ""
    @State private var brandNames = ""
    @State private var genericName = ""
    @State private var selectedCategory: MedicationCategory = .research
    @State private var description = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Medication Name", text: $name)

                    TextField("Brand Names (comma separated)", text: $brandNames)

                    TextField("Generic Name (optional)", text: $genericName)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(MedicationCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let brandNamesList = brandNames
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }

                        let medication = Medication.custom(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            brandNames: brandNamesList,
                            genericName: genericName.trimmingCharacters(in: .whitespacesAndNewlines),
                            category: selectedCategory,
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onSave(medication)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Medication Detail View

struct MedicationDetailView: View {
    let medication: Medication

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Name", value: medication.name)

                if !medication.genericName.isEmpty {
                    LabeledContent("Generic Name", value: medication.genericName)
                }

                if !medication.brandNames.isEmpty {
                    LabeledContent("Brand Names", value: medication.brandNames.joined(separator: ", "))
                }

                LabeledContent("Category", value: medication.category.rawValue)

                LabeledContent("FDA Status") {
                    if medication.isFDAApproved {
                        Label("Approved", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    } else {
                        Text("Not FDA Approved")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Description") {
                Text(medication.description)
            }
        }
        .navigationTitle(medication.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Medications") {
    NavigationStack {
        MedicationsView()
    }
}

#Preview("Medication Detail") {
    NavigationStack {
        MedicationDetailView(medication: MedicationDatabase.tirzepatide)
    }
}
