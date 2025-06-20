//
//  Models.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import SwiftUI
import SwiftData

@Model
class Document: Identifiable {
    var id: UUID = UUID() // 👈 SwiftUI needs this
    var name: String
    var category: DocumentCategory
    var isFavorite: Bool = false
    var isArchived: Bool = false
    var versions: [DocumentVersion] = []

    init(name: String, isFavorite: Bool = false, isArchived: Bool = false, category: DocumentCategory, versions: [DocumentVersion]) {
        self.name = name
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.category = category
        self.versions = versions
    }
}

@Model
class DocumentVersion {
    var fileData: Data
    var dateAdded: Date
    var note: String?
    
    init(fileData: Data, dateAdded: Date, note: String? = nil) {
        self.fileData = fileData
        self.dateAdded = dateAdded
        self.note = note
    }
}

@Model
class Number {
    var id: UUID = UUID()
    var name: String
    var idNumber: String
    var isCompleted: Bool
    
    init(name: String, idNumber: String, isCompleted: Bool = false) {
        self.name = name
        self.idNumber = idNumber
        self.isCompleted = isCompleted
    }
}

enum DocumentCategory: String, CaseIterable, Codable {
    case wohnung, versicherung, visa, konto, arbeit, steuern, gesundheit, studium
    case fahrzeug, internet, mitgliedschaft, quittungen, behoerden, rechtliches, familie, sonstiges

    var label: String {
        switch self {
        case .wohnung: return NSLocalizedString("Wohnung", comment: "Category name")
        case .versicherung: return NSLocalizedString("Versicherung", comment: "Category name")
        case .visa: return NSLocalizedString("Visa", comment: "Category name")
        case .konto: return NSLocalizedString("Konto", comment: "Category name")
        case .arbeit: return NSLocalizedString("Arbeit", comment: "Category name")
        case .steuern: return NSLocalizedString("Steuern", comment: "Category name")
        case .gesundheit: return NSLocalizedString("Gesundheit", comment: "Category name")
        case .studium: return NSLocalizedString("Studium", comment: "Category name")
        case .fahrzeug: return NSLocalizedString("Fahrzeug", comment: "Category name")
        case .internet: return NSLocalizedString("Internet & Handy", comment: "Category name")
        case .mitgliedschaft: return NSLocalizedString("Mitgliedschaften", comment: "Category name")
        case .quittungen: return NSLocalizedString("Rechnungen & Quittungen", comment: "Category name")
        case .behoerden: return NSLocalizedString("Behörden", comment: "Category name")
        case .rechtliches: return NSLocalizedString("Rechtliches", comment: "Category name")
        case .familie: return NSLocalizedString("Familie", comment: "Category name")
        case .sonstiges: return NSLocalizedString("Sonstiges", comment: "Category name")
        }
    }

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

