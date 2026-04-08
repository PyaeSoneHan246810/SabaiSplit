//
//  EditPromptPayPhoneNumberView.swift
//  SabaiSplit
//
//  Created by Dylan on 8/4/26.
//

import SwiftUI

struct EditPromptPayPhoneNumberView: View {
    @Binding var isViewPresented: Bool
    @Binding var promptPayPhoneNumber: String?
    var onSave: (() -> Void)?
    @State private var newPromptPayPhoneNumber: String = ""
    private var isPromptPayPhoneNumberValid: Bool {
        PromptPayQRStringGenerator.formatPhoneNumber(newPromptPayPhoneNumber) != nil
    }
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 16.0) {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Edit PromptPay Phone Number")
                        .font(.headline)
                    TextField("Enter your number", text: $newPromptPayPhoneNumber)
                        .keyboardType(.phonePad)
                        .backgroundCardStyle(height: 60.0)
                    if !newPromptPayPhoneNumber.isEmpty && !isPromptPayPhoneNumberValid {
                        Text("Please enter a valid 10-digit Thai phone number starting with 0")
                            .font(.caption)
                            .foregroundStyle(.pink)
                    }
                }
                Button {
                    promptPayPhoneNumber = newPromptPayPhoneNumber
                    isViewPresented = false
                    onSave?()
                } label: {
                    Text("Save")
                        .primaryButtonStyle()
                }
                .disabled(!isPromptPayPhoneNumberValid)
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    isViewPresented = false
                }
            }
        }
        .onAppear {
            newPromptPayPhoneNumber = promptPayPhoneNumber ?? ""
        }
    }
}

#Preview {
    EditPromptPayPhoneNumberView(
        isViewPresented: .constant(true),
        promptPayPhoneNumber: .constant(nil)
    )
}
