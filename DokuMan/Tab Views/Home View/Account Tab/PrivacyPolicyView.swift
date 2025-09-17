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

                // Website links block
                webLinks
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
Last updated: September 2025

This Privacy Policy applies to the apps DokuMan and DevelopFilm, published by Nice Things Studio.

Data Collection
We do not collect or share your personal data. We do not run our own servers and have no access to your documents, photos, or usage data.

On-Device Storage
All documents, numbers, journal entries, and photos you add are stored locally on your device. They remain under your control and are not transmitted to us.

Optional iCloud Storage
If you enable iCloud features, your data is stored with Apple’s iCloud under your Apple ID. We do not operate iCloud and cannot access this data.

Payments
Subscriptions and in-app purchases are handled by Apple via the App Store. We do not process or see your payment information.

Security
The app uses the iOS sandbox for data isolation. If enabled, Face ID or passcode protection adds an extra layer of security.

Your Rights
You can delete the app at any time to remove data stored on your device. You can also disable iCloud sync in your device settings.

Contact
If you have questions, contact: aleksandrs[dot]bertulis[at]gmail[dot]com

Changes
We may update this policy. Significant changes will be shown in the app.
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
Zuletzt aktualisiert: September 2025

Diese Datenschutzerklärung gilt für die Apps DokuMan und DevelopFilm von Nice Things Studio.

Datenerhebung
Wir erheben oder teilen keine personenbezogenen Daten. Wir betreiben keine eigenen Server und haben keinen Zugriff auf Ihre Dokumente, Fotos oder Nutzungsdaten.

Lokale Speicherung
Alle von Ihnen hinzugefügten Dokumente, Nummern, Journaleinträge und Fotos werden lokal auf Ihrem Gerät gespeichert. Sie bleiben unter Ihrer Kontrolle und werden nicht an uns übermittelt.

Optionale iCloud-Speicherung
Wenn Sie iCloud-Funktionen aktivieren, werden Ihre Daten unter Ihrer Apple-ID in Apples iCloud gespeichert. Wir betreiben iCloud nicht und haben keinen Zugriff auf diese Daten.

Zahlungen
Abonnements und In-App-Käufe werden über den App Store von Apple abgewickelt. Wir verarbeiten keine Zahlungsdaten und sehen diese nicht ein.

Sicherheit
Die App nutzt die iOS-Sandbox zur Datenisolation. Optional aktivierbare Face ID oder Code-Sperre bieten zusätzlichen Schutz.

Ihre Rechte
Sie können die App jederzeit löschen, um lokal gespeicherte Daten zu entfernen. iCloud-Synchronisation kann in den Geräteeinstellungen deaktiviert werden.

Kontakt
Bei Fragen: aleksandrs[dot]bertulis[at]gmail[dot]com

Änderungen
Wir können diese Erklärung aktualisieren. Wesentliche Änderungen werden in der App angezeigt.
""")
            .font(.body)

            Spacer()
        }
    }

    // MARK: - Website links (localized labels, fixed URLs)
    private var webLinks: some View {
        VStack(spacing: 8) {
            Divider().padding(.top, 4)
            HStack(spacing: 12) {
                Link(locale.identifier.starts(with: "de") ? "Impressum (Website)" : "Impressum (Website)",
                     destination: URL(string: "https://mirnijatom.github.io/dokuman/impressum.html")!)
                Text("·").foregroundStyle(.secondary)
                Link(locale.identifier.starts(with: "de") ? "Datenschutz (Website)" : "Privacy Policy (Website)",
                     destination: URL(string: "https://mirnijatom.github.io/dokuman/privacy.html")!)
                Text("·").foregroundStyle(.secondary)
                Link(locale.identifier.starts(with: "de") ? "Nutzungsbedingungen (Website)" : "Terms of Use (Website)",
                     destination: URL(string: "https://mirnijatom.github.io/dokuman/terms.html")!)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 2)
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
