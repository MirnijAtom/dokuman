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
DokuMan stores your documents and personal data (such as ID numbers) exclusively on your device. If iCloud sync is enabled, your data is securely stored in your personal iCloud account. We do not collect, track, or share your information.

You are fully responsible for your stored content. We provide no warranty regarding data loss or corruption.

See full details below.
""")
                
                Divider()
                
                Text("Terms and Conditions")
                    .font(.title2)
                    .bold()
                
                Text("""
Last updated: June 17, 2025

1. **Scope**  
These Terms govern your use of the DokuMan app.

2. **License**  
You may use the app for personal purposes only. Redistribution, resale, or commercial use is prohibited.

3. **User Responsibilities**  
You are responsible for the accuracy, legality, and safety of your stored content. We do not access or monitor your data.

4. **Limitation of Liability**  
DokuMan and its developers are not liable for any data loss, damage, or other issues resulting from app use.

5. **Modifications**  
We may update these Terms at any time. Continued use of the app implies acceptance of the updated Terms.
""")
                
                Divider()
                
                Text("Privacy Policy")
                    .font(.title2)
                    .bold()
                
                Text("""
1. **Data Collection**  
DokuMan does not collect personal data. All documents and personal information are stored locally on your device or optionally in your iCloud account.

2. **Third-Party Services**  
The app uses system services such as iCloud and Face ID according to Apple's privacy policies. No personal data is shared with third parties.

3. **Your Rights (GDPR)**  
You have full control over your data, including rights to access, correct, or delete it, as data is stored locally or in your personal iCloud.

4. **Contact**  
For privacy questions, please email:  
dokumanapp at gmail dot com

5. **Policy Changes**  
We may update this policy occasionally. Important changes will be communicated within the app.

6. **Lifetime Access**  
If you purchase a lifetime access subscription, you are granted unlimited use of the app's features for the duration of the app's availability. However, this does not guarantee indefinite availability of the app or its services. The developer reserves the right to modify, suspend, or terminate the app or services at any time without prior notice. No refunds will be issued in such cases.
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
                .textSelection(.enabled) // Optional: allow copy without link
                
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
