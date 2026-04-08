//
//  WelcomeView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var savedPromptPayPhoneNumber: String?
    @State private var promptPayPhoneNumber: String = ""
    private var isPromptPayPhoneNumberValid: Bool {
        PromptPayQRStringGenerator.formatPhoneNumber(promptPayPhoneNumber) != nil
    }
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 32.0) {
                welcomeSectionView
                setPromptPayPhoneNumberView
                buttonsView
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .tint(.mint)
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
            Text("Split and track bills easily, and get instant PromptPay QR codes.")
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    var setPromptPayPhoneNumberView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Set PromptPay Phone Number")
                .font(.headline)
            TextField("Enter your number", text: $promptPayPhoneNumber)
                .keyboardType(.phonePad)
                .backgroundCardStyle(height: 60.0)
            if !promptPayPhoneNumber.isEmpty && !isPromptPayPhoneNumberValid {
                Text("Please enter a valid 10-digit Thai phone number starting with 0")
                    .font(.caption)
                    .foregroundStyle(.pink)
            }
        }
    }
    var buttonsView: some View {
        VStack(spacing: 12.0) {
            Button {
                savedPromptPayPhoneNumber = promptPayPhoneNumber
                hasCompletedOnboarding = true
            } label: {
                Text("Save")
                    .primaryButtonStyle()
            }
            .disabled(!isPromptPayPhoneNumberValid)
            Button("Skip for now") {
                savedPromptPayPhoneNumber = nil
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    WelcomeView()
}
