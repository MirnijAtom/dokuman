//
//  TermsAndConditionsView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

struct TermsAndConditionsView: View {
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms and Privacy")
                    .font(.largeTitle)
                    .bold()

                Text("Summary")
                    .font(.title2)
                    .bold()

                Text("""
DokuMan is designed to securely store and manage sensitive personal documents, including identification numbers, certificates, and contracts. Your data is stored locally on your device and optionally synced via your personal iCloud account. We do not collect, process, or transmit any personal information to our servers.

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
Subject to your compliance with these Terms, the Developer grants you a non-transferable, non-exclusive license to use the app on Apple-branded products you own or control. The license is for personal, non-commercial use only.

3. **Storage of Sensitive Data**  
DokuMan is designed for the local storage of sensitive documents. You are responsible for ensuring the safety and legality of the content you upload. Enabling iCloud sync is optional and subject to Apple's policies.

4. **No Access by Developer**  
The Developer does not access, store, or transmit any of your documents or personal data. Your data remains on your device or in your personal iCloud account.

5. **Security**  
While local device encryption and iCloud offer a secure storage environment, the Developer disclaims all warranties related to data security, loss, or unauthorized access.

6. **Limitation of Liability**  
To the fullest extent permitted by law, the Developer shall not be liable for any loss of data, damages, or misuse arising from your use of the app.

7. **Modifications**  
These Terms may be updated occasionally. Continued use after changes implies acceptance of the revised Terms.

8. **Apple EULA**  
These Terms incorporate Apple’s standard End User License Agreement (EULA), which governs your relationship with Apple. See: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""")

                Divider()

                Text("Privacy Policy")
                    .font(.title2)
                    .bold()

                
                Text("""
                To understand how we handle your personal data, please refer to our separate Privacy Policy available in the app or on our website.
                """)

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
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Legal")
    }
}

#Preview {
    TermsAndConditionsView()
}
