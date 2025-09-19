//
//  SubscriptionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 08.07.25.
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
            

            // background blobs
//            Circle()
//                .fill(Color.teal.opacity(0.3))
//                .frame(width: 300, height: 300)
//                .offset(x: -150, y: -200)
//                .blur(radius: 60)
//
//            Circle()
//                .fill(Color.teal.opacity(0.2))
//                .frame(width: 250, height: 250)
//                .offset(x: 120, y: 300)
//                .blur(radius: 40)

            VStack {
                VStack(spacing: 24) {
                    Image("vault")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 120)
                        .padding(.horizontal, 20)

                    // entitlement banner
                    Text(store.isPro ? "You have DokuMan Pro" : "Get DokuMan Pro")
                        .font(.largeTitle).bold()

                    // features
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Unlimited Documents", systemImage: "doc.on.doc")
                        Label("Unlimited Numbers", systemImage: "numbers")
                        Label("Archive Your Files", systemImage: "archivebox")
                    }
                    .font(.headline)

                    // LIFETIME CARD
                    VStack(spacing: 8) {
                        Text("Lifetime Access")
                            .font(.headline)
                        Text("One-time purchase. All features, forever on this Apple ID.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer(minLength: 4)

                        // Price
                        Text(store.lifetimePrice)
                            .font(.title3).bold()

                        Text("one-time payment")
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
                    .accessibilityLabel("Lifetime. One-time payment \(store.lifetimePrice).")

                    VStack (spacing: 2) {
                    // UNLOCK BUTTON
                    Button {
                        Task {
                            _ = await store.purchase(.lifetime)
                        }
                    } label: {
                        if store.isLoading {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(store.isPro ? "Already Unlocked" : "Unlock Lifetime")
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
                            Button("Privacy Policy") { showPrivacyPolicy = true }
                            Text("•").font(.headline)
                            Button("Terms & Conditions") { showTerms = true }
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .sheet(isPresented: $showPrivacyPolicy) {
                            PrivacyPolicyView()
                        }
                        .sheet(isPresented: $showTerms) {
                            TermsAndConditionsView()
                        }
                        
                        // RESTORE (required by Apple, restores non-consumable)
                        Button {
                            Task { await store.restore() }
                        } label: {
                            Text("Restore Purchases")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        
                        // LEGAL FOOTNOTE for non-consumable
                        Text(footnoteText)
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
        .task {
            await store.loadProducts()
        }
    }

    // One-time purchase legal copy (short + compliant)
    private var footnoteText: String {
        "One-time purchase. Payment is charged to your Apple ID. No auto-renewal. You can restore your purchase on a new device with the same Apple ID."
    }
}

#Preview {
    let store = StoreKitManager()
    NavigationStack {
        SubscriptionView()
            .environmentObject(store)
    }
}
