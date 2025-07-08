//
//  AccountView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftData
import SwiftUI

// MARK: - AccountView

/// Displays user account settings, including theme, language, legal, and storage info.
struct AccountView: View {
    // MARK: - Environment & State
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var languageSettings: LanguageSettings
    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false
    @State private var showStorageInfo = false
    @State private var showUpgradeToPro = false

    // MARK: - Body
    var body: some View {
        List {
            // MARK: - Appearance & Language
            Section {
                Toggle(LocalizedStringKey("Dark mode"), isOn: $themeSettings.isDarkMode)
                    .toggleStyle(.switch)
                    .onChange(of: themeSettings.isDarkMode) { _, _ in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                HStack {
                    Text(LocalizedStringKey("Language"))
                    Spacer()
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        languageSettings.locale = Locale(identifier: "en")
                    } label: {
                        Image("UKFlag")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(languageSettings.locale.identifier == "en" ? Color.teal.secondary : Color.clear.secondary, lineWidth: 1)
                            )
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    Spacer().frame(width: 16)
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        languageSettings.locale = Locale(identifier: "de")
                    } label: {
                        Image("GermanFlag")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 26)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(languageSettings.locale.identifier == "de" ? Color.teal.secondary : Color.clear.secondary, lineWidth: 1)
                            )
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
                Button(LocalizedStringKey("Storage Info")) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation { showStorageInfo.toggle() }
                }
                .foregroundStyle(.primary)
            }
            // MARK: - Subscription
            Section {
                Button(LocalizedStringKey("Upgrade to Pro")) {
                    showUpgradeToPro = true
                }
                .foregroundStyle(.primary)
                
                Button(LocalizedStringKey("Manage Subscription")) {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundStyle(.primary)
            }
            // MARK: - Legal
            Section {
                Button(LocalizedStringKey("Privacy Policy")) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation { showPrivacyPolicy = true }
                }
                .foregroundStyle(.primary)
                Button(LocalizedStringKey("Terms & Conditions")) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    withAnimation { showTermsAndConditions = true }
                }
                .foregroundStyle(.primary)
            }
            // MARK: - Placeholder Section
            Section {
                // Reserved for future settings
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsAndConditions) {
            TermsAndConditionsView()
        }
        .sheet(isPresented: $showStorageInfo) {
            StorageInfoView()
        }
        .fullScreenCover(isPresented: $showUpgradeToPro) {
            NavigationStack {
                SubscriptionView()
            }
        }
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    AccountView()
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
}
