import SwiftUI

struct NotesView: View {
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let existingNotes: String

    private var quickNotes: [String] {
        [
            "Feeling good today",
            "More energy than usual",
            "Less appetite",
            "Stayed hydrated",
            "Ate smaller portions",
            "Skipped snacking",
            "Good sleep last night",
            "Light exercise"
        ]
    }

    @State private var notes: String
    @FocusState private var isTextFieldFocused: Bool

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
        !existingNotes.isEmpty
    }

    init(date: Date, existingNotes: String = "") {
        self.date = date
        self.existingNotes = existingNotes
        _notes = State(initialValue: existingNotes)
    }

    var body: some View {
        NavigationStack {
            Form {
                headerSection
                notesSection
                suggestionsSection
            }
            .navigationTitle(isEditing ? "Edit Notes" : "Add Notes")
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
            .onAppear {
                isTextFieldFocused = true
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

    private var notesSection: some View {
        Section("Notes") {
            TextField("Write your notes here...", text: $notes, axis: .vertical)
                .lineLimit(5...15)
                .focused($isTextFieldFocused)
        }
    }

    private var suggestionsSection: some View {
        Section("Quick Add") {
            ForEach(quickNotes, id: \.self) { note in
                Button {
                    appendNote(note)
                } label: {
                    HStack {
                        Text(note)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func appendNote(_ note: String) {
        if notes.isEmpty {
            notes = note
        } else {
            notes += "\n\(note)"
        }
    }
}

// MARK: - Preview

#Preview {
    NotesView(date: Date())
}
