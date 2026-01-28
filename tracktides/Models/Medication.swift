import Foundation

// MARK: - Medication Category

enum MedicationCategory: String, CaseIterable, Identifiable, Codable {
    case metabolic = "Metabolic"
    case hormone = "Hormone"
    case healingRecovery = "Healing & Recovery"
    case immune = "Immune"
    case stacks = "Stacks"
    case research = "Research"

    var id: String {
        rawValue
    }

    var description: String {
        switch self {
        case .metabolic:
            "GLP-1 agonists and related peptides for weight management and metabolic health."
        case .hormone:
            "Peptides that stimulate natural growth hormone release for body composition and anti-aging."
        case .healingRecovery:
            "Peptides that support tissue repair, wound healing, and recovery from injuries."
        case .immune:
            "Immune-modulating peptides that enhance immune function."
        case .stacks:
            "Pre-formulated peptide combinations designed for specific wellness goals."
        case .research:
            "Experimental and research peptides with emerging applications."
        }
    }
}

// MARK: - Medication

struct Medication: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let brandNames: [String]
    let genericName: String
    let category: MedicationCategory
    let description: String
    let isFDAApproved: Bool
    let isCustom: Bool

    init(
        id: String,
        name: String,
        brandNames: [String],
        genericName: String,
        category: MedicationCategory,
        description: String,
        isFDAApproved: Bool,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.brandNames = brandNames
        self.genericName = genericName
        self.category = category
        self.description = description
        self.isFDAApproved = isFDAApproved
        self.isCustom = isCustom
    }

    var displayName: String {
        name
    }

    var allNames: [String] {
        var names = [name]
        names.append(contentsOf: brandNames)
        if !genericName.isEmpty, genericName != name {
            names.append(genericName)
        }
        return names
    }

    /// Create a custom medication
    static func custom(
        name: String,
        brandNames: [String] = [],
        genericName: String = "",
        category: MedicationCategory,
        description: String = ""
    ) -> Medication {
        Medication(
            id: "custom_\(UUID().uuidString)",
            name: name,
            brandNames: brandNames,
            genericName: genericName,
            category: category,
            description: description,
            isFDAApproved: false,
            isCustom: true
        )
    }
}

// MARK: - Medication Database

enum MedicationDatabase {
    // MARK: - Metabolic Peptides

    static let tirzepatide = Medication(
        id: "tirzepatide",
        name: "Tirzepatide",
        brandNames: ["Mounjaro", "Zepbound"],
        genericName: "Tirzepatide",
        category: .metabolic,
        description: "Dual GIP/GLP-1 receptor agonist for weight loss and diabetes management.",
        isFDAApproved: true
    )

    static let semaglutide = Medication(
        id: "semaglutide",
        name: "Semaglutide",
        brandNames: ["Ozempic", "Wegovy"],
        genericName: "Semaglutide",
        category: .metabolic,
        description: "GLP-1 receptor agonist for weight management and type 2 diabetes.",
        isFDAApproved: true
    )

    static let retatrutide = Medication(
        id: "retatrutide",
        name: "Retatrutide",
        brandNames: [],
        genericName: "LY3437943",
        category: .metabolic,
        description: "Triple agonist targeting GIP, GLP-1, and glucagon receptors.",
        isFDAApproved: false
    )

    static let motsc = Medication(
        id: "motsc",
        name: "MOTS-c",
        brandNames: [],
        genericName: "Mitochondrial ORF of the 12S rRNA-c",
        category: .metabolic,
        description: "Mitochondrial-derived peptide that mimics exercise effects on metabolism.",
        isFDAApproved: false
    )

    // MARK: - Hormone Peptides

    static let cjc1295 = Medication(
        id: "cjc1295",
        name: "CJC-1295",
        brandNames: [],
        genericName: "CJC-1295",
        category: .hormone,
        description: "Growth hormone releasing hormone analog with extended half-life.",
        isFDAApproved: false
    )

    static let ipamorelin = Medication(
        id: "ipamorelin",
        name: "Ipamorelin",
        brandNames: [],
        genericName: "Ipamorelin",
        category: .hormone,
        description: "Selective growth hormone secretagogue with minimal side effects.",
        isFDAApproved: false
    )

    static let mk677 = Medication(
        id: "mk677",
        name: "MK-677",
        brandNames: ["Ibutamoren"],
        genericName: "Ibutamoren",
        category: .hormone,
        description: "Oral growth hormone secretagogue that mimics ghrelin.",
        isFDAApproved: false
    )

    static let tesamorelin = Medication(
        id: "tesamorelin",
        name: "Tesamorelin",
        brandNames: ["Egrifta"],
        genericName: "Tesamorelin Acetate",
        category: .hormone,
        description: "FDA-approved GHRH analog for reducing visceral fat.",
        isFDAApproved: true
    )

    // MARK: - Healing & Recovery Peptides

    static let bpc157 = Medication(
        id: "bpc157",
        name: "BPC-157",
        brandNames: [],
        genericName: "Body Protection Compound-157",
        category: .healingRecovery,
        description: "Gastric pentadecapeptide with remarkable tissue healing properties.",
        isFDAApproved: false
    )

    static let tb500 = Medication(
        id: "tb500",
        name: "TB-500",
        brandNames: [],
        genericName: "Thymosin Beta-4",
        category: .healingRecovery,
        description: "Naturally occurring peptide that promotes tissue repair and reduces inflammation.",
        isFDAApproved: false
    )

    // MARK: - Immune Peptides

    static let thymosinAlpha1 = Medication(
        id: "thymosinAlpha1",
        name: "Thymosin Alpha-1",
        brandNames: ["Zadaxin"],
        genericName: "Thymalfasin",
        category: .immune,
        description: "Immune-modulating peptide that enhances T-cell function and immune response.",
        isFDAApproved: false
    )

    // MARK: - Research Peptides

    static let epithalon = Medication(
        id: "epithalon",
        name: "Epithalon",
        brandNames: ["Epitalon", "Epithalone"],
        genericName: "Epithalon",
        category: .research,
        description: "Telomerase-activating tetrapeptide studied for anti-aging effects.",
        isFDAApproved: false
    )

    static let ghFrag176191 = Medication(
        id: "ghFrag176191",
        name: "GH-Frag 176-191",
        brandNames: [],
        genericName: "HGH Fragment 176-191",
        category: .research,
        description: "Fragment of growth hormone targeting fat metabolism.",
        isFDAApproved: false
    )

    static let pt141 = Medication(
        id: "pt141",
        name: "PT-141",
        brandNames: ["Bremelanotide"],
        genericName: "Bremelanotide",
        category: .research,
        description: "Melanocortin receptor agonist for sexual dysfunction.",
        isFDAApproved: false
    )

    static let selank = Medication(
        id: "selank",
        name: "Selank",
        brandNames: [],
        genericName: "Synthetic Tuftsin Analog",
        category: .research,
        description: "Anxiolytic and nootropic peptide derived from tuftsin.",
        isFDAApproved: false
    )

    static let semax = Medication(
        id: "semax",
        name: "Semax",
        brandNames: [],
        genericName: "ACTH(4-10) Analog",
        category: .research,
        description: "Neuroprotective peptide derived from ACTH with nootropic effects.",
        isFDAApproved: false
    )

    // MARK: - Peptide Stacks

    static let glow = Medication(
        id: "glow",
        name: "GLOW",
        brandNames: [],
        genericName: "GHK-Cu + Epithalon Stack",
        category: .stacks,
        description: "Skin, hair, and anti-aging stack combining copper peptide with telomerase activator.",
        isFDAApproved: false
    )

    static let klow = Medication(
        id: "klow",
        name: "KLOW",
        brandNames: [],
        genericName: "CJC-1295 + Ipamorelin Stack",
        category: .stacks,
        description: "Growth hormone optimization stack for body composition and recovery.",
        isFDAApproved: false
    )

    static let cjcIpaStack = Medication(
        id: "cjcIpaStack",
        name: "CJC/Ipamorelin",
        brandNames: [],
        genericName: "CJC-1295/Ipamorelin Blend",
        category: .stacks,
        description: "Classic GH secretagogue combination for synergistic growth hormone release.",
        isFDAApproved: false
    )

    static let bpcTbStack = Medication(
        id: "bpcTbStack",
        name: "BPC/TB-500",
        brandNames: [],
        genericName: "BPC-157/TB-500 Blend",
        category: .stacks,
        description: "Healing stack combining two powerful tissue repair peptides.",
        isFDAApproved: false
    )

    // MARK: - All Medications

    static let all: [Medication] = [
        // Metabolic
        tirzepatide,
        semaglutide,
        retatrutide,
        motsc,
        // Hormone
        cjc1295,
        ipamorelin,
        mk677,
        tesamorelin,
        // Healing & Recovery
        bpc157,
        tb500,
        // Immune
        thymosinAlpha1,
        // Stacks
        glow,
        klow,
        cjcIpaStack,
        bpcTbStack,
        // Research
        epithalon,
        ghFrag176191,
        pt141,
        selank,
        semax
    ]

    static func medications(for category: MedicationCategory) -> [Medication] {
        all.filter { $0.category == category }
    }

    static func medication(byID id: String) -> Medication? {
        all.first { $0.id == id }
    }
}

// MARK: - User Medication Preferences

@MainActor
@Observable
final class MedicationPreferences {
    private let enabledMedicationsKey = "enabledMedications"
    private let customMedicationsKey = "customMedications"

    var enabledMedicationIDs: Set<String> {
        didSet {
            saveEnabledMedications()
        }
    }

    var customMedications: [Medication] {
        didSet {
            saveCustomMedications()
        }
    }

    init() {
        // Load enabled medications
        if let saved = UserDefaults.standard.array(forKey: enabledMedicationsKey) as? [String] {
            self.enabledMedicationIDs = Set(saved)
        } else {
            // Default to FDA-approved medications
            self.enabledMedicationIDs = Set(
                MedicationDatabase.all
                    .filter(\.isFDAApproved)
                    .map(\.id)
            )
        }

        // Load custom medications
        if let data = UserDefaults.standard.data(forKey: customMedicationsKey),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            self.customMedications = decoded
        } else {
            self.customMedications = []
        }
    }

    /// All available medications (built-in + custom)
    var allMedications: [Medication] {
        MedicationDatabase.all + customMedications
    }

    var enabledMedications: [Medication] {
        allMedications.filter { enabledMedicationIDs.contains($0.id) }
    }

    func medications(for category: MedicationCategory) -> [Medication] {
        allMedications.filter { $0.category == category }
    }

    func isEnabled(_ medication: Medication) -> Bool {
        enabledMedicationIDs.contains(medication.id)
    }

    func toggle(_ medication: Medication) {
        if enabledMedicationIDs.contains(medication.id) {
            enabledMedicationIDs.remove(medication.id)
        } else {
            enabledMedicationIDs.insert(medication.id)
        }
    }

    func setEnabled(_ enabled: Bool, for medication: Medication) {
        if enabled {
            enabledMedicationIDs.insert(medication.id)
        } else {
            enabledMedicationIDs.remove(medication.id)
        }
    }

    func addCustomMedication(_ medication: Medication) {
        customMedications.append(medication)
        enabledMedicationIDs.insert(medication.id)
    }

    func deleteCustomMedication(_ medication: Medication) {
        customMedications.removeAll { $0.id == medication.id }
        enabledMedicationIDs.remove(medication.id)
    }

    private func saveEnabledMedications() {
        UserDefaults.standard.set(Array(enabledMedicationIDs), forKey: enabledMedicationsKey)
    }

    private func saveCustomMedications() {
        if let encoded = try? JSONEncoder().encode(customMedications) {
            UserDefaults.standard.set(encoded, forKey: customMedicationsKey)
        }
    }
}
