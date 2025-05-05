//
//  DataManager.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 05.05.25.
//

import SwiftData

struct DataManager {
    static func loadDefaultNumbersIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Number>()
        if let count = try? context.fetchCount(descriptor), count == 0 {
            for defaultNumber in Number.defaultNumbers {
                context.insert(defaultNumber)
            }
            try? context.save()
        }
    }
}
