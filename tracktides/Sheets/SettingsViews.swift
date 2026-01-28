import SwiftUI

// MARK: - Personal Details View

struct PersonalDetailsView: View {
    @State private var name: String = ""
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 10
    @State private var goalWeight: String = ""
    @State private var startDate: Date = .init()

    var body: some View {
        Form {
            Section("Name") {
                TextField("Enter your name", text: $name)
            }

            Section("Height") {
                HStack {
                    Spacer()
                    Picker("Feet", selection: $heightFeet) {
                        ForEach(4...7, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()

                    Picker("Inches", selection: $heightInches) {
                        ForEach(0...11, id: \.self) { inches in
                            Text("\(inches) in").tag(inches)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 100)
                    .clipped()
                    Spacer()
                }
            }

            Section("Goal Weight") {
                HStack {
                    TextField("Enter goal weight", text: $goalWeight)
                        .keyboardType(.decimalPad)
                    Text("lb")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Start Date") {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
            }
        }
        .navigationTitle("Personal Details")
    }
}

// MARK: - Appearance View

struct AppearanceView: View {
    @AppStorage("appAppearance") private var appearance: Int = 0
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled: Bool = true

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

            Section("Feedback") {
                Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
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

// MARK: - About View

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("""
                I built Tracktides because I wanted a simple, private way to track my health journey. \
                After trying dozens of apps that either cost a fortune or wanted all my data, \
                I decided to create something different.

                This app is completely free. No subscriptions, no ads, no catch.
                """)
                .font(.subheadline)
            } header: {
                Text("Why I Made This")
            }

            Section {
                Text("""
                Your data never leaves your device. Everything is stored locally using Apple's \
                secure frameworks. I can't see your information, and neither can anyone else.

                No account required. No cloud sync. No analytics tracking your every move. \
                Just a simple tool that respects your privacy.
                """)
                .font(.subheadline)
            } header: {
                Text("Privacy First")
            }
        }
        .navigationTitle("About")
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

#Preview("About") {
    NavigationStack {
        AboutView()
    }
}
