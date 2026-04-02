//
//  WelcomeView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var savedPromptPayPhoneNumber: String?
    @State private var promptPayPhoneNumber: String = ""
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 32.0) {
                welcomeSectionView
                setPromptPayPhoneNumberView
                saveButtonView
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }
}

private extension WelcomeView {
    var welcomeSectionView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("👋")
                .font(.system(size: 40.0))
            Text("Welcome to Sabai Split")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.mint.gradient)
            Text("Quick bill splits, instant PromptPay QR codes, and tracking made easy.")
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    var isPhoneNumberValid: Bool {
        PromptPayQRStringGenerator.formatPhoneNumber(promptPayPhoneNumber) != nil
    }
    var setPromptPayPhoneNumberView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Set Prompt Pay Phone Number")
                .font(.headline)
            TextField("Enter your number", text: $promptPayPhoneNumber)
                .keyboardType(.phonePad)
                .applyBackgroundStyle(height: 60.0)
            if !promptPayPhoneNumber.isEmpty && !isPhoneNumberValid {
                Text("Please enter a valid 10-digit Thai phone number starting with 0")
                    .font(.caption)
                    .foregroundStyle(.pink)
            }
        }
    }
    var saveButtonView: some View {
        Button {
            savedPromptPayPhoneNumber = promptPayPhoneNumber
        } label: {
            Label("Save", systemImage: "")
                .applyPrimaryButtonStyle()
        }
        .disabled(!isPhoneNumberValid)
    }
}

#Preview {
    WelcomeView()
}
