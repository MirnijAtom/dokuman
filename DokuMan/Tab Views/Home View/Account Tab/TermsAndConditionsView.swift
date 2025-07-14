//
//  TermsAndConditionsView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

struct TermsAndConditionsView: View {
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
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Legal")
    }
}

#Preview {
    TermsAndConditionsView()
}
