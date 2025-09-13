//
//  Entitlements.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 13.09.25.
//

import Foundation

@MainActor
enum Entitlements {
    private static let key = "isPro"

    static var isPro: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// Tiny wrapper for AppStorage-like behavior outside SwiftUI Views
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
