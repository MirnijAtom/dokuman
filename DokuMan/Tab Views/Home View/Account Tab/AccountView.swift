//
//  AccountView.swift
//  DokuMan
//
//  Created by Aleksandrs Bertulis on 21.06.25.
//

import SwiftData
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var themeSettings: ThemeSettings
    @EnvironmentObject var languageSettings: LanguageSettings
    
    @State private var showPrivacyPolicy = false
    @State private var showTermsAndConditions = false
    @State private var showStorageInfo = false

    
    var body: some View {
        List {
            Section {
                Toggle(LocalizedStringKey("Dark mode"), isOn: $themeSettings.isDarkMode)
                    .toggleStyle(.switch)
                
                HStack {
                    Text(LocalizedStringKey("Language"))
                    
                    Spacer()
                    
                    Button {
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
                    showStorageInfo.toggle()
                }
                .foregroundStyle(.primary)

            }
            

            
            Section {
                Text(LocalizedStringKey("Upgrade to Pro"))
                Text(LocalizedStringKey("Manage Subscription"))
            }
            
            Section {
                Button(LocalizedStringKey("Privacy Policy")) {
                    showPrivacyPolicy = true
                }
                .foregroundStyle(.primary)
                Button(LocalizedStringKey("Terms & Conditions")) {
                    showTermsAndConditions = true
                }
                .foregroundStyle(.primary)
            }
            

            Section {
                
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
    }
}

#Preview {
    AccountView()
}
