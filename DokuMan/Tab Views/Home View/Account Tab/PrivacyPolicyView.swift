//
//  PrivacyPolicyView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

// MARK: - PrivacyPolicyView

/// Displays the app's privacy policy in a scrollable view.
struct PrivacyPolicyView: View {
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                Text("""
                Your privacy is important to us. DokuMan is designed with a local-first approach and does not collect, store, or share your personal data unless explicitly required and initiated by you.

                **What data we handle:**
                - You may store sensitive personal documents and ID numbers inside the app.
                - All data remains solely on your device.
                - If you choose to enable iCloud sync, your data is securely stored in your personal iCloud account, managed by Apple.

                **We do not:**
                - Collect analytics or track your usage.
                - Share data with third parties.
                - Access your documents or personal data in any way.

                **Security Measures:**
                - You may enable Face ID for additional protection.
                - The app does not transmit your data externally.

                **Your Rights (GDPR & CCPA):**
                - You can access, modify, or delete your stored data at any time.
                - As data is stored locally, deletion is fully in your control.
                - You are the sole data controller for your stored content.

                **Legal Basis:**
                - Processing is based on your explicit consent and is necessary to provide app functionality.

                **Contact:**
                If you have privacy-related concerns, contact:  
                dokumanapp [at] gmail [dot] com

                **Changes to this Policy:**
                We may update this privacy policy. Substantial changes will be reflected in-app.
                """)
                .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    let themeSettings = ThemeSettings()
    let languageSettings = LanguageSettings()
    PrivacyPolicyView()
        .environmentObject(themeSettings)
        .environmentObject(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
}
