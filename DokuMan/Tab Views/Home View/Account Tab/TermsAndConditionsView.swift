//
//  TermsAndConditionsView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

struct TermsAndConditionsView: View {
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
        locale.identifier.starts(with: "de") ? "Rechtliches" : "Legal"
    }

    private var englishContent: some View {
        Group {
            Text("Terms and Privacy")
                .font(.largeTitle)
                .bold()

            Text("Summary")
                .font(.title2)
                .bold()

            Text("""
DokuMan is designed to securely store and manage sensitive personal documents, including identification numbers, certificates, and contracts. Your data is stored locally on your device and optionally synced via your personal iCloud account. We do not collect, process, or transmit any personal information to our servers.

Face ID authentication is available in the free version of the app to help protect access. This uses Apple’s secure biometric system and no biometric data is ever stored by the app.

By using this app, you accept full responsibility for the data you store. We disclaim liability for any data loss or misuse. Use is at your own risk.
""")

            Divider()

            Text("Terms and Conditions")
                .font(.title2)
                .bold()

            Text("""
Last updated: July 10, 2025

1. **Scope**  
These Terms govern your use of the DokuMan application provided by Aleksandrs Bertulis ("Developer").

2. **License**  
You are granted a non-transferable, non-exclusive license to use the app on Apple-branded devices you own. Use is personal and non-commercial.

3. **Storage of Sensitive Data**  
You are responsible for ensuring that any sensitive content stored in the app complies with applicable laws. Syncing with iCloud is optional and governed by Apple's terms.

4. **No Access by Developer**  
The Developer does not access or store your data. All files and information remain on your device or in your personal iCloud account.

5. **Security**  
DokuMan supports Face ID for device-level access protection. This uses Apple’s secure biometric system. The app does not collect or store biometric data. Despite precautions, no security system is foolproof and use is at your own risk.

6. **Limitation of Liability**  
The Developer shall not be liable for data loss, misuse, or damages resulting from use of the app.

7. **Modifications**  
These Terms may change. Continued use of the app after changes means you accept the new Terms.

8. **Apple EULA**  
These Terms incorporate Apple's standard EULA:  
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""")

            Divider()

            Text("Privacy Policy")
                .font(.title2)
                .bold()

            Text("To understand how we handle your personal data, see the separate Privacy Policy available in the app.")

            Divider()

            Text("Impressum")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("Aleksandrs Bertulis")
                Text("Dehnhaide 153")
                Text("22081 Hamburg")
                Text("Germany")
                Text("Email: aleksandrs dot bertulis at gmail dot com")
            }
            .font(.body)
            .foregroundColor(.primary)
            .textSelection(.enabled)
        }
    }

    private var germanContent: some View {
        Group {
            Text("Nutzungsbedingungen und Datenschutz")
                .font(.largeTitle)
                .bold()

            Text("Zusammenfassung")
                .font(.title2)
                .bold()

            Text("""
DokuMan ist dafür entwickelt, sensible persönliche Dokumente sicher zu speichern und zu verwalten, einschließlich Identifikationsnummern, Bescheinigungen und Verträgen. Ihre Daten werden lokal auf Ihrem Gerät gespeichert und optional über Ihr persönliches iCloud-Konto synchronisiert. Wir sammeln, verarbeiten oder übertragen keine personenbezogenen Daten an unsere Server.

Face ID-Authentifizierung ist in der kostenlosen Version der App verfügbar, um den Zugriff zu schützen. Dabei wird Apples sicheres biometrisches System verwendet, und keine biometrischen Daten werden von der App gespeichert.

Durch die Nutzung dieser App übernehmen Sie die volle Verantwortung für die gespeicherten Daten. Wir schließen jegliche Haftung für Datenverlust oder Missbrauch aus. Die Nutzung erfolgt auf eigenes Risiko.
""")

            Divider()

            Text("Nutzungsbedingungen")
                .font(.title2)
                .bold()

            Text("""
Zuletzt aktualisiert: 10. Juli 2025

1. **Geltungsbereich**  
Diese Bedingungen regeln Ihre Nutzung der von Aleksandrs Bertulis ("Entwickler") bereitgestellten DokuMan-Anwendung.

2. **Lizenz**  
Sie erhalten eine nicht übertragbare, nicht exklusive Lizenz zur Nutzung der App auf Apple-Geräten, die Sie besitzen. Die Nutzung ist persönlich und nicht kommerziell.

3. **Speicherung sensibler Daten**  
Sie sind verantwortlich dafür, dass alle in der App gespeicherten sensiblen Inhalte den geltenden Gesetzen entsprechen. Die Synchronisierung mit iCloud ist optional und unterliegt Apples Bedingungen.

4. **Kein Zugriff durch den Entwickler**  
Der Entwickler hat keinen Zugriff auf Ihre Daten und speichert diese nicht. Alle Dateien und Informationen verbleiben auf Ihrem Gerät oder in Ihrem persönlichen iCloud-Konto.

5. **Sicherheit**  
DokuMan unterstützt Face ID zum Schutz des Gerätezugriffs. Dabei wird Apples sicheres biometrisches System verwendet. Die App speichert keine biometrischen Daten. Trotz aller Vorsichtsmaßnahmen ist kein Sicherheitssystem unfehlbar; die Nutzung erfolgt auf eigenes Risiko.

6. **Haftungsbeschränkung**  
Der Entwickler haftet nicht für Datenverlust, Missbrauch oder Schäden, die aus der Nutzung der App entstehen.

7. **Änderungen**  
Diese Bedingungen können sich ändern. Die fortgesetzte Nutzung der App nach Änderungen bedeutet Ihre Zustimmung zu den neuen Bedingungen.

8. **Apple EULA**  
Diese Bedingungen schließen Apples Standard-EULA ein:  
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""")

            Divider()

            Text("Datenschutzerklärung")
                .font(.title2)
                .bold()

            Text("Um zu verstehen, wie wir Ihre persönlichen Daten behandeln, lesen Sie bitte die separate Datenschutzerklärung, die in der App verfügbar ist.")

            Divider()

            Text("Impressum")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("Aleksandrs Bertulis")
                Text("Dehnhaide 153")
                Text("22081 Hamburg")
                Text("Deutschland")
                Text("Email: aleksandrs punkt bertulis at gmail punkt com")
            }
            .font(.body)
            .foregroundColor(.primary)
            .textSelection(.enabled)
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
    TermsAndConditionsView()
}
