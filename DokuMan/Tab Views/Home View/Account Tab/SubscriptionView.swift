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
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}
