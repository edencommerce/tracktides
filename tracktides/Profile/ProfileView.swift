import MessageUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(\.openURL) private var openURL

    // swiftlint:disable:next force_unwrapping
    private let termsURL: URL = .init(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    // swiftlint:disable:next force_unwrapping
    private let privacyURL: URL = .init(string: "https://www.tryeden.ai/privacy")!

    @State private var showingMailComposer: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                accountSection
                preferencesSection
                supportSection
                logoutSection
                versionSection
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMailComposer) {
                MailComposeView()
            }
        }
    }

    // MARK: - Sections

    private var accountSection: some View {
        Section("Account") {
            NavigationLink {
                PersonalDetailsView()
            } label: {
                Label("Personal Details", systemImage: "person.text.rectangle")
            }

            NavigationLink {
                NotificationsView()
            } label: {
                LabeledContent {
                    Text("Enabled")
                } label: {
                    Label("Notifications", systemImage: "bell.badge")
                }
            }

            NavigationLink {
                UnitsView()
            } label: {
                LabeledContent {
                    Text("Metric")
                } label: {
                    Label("Units", systemImage: "globe")
                }
            }

            NavigationLink {
                ManageDataView()
            } label: {
                Label("Manage My Data", systemImage: "arrow.up.doc")
            }
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            NavigationLink {
                MedicationsView()
            } label: {
                Label("Medications", systemImage: "pills")
            }

            NavigationLink {
                AppearanceView()
            } label: {
                Label("Customization", systemImage: "paintbrush")
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Button {
                if MFMailComposeViewController.canSendMail() {
                    showingMailComposer = true
                }
            } label: {
                HStack {
                    Label("Support Email", systemImage: "envelope")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .disabled(!MFMailComposeViewController.canSendMail())

            Button {
                openURL(termsURL)
            } label: {
                HStack {
                    Label("Terms and Conditions", systemImage: "doc.text")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                openURL(privacyURL)
            } label: {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                // Rate app action
            } label: {
                Label("Rate App", systemImage: "star")
            }

            NavigationLink {
                AboutView()
            } label: {
                Label("About", systemImage: "info.circle")
            }
        }
    }

    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                // Logout action
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }

            Button(role: .destructive) {
                // Delete account action
            } label: {
                Label("Delete Account", systemImage: "person.fill.xmark")
            }
        }
    }

    private var versionSection: some View {
        Section {
            Text("Peptides v1.0.0")
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .listRowBackground(Color.clear)
    }
}

// MARK: - Mail Compose View

struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@tryeden.ai"])
        composer.setSubject("Support Request")

        // Get device info
        let device = UIDevice.current
        let deviceModel: String = device.model
        let iOSVersion: String = device.systemVersion
        let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let userId: String = device.identifierForVendor?.uuidString ?? "Unknown"
        let userIdBase64: String = Data(userId.utf8).base64EncodedString()

        let body = """

        Please describe your issue above this line.
        ----------------------------------------
        User ID: \(userId)
        Email: (your email)
        Version: \(appVersion)
        Provider Id: \(userIdBase64)
        Platform: iOS
        iOS Version: \(iOSVersion)
        Device: \(deviceModel)
        """

        composer.setMessageBody(body, isHTML: false)
        return composer
    }

    func updateUIViewController(_: MFMailComposeViewController, context _: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    @MainActor
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        nonisolated func mailComposeController(
            _: MFMailComposeViewController,
            didFinishWith _: MFMailComposeResult,
            error _: Error?
        ) {
            Task { @MainActor in
                dismiss()
            }
        }
    }
}

#Preview {
    ProfileView()
}
