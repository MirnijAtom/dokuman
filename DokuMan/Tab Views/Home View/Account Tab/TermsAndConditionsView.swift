//
//  TermsAndConditionsView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

// MARK: - TermsAndConditionsView

/// Displays the app's terms, privacy policy, and legal information in a scrollable view.
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
This app stores your documents and personal data (like ID numbers) only on your device. If iCloud sync is enabled, documents will be stored securely in your personal iCloud. We do not collect, track, or share your data.

You are responsible for your content. We provide no warranty for lost or corrupted data.

For full details, see below.
""")
                Divider()
                Text("Terms and Conditions")
                    .font(.title2)
                    .bold()
                Text("""
Last updated: June 17, 2025

1. **Scope**  
These Terms apply to your use of the DokuMan app.

2. **License**  
You may use the app for personal purposes. Redistribution or resale is not allowed.

3. **User Responsibilities**  
You are responsible for the content you store. We do not access or monitor your data.

4. **Limitations of Liability**  
We are not liable for any data loss or damages arising from use of the app.

5. **Modifications**  
We reserve the right to update the Terms at any time.
""")
                Divider()
                Text("Privacy Policy")
                    .font(.title2)
                    .bold()
                Text("""
1. **Data Collection**  
DokuMan does not collect personal data. All data is stored locally or optionally in iCloud under your Apple ID.

2. **Third Parties**  
No data is shared with third parties. The app uses system features (e.g., iCloud, Face ID) under Apple's policies.

3. **Your Rights (GDPR)**  
You have the right to access, correct, or delete your data at any time. Since data is local, this is under your control.

4. **Contact**  
For privacy-related questions, contact: dokumanapp@gmail.com

5. **Changes**  
This policy may be updated. You will be informed in the app if necessary.
""")
                Divider()
                Text("Impressum")
                    .font(.title2)
                    .bold()
                Text("""
Aleksandrs Bertulis  
Dehnhaide 153  
22081 Hamburg 
Germany

Email: aleksandrs.bertulis@gmail.com  
""")
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
