//
//  StoreKitManager.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 13.09.25.
//

import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    // Your product IDs
    enum IDs {
        static let monthly = "MirnijAtom.DokuMan.monthly.pro"
        static let yearly  = "MirnijAtom.DokuMan.yearly.pro"
    }

    // Products
    @Published var products: [Product] = []
    @Published var monthly: Product?
    @Published var yearly: Product?

    // Cached, UI-safe price strings (avoid touching Product in SwiftUI render path)
    @Published var monthlyPrice: String = "€1.99"
    @Published var yearlyPrice:  String = "€11.99"

    // State
    @Published var isPro: Bool = false
    @Published var isLoading = false
    @Published var lastError: String?

    // Optional intro offer flags
    var hasIntroMonthly: Bool { monthly?.subscription?.introductoryOffer != nil }
    var hasIntroYearly:  Bool { yearly?.subscription?.introductoryOffer != nil }

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // Load products and cache display prices
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = [IDs.monthly, IDs.yearly]
            let fetched = try await Product.products(for: ids)

            self.products = fetched
            self.monthly  = fetched.first(where: { $0.id == IDs.monthly })
            self.yearly   = fetched.first(where: { $0.id == IDs.yearly })

            // Cache display prices (formatted per storefront/locale)
            if let p = monthly?.displayPrice { self.monthlyPrice = p }
            if let p = yearly?.displayPrice  { self.yearlyPrice  = p }

            try await refreshEntitlements()
        } catch {
            self.lastError = "Failed to load products: \(error.localizedDescription)"
        }
    }

    enum Plan { case monthly, yearly }

    func purchase(_ plan: Plan) async -> Bool {
        let product: Product?
        switch plan {
        case .monthly: product = monthly
        case .yearly:  product = yearly
        }
        guard let product else {
            lastError = "Product not available."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                try await refreshEntitlements()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            try await refreshEntitlements()
        } catch {
            lastError = "Restore failed: \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async throws {
        var pro = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productType == .autoRenewable {
                pro = true
            }
        }
        self.isPro = pro
        Entitlements.isPro = pro
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try self.checkVerified(update)
                    await transaction.finish()
                    try await self.refreshEntitlements()
                } catch {
                    await MainActor.run {
                        self.lastError = "Verification failed."
                    }
                }
            }
        }
    }

    // Marked nonisolated so it can be called from detached tasks without 'await'
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notEntitled
        case .verified(let safe):
            return safe
        }
    }

    enum StoreKitError: Error { case notEntitled }
}
