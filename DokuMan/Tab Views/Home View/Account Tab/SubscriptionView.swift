//
//  SubscriptionView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 08.07.25.
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlan: String? = nil
    
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false

    var body: some View {
        VStack {
            VStack(spacing: 24) {
                Image("vault")
                    .resizable()
                    .scaledToFit()
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
                            Text("Free")
                                .font(.headline)
                            Text("Basic usage")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("0 €")
                                .font(.title3).bold()
                            Text("")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)

                    Button {
                        selectedPlan = "Monthly"
                    } label: {
                        VStack(spacing: 8) {
                            Text("Monthly")
                                .font(.headline)
                            Text("All features")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("1.49 €")
                                .font(.title3).bold()
                            Text("Monthly")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding()
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
                    } label: {
                        VStack(spacing: 8) {
                            Text("Lifetime")
                                .font(.headline)
                            Text("One-time purchase")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("9.99 €")
                                .font(.title3).bold()
                            Text("")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedPlan == "Lifetime" ? Color.teal : Color.clear, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 15)

                Button("Subscribe") {
                    // Final purchase trigger
                }
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
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}
