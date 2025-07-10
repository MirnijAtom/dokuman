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
    
    @State private var selectedPlan: String? = nil
    
    @State private var selectedProduct: Product? = nil
    @State private var products: [Product] = []
    
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    
    let productIDs = ["MirnijAtom.DokuMan.monthly.pro", "MirnijAtom.DokuMan.pro.lifetime"]

    var body: some View {
        ZStack {
            Color(.systemBackground)

            Circle()
                .fill(Color.teal.opacity(0.3))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -200)
                .blur(radius: 60)

            Circle()
                .fill(Color.teal.opacity(0.2))
                .frame(width: 250, height: 250)
                .offset(x: 120, y: 300)
                .blur(radius: 40)

        VStack {
            VStack(spacing: 24) {
                Image("vault")
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                Text("Get DokuMan Pro")
                    .font(.largeTitle).bold()

                VStack(alignment: .leading, spacing: 12) {
                    Label("Unlimited Documents", systemImage: "doc.on.doc")
                    Label("Secure Backup", systemImage: "lock.shield")
                    Label("Face ID Lock", systemImage: "faceid")
                }
                .font(.headline)
                

                
                HStack(spacing: 12) {
                    Button {
//                        selectedPlan = "Free"
                    } label: {
                        VStack(spacing: 8) {
                            Text("Basic")
                                .font(.headline)
                            Text("Basic usage")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Free")
                                .font(.title3).bold()
                            Text("")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding(.vertical)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Button {
                        selectedPlan = "Monthly"
                        selectedProduct = products.first { $0.id == "MirnijAtom.DokuMan.monthly.pro" }
                    } label: {
                        VStack(spacing: 8) {
                            Text("Monthly")
                                .font(.headline)
                            Text("All features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("0.99 €")
                                .font(.title3).bold()
                            Text("Monthly payment")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding(.vertical)
                        .background(Color.teal.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPlan == "Monthly" ? Color.teal : Color.clear, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Button {
                        selectedPlan = "Lifetime"
                        selectedProduct = products.first { $0.id == "MirnijAtom.DokuMan.pro.lifetime" }
                    } label: {
                        VStack(spacing: 8) {
                            Text("Lifetime")
                                .font(.headline)
                            Text("All features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("9.99 €")
                                .font(.title3).bold()
                            Text("One-time purchase")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding(.vertical)
                        .background(Color.blue.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPlan == "Lifetime" ? Color.teal : Color.clear, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                Button("Subscribe") {
                    guard let product = selectedProduct else { return }
                    Task {
                        await purchase(product)
                    }                }
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(12)

                HStack {
                    Button("Privacy Policy") { showPrivacyPolicy = true }
                    Spacer()
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
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        }
        .ignoresSafeArea()
        .task {
            do {
                products = try await Product.products(for: productIDs)
            } catch {
                print("❌ Failed to load products: \(error)")
            }
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                print("✅ Purchase successful: \(transaction.productID)")
                // Unlock features here
            } else {
                print("❌ Purchase not verified or cancelled.")
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
    
    @MainActor
    func loadProducts() async throws -> [Product] {
        let productIDs = [
            "MirnijAtom.DokuMan.monthly.pro",
            "MirnijAtom.DokuMan.pro.lifetime"
        ]
        return try await Product.products(for: productIDs)
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}
