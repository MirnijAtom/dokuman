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

    init(name: String, category: DocumentCategory, versions: [DocumentVersion]) {
        self.name = name
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

enum DocumentCategory: String, CaseIterable, Codable {
    case wohnung, versicherung, visa, konto, arbeit, steuern, gesundheit, studium
    case fahrzeug, internet, mitgliedschaft, quittungen, behoerden, rechtliches, familie, sonstiges

    var label: String {
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
        case .rechtliches: return .black
        case .familie: return .orange
        case .sonstiges: return .gray.opacity(0.6)
        }
    }
}
