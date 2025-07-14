//
//  Models.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI
import SwiftData

// MARK: - Document Model

/// Represents a document with versions, category, and metadata.
@Model
class Document: Identifiable {
    /// Unique identifier for the document (required by SwiftUI)
    var id: UUID = UUID()
    /// The display name of the document
    var name: String
    /// The category of the document
    var category: DocumentCategory
    /// Whether the document is marked as favorite
    var isFavorite: Bool = false
    /// Whether the document is archived
    var isArchived: Bool = false
    /// All versions of the document (PDF data, etc.)
    var versions: [DocumentVersion] = []

    /// Initializes a new Document
    init(name: String, isFavorite: Bool = false, isArchived: Bool = false, category: DocumentCategory, versions: [DocumentVersion]) {
        self.name = name
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.category = category
        self.versions = versions
    }
}

// MARK: - DocumentVersion Model

/// Represents a single version of a document (e.g., a PDF file)
@Model
class DocumentVersion {
    var fileData: Data
    var dateAdded: Date
    var note: String?

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: dateAdded)
    }

    init(fileData: Data, dateAdded: Date = Date(), note: String? = nil) {
        self.fileData = fileData
        self.dateAdded = dateAdded
        self.note = note
    }
}

// MARK: - Number Model

/// Represents a number/ID (e.g., insurance number, tax ID)
@Model
class Number {
    /// Unique identifier for the number
    var id: UUID = UUID()
    /// The display name of the number
    var name: String
    /// The actual number or ID string
    var idNumber: String
    /// Whether the number is marked as completed
    var isCompleted: Bool
    
    /// Initializes a new Number
    init(name: String, idNumber: String, isCompleted: Bool = false) {
        self.name = name
        self.idNumber = idNumber
        self.isCompleted = isCompleted
    }
}

// MARK: - DocumentCategory Enum

/// All possible categories for a document
/// Provides label, icon, and color for each category
/// (Extend as needed for new categories)
enum DocumentCategory: String, CaseIterable, Codable {
    case wohnung, versicherung, visa, konto, arbeit, steuern, gesundheit, studium
    case fahrzeug, internet, mitgliedschaft, quittungen, behoerden, rechtliches, familie, sonstiges

    /// Localized label for display
    var label: LocalizedStringKey {
        switch self {
        case .wohnung: return "Wohnung"
        case .versicherung: return "Versicherung"
        case .visa: return "Visa"
        case .konto: return "Konto"
        case .arbeit: return "Arbeit"
        case .steuern: return "Steuern"
        case .gesundheit: return "Gesundheit"
        case .studium: return "Studium"
        case .fahrzeug: return "Fahrzeug"
        case .internet: return "Internet & Handy"
        case .mitgliedschaft: return "Mitgliedschaften"
        case .quittungen: return "Rechnungen & Quittungen"
        case .behoerden: return "Behörden"
        case .rechtliches: return "Rechtliches"
        case .familie: return "Familie"
        case .sonstiges: return "Sonstiges"
        }
    }

    /// SF Symbol icon for the category
    var icon: String {
        switch self {
        case .wohnung: return "house.fill"
        case .versicherung: return "shield.lefthalf.filled.badge.checkmark"
        case .visa: return "globe"
        case .konto: return "creditcard.fill"
        case .arbeit: return "briefcase.fill"
        case .steuern: return "doc.text.fill"
        case .gesundheit: return "cross.case.fill"
        case .studium: return "graduationcap.fill"
        case .fahrzeug: return "car.fill"
        case .internet: return "antenna.radiowaves.left.and.right"
        case .mitgliedschaft: return "person.3.fill"
        case .quittungen: return "dollarsign"
        case .behoerden: return "building.columns.fill"
        case .rechtliches: return "book.closed.fill"
        case .familie: return "person.2.fill"
        case .sonstiges: return "tray.fill"
        }
    }

    /// Color for the category (used in UI)
    var color: Color {
        switch self {
        case .wohnung: return .blue
        case .versicherung: return .orange
        case .visa: return .teal
        case .konto: return .purple
        case .arbeit: return .cyan
        case .steuern: return .indigo
        case .gesundheit: return .red
        case .studium: return .mint
        case .fahrzeug: return .gray
        case .internet: return .pink
        case .mitgliedschaft: return .brown
        case .quittungen: return .yellow
        case .behoerden: return .green
        case .rechtliches: return .secondary
        case .familie: return .orange
        case .sonstiges: return .gray.opacity(0.6)
        }
    }
}

