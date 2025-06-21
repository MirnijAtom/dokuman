//
//  PrivacyPolicyView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                Text("""
                Your privacy is important to us. This app collects and uses personal data only to provide its features and improve user experience.

                **Data Collection:**
                - We do not collect personal data unless you explicitly provide it (e.g., via form inputs).
                - Documents and data stay on your device; we don’t upload or share them.
                
                **Data Usage:**
                - Data is used only locally in the app.
                - No tracking, no third-party analytics.

                **Security:**
                - We implement reasonable measures to protect your data.
                - You can enable Face ID / passcode lock for additional security.

                **Your Rights:**
                - You can delete your data anytime.
                - You can contact us at [your email].

                **Legal Basis:**
                - Processing your data is based on your consent and necessity to provide app services.

                **Changes:**
                - We may update this policy; please review regularly.
                """)
                .font(.body)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    PrivacyPolicyView()
}
