//
//  SubscriptionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 08.07.25.
//

//
//  SubscriptionView.swift
//  DokuMan
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StoreKitManager

    @State private var showPrivacyPolicy = false
    @State private var showTerms = false

    var body: some View {
        ZStack {
            Color(.cyan.withProminence(.tertiary))

            VStack {
                VStack(spacing: 24) {
                    Image("vault")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 120)
                        .padding(.horizontal, 20)

                    // entitlement banner
                    Text(store.isPro ? LocalizedStringKey("pro_title_have")
                                     : LocalizedStringKey("pro_title_get"))
                        .font(.largeTitle).bold()

                    // features
                    VStack(alignment: .leading, spacing: 12) {
                        Label(LocalizedStringKey("feature_unlimited_docs"), systemImage: "doc.on.doc")
                        Label(LocalizedStringKey("feature_unlimited_numbers"), systemImage: "numbers")
                        Label(LocalizedStringKey("feature_archive"), systemImage: "archivebox")
                    }
                    .font(.headline)

                    // LIFETIME CARD
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey("lifetime_title"))
                            .font(.title2)

                        Text(LocalizedStringKey("lifetime_subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer(minLength: 4)

                        // Localized price comes from StoreKit
                        Text(store.lifetimePrice)
                            .font(.title3).bold()

                        Text(LocalizedStringKey("lifetime_price_note"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .fill(Color.cyan.secondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .stroke(Color.teal, lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        Text("\(NSLocalizedString("lifetime_title", comment: "")) \(store.lifetimePrice)")
                    )

                    VStack (spacing: 2) {
                        // UNLOCK BUTTON
                        Button {
                            Task { _ = await store.purchase(.lifetime) }
                        } label: {
                            if store.isLoading {
                                ProgressView().tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(store.isPro ? LocalizedStringKey("cta_already_unlocked")
                                                 : LocalizedStringKey("cta_unlock_lifetime"))
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .glassEffect(.regular.tint(.cyan))
                        .foregroundColor(.black)
                        .disabled(store.isPro || store.isLoading || store.lifetime == nil)

                        // LINKS
                        HStack {
                            Button(LocalizedStringKey("Privacy Policy")) { showPrivacyPolicy = true }
                            Text("•").font(.headline)
                            Button(LocalizedStringKey("Terms & Conditions")) { showTerms = true }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .sheet(isPresented: $showPrivacyPolicy) { PrivacyPolicyView() }
                        .sheet(isPresented: $showTerms) { TermsAndConditionsView() }

                        // RESTORE (required by Apple)
                        Button {
                            Task { await store.restore() }
                        } label: {
                            Text(LocalizedStringKey("restore_purchases"))
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                        // LEGAL FOOTNOTE (non-consumable)
                        Text(LocalizedStringKey("legal_lifetime"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Error surface
                        if let err = store.lastError {
                            Text(err)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "chevron.left") }
                }
            }
        }
        .ignoresSafeArea()
        .task { await store.loadProducts() }
    }
}

#Preview {
    let store = StoreKitManager()
    NavigationStack {
        SubscriptionView()
            .environmentObject(store)
    }
}
