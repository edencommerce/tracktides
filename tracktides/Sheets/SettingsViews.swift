import SwiftUI

// MARK: - Personal Details View

struct PersonalDetailsView: View {
    var body: some View {
        Form {
            Section("Name") {
                Text("Not set").foregroundStyle(.secondary)
            }
            Section("Default Settings") {
                LabeledContent("Morning dose", value: "8:00 AM")
            }
        }
        .navigationTitle("Personal Details")
    }
}

// MARK: - Appearance View

struct AppearanceView: View {
    @AppStorage("appAppearance") private var appearance: Int = 0

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Appearance")
    }
}

// MARK: - Notifications View

struct NotificationsView: View {
    @State private var doseReminders: Bool = true
    @State private var refillAlerts: Bool = true
    @State private var trackingReminders: Bool = false

    var body: some View {
        Form {
            Section("Reminders") {
                Toggle("Dose Reminders", isOn: $doseReminders)
                Toggle("Refill Alerts", isOn: $refillAlerts)
                Toggle("Daily Tracking Reminder", isOn: $trackingReminders)
            }
            Section("Frequency") {
                Text("15 minutes before dose")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Notifications")
    }
}

// MARK: - Units View

struct UnitsView: View {
    @State private var unitSystem: Int = 0
    @State private var volumeUnit: Int = 0

    var body: some View {
        Form {
            Section("Measurement System") {
                Picker("System", selection: $unitSystem) {
                    Text("Metric").tag(0)
                    Text("Imperial").tag(1)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("Volume") {
                Picker("Volume Unit", selection: $volumeUnit) {
                    Text("mL").tag(0)
                    Text("IU").tag(1)
                    Text("mg").tag(2)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Units")
    }
}

// MARK: - Display Settings View

struct DisplaySettingsView: View {
    @State private var showGraph: Bool = true
    @State private var showCalendar: Bool = true
    @State private var compactMode: Bool = false

    var body: some View {
        Form {
            Section("Home Screen") {
                Toggle("Show Progress Graph", isOn: $showGraph)
                Toggle("Show Calendar View", isOn: $showCalendar)
                Toggle("Compact Mode", isOn: $compactMode)
            }
        }
        .navigationTitle("Display Settings")
    }
}

// MARK: - Support View

struct SupportView: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("Email", value: "support@peptides.app")
            }
            Section("FAQ") {
                Text("How do I add a new peptide?")
                Text("How do I set dose reminders?")
                Text("How do I track my progress?")
            }
        }
        .navigationTitle("Support")
    }
}

// MARK: - Previews

#Preview("Personal Details") {
    NavigationStack {
        PersonalDetailsView()
    }
}

#Preview("Appearance") {
    NavigationStack {
        AppearanceView()
    }
}

#Preview("Notifications") {
    NavigationStack {
        NotificationsView()
    }
}
