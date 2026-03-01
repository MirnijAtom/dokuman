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
        ScrollView {
            VStack(spacing: 24) {
                Image("vault")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .padding(.top, 24)

                Text(store.isPro ? LocalizedStringKey("pro_title_have")
                                 : LocalizedStringKey("pro_title_get"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 14) {
                    featureRow("feature_unlimited_docs", icon: "doc.on.doc")
                    Divider().padding(.leading, 28)
                    featureRow("feature_unlimited_numbers", icon: "numbers")
                    Divider().padding(.leading, 28)
                    featureRow("feature_archive", icon: "archivebox")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("lifetime_title"))
                            .font(.headline)
                        Text(LocalizedStringKey("lifetime_price_note"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(store.lifetimePrice)
                        .font(.headline.weight(.semibold))
                }
                .padding(16)
                .frame(minHeight: 86)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )

                if let err = store.lastError {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 140)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button {
                    Task { _ = await store.purchase(.lifetime) }
                } label: {
                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text(store.isPro ? LocalizedStringKey("cta_already_unlocked")
                                         : LocalizedStringKey("cta_unlock_lifetime"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.cyan)
                )
                .disabled(store.isPro || store.isLoading || store.lifetime == nil)

                HStack(spacing: 10) {
                    Button(LocalizedStringKey("Privacy Policy")) { showPrivacyPolicy = true }
                    Text("•").foregroundStyle(.secondary)
                    Button(LocalizedStringKey("Terms & Conditions")) { showTerms = true }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showPrivacyPolicy) { PrivacyPolicyView() }
        .sheet(isPresented: $showTerms) { TermsAndConditionsView() }
        .task { await store.loadProducts() }
    }

    @ViewBuilder
    private func featureRow(_ title: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 18, alignment: .center)
            Text(title)
        }
        .font(.subheadline)
    }
}

#Preview {
    let store = StoreKitManager()
    NavigationStack {
        SubscriptionView()
            .environmentObject(store)
    }
}
