//
//  PurchaseManager.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 10.07.25.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class PurchaseManager: ObservableObject {
    @Published var hasProAccess: Bool = false
    
    private let productIDs = [
        "MirnijAtom.DokuMan.monthly.pro",
        "MirnijAtom.DokuMan.pro.lifetime"
    ]

    init() {
        Task {
            await checkEntitlements()
        }
    }

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) {
                    hasProAccess = true
                    print("✅ Active entitlement: \(transaction.productID)")
                    return
                }
            }
        }
        hasProAccess = false
        print("❌ No active entitlements")
    }

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                if productIDs.contains(transaction.productID) {
                    hasProAccess = true
                    print("🔁 Transaction update: \(transaction.productID)")
                }
                await transaction.finish()
            }
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                hasProAccess = true
                print("✅ Purchase successful: \(transaction.productID)")
            } else {
                print("❌ Purchase not verified or cancelled.")
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
}
