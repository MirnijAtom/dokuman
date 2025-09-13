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
    
    // CHANGED: use typed plan instead of string/product in the view
    @State private var selectedPlan: StoreKitManager.Plan? = nil
    
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
            
            // background blobs
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
                        .padding(.top, 120)
                        .padding(.horizontal, 20)
                    
                    // entitlement banner
                    Text(store.isPro ? "You have DokuMan Pro" : "Get DokuMan Pro")
                        .font(.largeTitle).bold()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Unlimited Documents", systemImage: "doc.on.doc")
                        Label("Unlimited Numbers", systemImage: "numbers")
                        Label("Archive Your Files", systemImage: "archivebox")
                    }
                    .font(.headline)
                    
                    // PLANS
                    VStack {
                        HStack(spacing: 16) {
                            
                            
                            // Monthly
                            Button {
                                selectedPlan = .monthly
                            } label: {
                                VStack(spacing: 8) {
                                    Text("Monthly").font(.headline)
                                    Text("All features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    // CHANGED: dynamic price
                                    Text(store.monthlyPrice).font(.title3).bold()
                                    Text("Monthly payment")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .padding(.vertical)
                                .background(Color.teal.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(selectedPlan == .monthly ? Color.teal : Color.clear, lineWidth: 2)
                                )
                                .cornerRadius(32)
                            }
                            .buttonStyle(.plain)
                            
                            // Yearly
                            Button {
                                selectedPlan = .yearly
                            } label: {
                                VStack(spacing: 8) {
                                    Text("Annual").font(.headline)
                                    Text("All features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    // CHANGED: dynamic price
                                    Text(store.yearlyPrice).font(.title3).bold()
                                    Text("Annual payment")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .padding(.vertical)
                                .background(Color.blue.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(selectedPlan == .yearly ? Color.teal : Color.clear, lineWidth: 2)
                                )
                                .cornerRadius(32)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        
                        // Subscribe
                        Button {
                            guard let plan = selectedPlan else { return }
                            Task { _ = await store.purchase(plan) }
                        } label: {
                            if store.isLoading {
                                ProgressView().tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Subscribe")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(selectedPlan == nil ? Color.gray : Color.teal)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .cornerRadius(12)
                        .disabled(selectedPlan == nil || store.isLoading)
                        
                        HStack {
                            Button("Privacy Policy") { showPrivacyPolicy = true }
                            Text("•")
                                .font(.headline)
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
                        
                        // Restore
                        Button {
                            Task { await store.restore() }
                        } label: {
                            Text("Restore Purchases")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        
                        // Error surface
                        if let err = store.lastError {
                            Text(err)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    
                    
                    
                    
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
}

#Preview {
    let store = StoreKitManager()
    NavigationStack {
        SubscriptionView()
            .environmentObject(store)
    }
}
