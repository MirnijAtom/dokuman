//
//  PrivacyPolicyView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if locale.identifier.starts(with: "de") {
                    germanContent
                } else {
                    englishContent
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(localizedTitle)
    }

    private var localizedTitle: LocalizedStringKey {
        locale.identifier.starts(with: "de") ? "Datenschutzerklärung" : "Privacy Policy"
    }

    private var englishContent: some View {
        Group {
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
    }

    private var germanContent: some View {
        Group {
            Text("Datenschutzerklärung")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)

            Text("""
Ihre Privatsphäre ist uns wichtig. DokuMan ist lokal ausgelegt und sammelt, speichert oder teilt Ihre personenbezogenen Daten nicht, außer Sie initiieren dies explizit.

**Welche Daten wir verarbeiten:**
- Sie können sensible persönliche Dokumente und Identifikationsnummern in der App speichern.
- Alle Daten bleiben ausschließlich auf Ihrem Gerät.
- Wenn Sie iCloud-Sync aktivieren, werden Ihre Daten sicher in Ihrem persönlichen iCloud-Konto gespeichert, das von Apple verwaltet wird.

**Wir tun nicht:**
- Analysen sammeln oder Ihre Nutzung verfolgen.
- Daten mit Dritten teilen.
- Auf Ihre Dokumente oder persönlichen Daten zugreifen.

**Sicherheitsmaßnahmen:**
- Sie können Face ID für zusätzlichen Schutz aktivieren.
- Die App überträgt Ihre Daten nicht extern.

**Ihre Rechte (DSGVO & CCPA):**
- Sie können jederzeit auf Ihre gespeicherten Daten zugreifen, diese ändern oder löschen.
- Da die Daten lokal gespeichert sind, kontrollieren Sie die Löschung vollständig.
- Sie sind alleiniger Datenverantwortlicher für Ihre gespeicherten Inhalte.

**Rechtsgrundlage:**
- Die Verarbeitung basiert auf Ihrer ausdrücklichen Zustimmung und ist notwendig für die Funktionalität der App.

**Kontakt:**
Bei datenschutzbezogenen Fragen kontaktieren Sie:  
dokumanapp [at] gmail [punkt] com

**Änderungen an dieser Richtlinie:**
Wir können diese Datenschutzerklärung aktualisieren. Wesentliche Änderungen werden in der App angezeigt.
""")
            .font(.body)

            Spacer()
        }
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
