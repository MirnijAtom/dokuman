//
//  Models.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 14.04.25.
//

import Foundation
import SwiftData

@Model
class Document {
    var name: String
    var category: String
    var versions: [DocumentVersion] = []
    
    init(name: String, category: String, versions: [DocumentVersion]) {
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
