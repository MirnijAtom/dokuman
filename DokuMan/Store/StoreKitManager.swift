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

    // MARK: - Product IDs
    enum IDs {
        static let monthly = "MirnijAtom.DokuMan.monthly.pro"
        static let yearly  = "MirnijAtom.DokuMan.yearly.pro"
    }

    // MARK: - Public State (UI-safe)
    @Published var products: [Product] = []
    @Published var monthly: Product?
    @Published var yearly: Product?

    // Cached display prices for UI
    @Published var monthlyPrice: String = "€0.99"
    @Published var yearlyPrice:  String = "€9.99"

    // Cached trial labels like "14-day free trial", nil if none
    @Published var monthlyTrialText: String?
    @Published var yearlyTrialText: String?

    // Entitlement and UX state
    @Published var isPro: Bool = false
    @Published var isLoading = false
    @Published var lastError: String?

    // Convenience flags
    var hasIntroMonthly: Bool { monthlyTrialText != nil }
    var hasIntroYearly:  Bool { yearlyTrialText  != nil }

    // MARK: - Lifecycle
    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - API

    enum Plan { case monthly, yearly }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let ids = [IDs.monthly, IDs.yearly]
            let fetched = try await Product.products(for: ids)

            products = fetched
            monthly  = fetched.first(where: { $0.id == IDs.monthly })
            yearly   = fetched.first(where: { $0.id == IDs.yearly })

            // Cache localized display prices
            if let dp = monthly?.displayPrice { monthlyPrice = dp }
            if let dp = yearly?.displayPrice  { yearlyPrice  = dp }

            // Cache trial texts from introductory offers
            monthlyTrialText = trialText(for: monthly)
            yearlyTrialText  = trialText(for: yearly)

            try await refreshEntitlements()
        } catch {
            lastError = "Failed to load products: \(error.localizedDescription)"
        }
    }

    @discardableResult
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
        isPro = pro
        Entitlements.isPro = pro
    }

    // MARK: - Internals

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

    // Build a human readable trial text from a Product introductory offer
    private func trialText(for product: Product?) -> String? {
        guard
            let offer = product?.subscription?.introductoryOffer,
            offer.paymentMode == .freeTrial
        else { return nil }

        let p = offer.period
        switch p.unit {
        case .day:
            return p.value == 14 ? "14-day free trial" : "\(p.value)-day free trial"
        case .week:
            return p.value == 2 ? "2-week free trial" : "\(p.value)-week free trial"
        case .month:
            return p.value == 1 ? "1-month free trial" : "\(p.value)-month free trial"
        case .year:
            return p.value == 1 ? "1-year free trial" : "\(p.value)-year free trial"
        @unknown default:
            return "Free trial"
        }
    }

    // Allow calling from detached tasks without MainActor hops
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
