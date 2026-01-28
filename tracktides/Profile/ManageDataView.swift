import PDFKit
import SwiftUI
import UIKit

// MARK: - Export Format

enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf = "PDF"
    case csv = "CSV"
    case json = "JSON"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .pdf: "doc.richtext"
        case .csv: "tablecells"
        case .json: "curlybraces"
        }
    }

    var fileExtension: String {
        rawValue.lowercased()
    }

    var mimeType: String {
        switch self {
        case .pdf: "application/pdf"
        case .csv: "text/csv"
        case .json: "application/json"
        }
    }
}

// MARK: - Exportable Data

struct ExportableData: Codable {
    let exportDate: Date
    let appVersion: String
    let profile: ProfileData?
    let medications: [MedicationExport]
    let entries: [DayEntryExport]

    struct ProfileData: Codable {
        let name: String
        let heightFeet: Int
        let heightInches: Int
        let goalWeight: Double?
        let startDate: Date
    }

    struct MedicationExport: Codable {
        let id: String
        let name: String
        let category: String
        let isFDAApproved: Bool
    }

    struct DayEntryExport: Codable {
        let date: Date
        let medication: String?
        let dosage: String?
        let injectionSite: String?
        let painLevel: Int?
        let weight: Double?
        let calories: Int?
        let protein: Int?
        let sideEffects: [String]
        let notes: String
    }
}

// MARK: - Data Exporter

@MainActor
final class DataExporter {
    private let medicationPreferences: MedicationPreferences
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(medicationPreferences: MedicationPreferences) {
        self.medicationPreferences = medicationPreferences
    }

    func export(format: ExportFormat) -> Data? {
        let exportData = gatherExportData()

        switch format {
        case .json:
            return exportJSON(data: exportData)
        case .csv:
            return exportCSV(data: exportData)
        case .pdf:
            return exportPDF(data: exportData)
        }
    }

    func fileName(for format: ExportFormat) -> String {
        let date = dateFormatter.string(from: Date())
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: " ", with: "_")
        return "tracktides_export_\(date).\(format.fileExtension)"
    }

    private func gatherExportData() -> ExportableData {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

        // Gather enabled medications
        let medications = medicationPreferences.enabledMedications.map { med in
            ExportableData.MedicationExport(
                id: med.id,
                name: med.name,
                category: med.category.rawValue,
                isFDAApproved: med.isFDAApproved
            )
        }

        // Note: Will use actual persisted data when data layer is implemented
        let entries: [ExportableData.DayEntryExport] = sampleEntries()

        // Note: Will use actual persisted profile when data layer is implemented
        let profile = ExportableData.ProfileData(
            name: UserDefaults.standard.string(forKey: "userName") ?? "",
            heightFeet: UserDefaults.standard.integer(forKey: "heightFeet"),
            heightInches: UserDefaults.standard.integer(forKey: "heightInches"),
            goalWeight: UserDefaults.standard.double(forKey: "goalWeight"),
            startDate: Date(
                timeIntervalSince1970: UserDefaults.standard.double(forKey: "startDate")
            )
        )

        return ExportableData(
            exportDate: Date(),
            appVersion: appVersion,
            profile: profile,
            medications: medications,
            entries: entries
        )
    }

    private func sampleEntries() -> [ExportableData.DayEntryExport] {
        // Sample data for demonstration - will be replaced with actual data
        []
    }

    // MARK: - JSON Export

    private func exportJSON(data: ExportableData) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(data)
    }

    // MARK: - CSV Export

    private func exportCSV(data: ExportableData) -> Data? {
        var csv = "Tracktides Data Export\n"
        csv += "Export Date,\(dateFormatter.string(from: data.exportDate))\n"
        csv += "App Version,\(data.appVersion)\n\n"

        // Profile section
        csv += "PROFILE\n"
        if let profile = data.profile {
            csv += "Name,\(escapeCSV(profile.name))\n"
            csv += "Height,\(profile.heightFeet) ft \(profile.heightInches) in\n"
            if let goalWeight = profile.goalWeight, goalWeight > 0 {
                csv += "Goal Weight,\(goalWeight) lb\n"
            }
            csv += "Start Date,\(dateFormatter.string(from: profile.startDate))\n"
        }
        csv += "\n"

        // Medications section
        csv += "ENABLED MEDICATIONS\n"
        csv += "Name,Category,FDA Approved\n"
        for med in data.medications {
            csv += "\(escapeCSV(med.name)),\(escapeCSV(med.category)),\(med.isFDAApproved ? "Yes" : "No")\n"
        }
        csv += "\n"

        // Entries section
        if !data.entries.isEmpty {
            csv += "TRACKING HISTORY\n"
            csv += "Date,Medication,Dosage,Injection Site,Pain Level,Weight,Calories,Protein,Side Effects,Notes\n"
            let entryDateFormatter = DateFormatter()
            entryDateFormatter.dateStyle = .short
            for entry in data.entries {
                let dateStr = entryDateFormatter.string(from: entry.date)
                let medStr = entry.medication ?? ""
                let dosageStr = entry.dosage ?? ""
                let siteStr = entry.injectionSite ?? ""
                let painStr = entry.painLevel.map { String($0) } ?? ""
                let weightStr = entry.weight.map { String($0) } ?? ""
                let calStr = entry.calories.map { String($0) } ?? ""
                let proteinStr = entry.protein.map { String($0) } ?? ""
                let effectsStr = entry.sideEffects.joined(separator: "; ")
                csv += """
                \(dateStr),\(escapeCSV(medStr)),\(escapeCSV(dosageStr)),\
                \(escapeCSV(siteStr)),\(painStr),\(weightStr),\(calStr),\
                \(proteinStr),\(escapeCSV(effectsStr)),\(escapeCSV(entry.notes))\n
                """
            }
        }

        return csv.data(using: .utf8)
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    // MARK: - PDF Export

    private func exportPDF(data: ExportableData) -> Data? {
        let config = PDFConfiguration()
        let renderer = createPDFRenderer(config: config)

        return renderer.pdfData { context in
            context.beginPage()
            var yPosition = config.margin

            yPosition = drawPDFHeader(data: data, at: yPosition, config: config)
            yPosition = drawPDFProfile(data: data, at: yPosition, config: config, context: context)
            yPosition = drawPDFMedications(data: data, at: yPosition, config: config, context: context)
            _ = drawPDFEntries(data: data, at: yPosition, config: config, context: context)
            drawPDFFooter(config: config)
        }
    }

    private func createPDFRenderer(config: PDFConfiguration) -> UIGraphicsPDFRenderer {
        let pdfMetaData = [
            kCGPDFContextCreator: "Tracktides",
            kCGPDFContextAuthor: "Tracktides App",
            kCGPDFContextTitle: "Health Data Export"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        return UIGraphicsPDFRenderer(bounds: config.pageRect, format: format)
    }

    private func drawPDFHeader(data: ExportableData, at yPosition: CGFloat, config: PDFConfiguration) -> CGFloat {
        var currentY = yPosition

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 24)]
        "Tracktides Health Data".draw(at: CGPoint(x: config.margin, y: currentY), withAttributes: titleAttributes)
        currentY += 35

        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let exportInfo = "Exported on \(dateFormatter.string(from: data.exportDate)) • Version \(data.appVersion)"
        exportInfo.draw(at: CGPoint(x: config.margin, y: currentY), withAttributes: infoAttributes)
        currentY += 40

        return currentY
    }

    private func drawPDFProfile(
        data: ExportableData,
        at yPosition: CGFloat,
        config: PDFConfiguration,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var currentY = drawSectionHeader(title: "Profile", at: yPosition, config: config, context: context)

        guard let profile = data.profile else { return currentY + 20 }

        if !profile.name.isEmpty {
            "Name: \(profile.name)".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            currentY += 18
        }
        "Height: \(profile.heightFeet) ft \(profile.heightInches) in".draw(
            at: CGPoint(x: config.margin, y: currentY),
            withAttributes: config.bodyAttributes
        )
        currentY += 18
        if let goalWeight = profile.goalWeight, goalWeight > 0 {
            "Goal Weight: \(Int(goalWeight)) lb".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            currentY += 18
        }
        return currentY + 20
    }

    private func drawPDFMedications(
        data: ExportableData,
        at yPosition: CGFloat,
        config: PDFConfiguration,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var currentY = drawSectionHeader(title: "Enabled Medications", at: yPosition, config: config, context: context)

        if data.medications.isEmpty {
            "No medications enabled".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            return currentY + 38
        }

        for med in data.medications {
            if currentY > config.pageHeight - config.margin - 50 {
                context.beginPage()
                currentY = config.margin
            }
            let fdaIndicator = med.isFDAApproved ? " ✓ FDA" : ""
            "• \(med.name) (\(med.category))\(fdaIndicator)".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            currentY += 18
        }
        return currentY + 20
    }

    private func drawPDFEntries(
        data: ExportableData,
        at yPosition: CGFloat,
        config: PDFConfiguration,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        guard !data.entries.isEmpty else { return yPosition }

        var currentY = drawSectionHeader(title: "Tracking History", at: yPosition, config: config, context: context)
        let entryDateFormatter = DateFormatter()
        entryDateFormatter.dateStyle = .short

        for entry in data.entries {
            if currentY > config.pageHeight - config.margin - 80 {
                context.beginPage()
                currentY = config.margin
            }
            currentY = drawPDFEntry(entry: entry, at: currentY, config: config, dateFormatter: entryDateFormatter)
        }
        return currentY
    }

    private func drawPDFEntry(
        entry: ExportableData.DayEntryExport,
        at yPosition: CGFloat,
        config: PDFConfiguration,
        dateFormatter: DateFormatter
    ) -> CGFloat {
        var currentY = yPosition
        var entryText = dateFormatter.string(from: entry.date)

        if let med = entry.medication {
            entryText += " - \(med)"
            if let dosage = entry.dosage { entryText += " (\(dosage))" }
        }
        entryText.draw(at: CGPoint(x: config.margin, y: currentY), withAttributes: config.bodyAttributes)
        currentY += 16

        if let weight = entry.weight {
            "  Weight: \(weight) lb".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            currentY += 16
        }
        if !entry.notes.isEmpty {
            "  Notes: \(entry.notes)".draw(
                at: CGPoint(x: config.margin, y: currentY),
                withAttributes: config.bodyAttributes
            )
            currentY += 16
        }
        return currentY + 8
    }

    private func drawPDFFooter(config: PDFConfiguration) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.lightGray
        ]
        "Generated by Tracktides • Your data stays private".draw(
            at: CGPoint(x: config.margin, y: config.pageHeight - config.margin),
            withAttributes: footerAttributes
        )
    }

    private func drawSectionHeader(
        title: String,
        at yPosition: CGFloat,
        config: PDFConfiguration,
        context _: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var currentY = yPosition

        let sectionAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 14)]
        title.draw(at: CGPoint(x: config.margin, y: currentY), withAttributes: sectionAttributes)
        currentY += 20

        let path = UIBezierPath()
        path.move(to: CGPoint(x: config.margin, y: currentY))
        path.addLine(to: CGPoint(x: config.pageWidth - config.margin, y: currentY))
        UIColor.lightGray.setStroke()
        path.lineWidth = 0.5
        path.stroke()
        currentY += 10

        return currentY
    }
}

// MARK: - PDF Configuration

private struct PDFConfiguration {
    let pageWidth: CGFloat = 612
    let pageHeight: CGFloat = 792
    let margin: CGFloat = 50

    var pageRect: CGRect {
        CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    }

    var bodyAttributes: [NSAttributedString.Key: Any] {
        [.font: UIFont.systemFont(ofSize: 11)]
    }
}

// MARK: - Manage Data View

struct ManageDataView: View {
    @State private var exportingFormat: ExportFormat?
    @State private var exportedFileURL: URL?
    @State private var showShareSheet: Bool = false
    @State private var showExportError: Bool = false

    @State private var medicationPreferences = MedicationPreferences()

    var body: some View {
        Form {
            Section {
                Text("""
                Export your health data to keep a personal backup or share with your healthcare provider. \
                All exports are generated locally on your device.
                """)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Section {
                ForEach(ExportFormat.allCases) { format in
                    Button {
                        exportData(format: format)
                    } label: {
                        HStack {
                            Label(format.rawValue, systemImage: format.icon)
                            Spacer()
                            if exportingFormat == format {
                                ProgressView()
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(exportingFormat != nil)
                }
            } header: {
                Text("Export As")
            } footer: {
                Text("""
                PDF is best for sharing with healthcare providers. \
                CSV works with spreadsheet apps. JSON is for data backups.
                """)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's included:")
                        .font(.subheadline.weight(.medium))

                    Group {
                        Label("Profile information", systemImage: "person")
                        Label("Enabled medications", systemImage: "pills")
                        Label("Tracking history", systemImage: "calendar")
                        Label("Side effects & notes", systemImage: "note.text")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Data Included")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Privacy Note", systemImage: "lock.shield")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("""
                    Your data is processed entirely on your device. \
                    Nothing is uploaded to any server during export.
                    """)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Manage My Data")
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        .alert("Export Failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to generate export file. Please try again.")
        }
    }

    private func exportData(format: ExportFormat) {
        exportingFormat = format

        Task {
            let exporter = DataExporter(medicationPreferences: medicationPreferences)

            guard let data = exporter.export(format: format) else {
                exportingFormat = nil
                showExportError = true
                return
            }

            let fileName = exporter.fileName(for: format)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                try data.write(to: tempURL)
                exportedFileURL = tempURL
                exportingFormat = nil
                showShareSheet = true
            } catch {
                exportingFormat = nil
                showExportError = true
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) { }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ManageDataView()
    }
}
