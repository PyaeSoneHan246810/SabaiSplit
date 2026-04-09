//
//  UnpaidPersonDetailsView.swift
//  SabaiSplit
//
//  Created by Dylan on 4/4/26.
//

import SwiftUI
import SwiftData

struct UnpaidPersonDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    let unpaidPerson: Person
    @State private var qrCodeImage: UIImage? = nil
    @State private var isPromptPayNumberEditSheetPresented: Bool = false
    @State private var errorMessage: String? = nil
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                if let promptPayPhoneNumber {
                    ScanToPayView(
                        qrCodeImage: qrCodeImage,
                        qrCodeImageSize: qrCodeImageSize,
                        promptPayPhoneNumber: promptPayPhoneNumber,
                        amount: unpaidPerson.amount
                    )
                } else {
                    if let billSplitTitle = unpaidPerson.billSplit?.title {
                        HStack {
                            Text(billSplitTitle)
                                .font(.headline)
                            Spacer()
                            BahtTextView(amount: unpaidPerson.amount)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.pink)
                        }
                    }
                    ContentUnavailableView {
                        Label("Prompt Pay QR Code Unavailable", systemImage: "qrcode")
                    } description: {
                        Text("Please add your PromptPay phone number to generate the QR code.")
                    } actions: {
                        Button("Add number") {
                            isPromptPayNumberEditSheetPresented = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                Button {
                    unpaidPerson.hasPaid = true
                    unpaidPerson.paidDate = Date()
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        unpaidPerson.hasPaid = false
                        unpaidPerson.paidDate = nil
                        errorMessage = "Could not mark as paid. Please try again."
                    }
                } label: {
                    Label("Mark as paid", systemImage: "checkmark")
                        .primaryButtonStyle()
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .navigationTitle(Text(unpaidPerson.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isPromptPayNumberEditSheetPresented) {
            EditPromptPayPhoneNumberView(
                isViewPresented: $isPromptPayNumberEditSheetPresented,
                promptPayPhoneNumber: $promptPayPhoneNumber,
                onSave: {
                    qrCodeImage = generateQrCodeImage(amount: unpaidPerson.amount)
                }
            )
            .wrapsWithNavigationStack()
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
        }
        .onAppear {
            qrCodeImage = generateQrCodeImage(amount: unpaidPerson.amount)
        }
        .alert("Something Went Wrong", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private extension UnpaidPersonDetailsView {
    func generateQrCodeImage(amount: Double) -> UIImage? {
        guard let promptPayPhoneNumber else {
            isPromptPayNumberEditSheetPresented = true
            return nil
        }
        guard let qrCodeString = PromptPayQRStringGenerator.generateQRString(
            promptPayPhoneNumber: promptPayPhoneNumber,
            amount: amount
        ) else { return nil }
        let amountText = "฿\(String(format: "%.2f", amount))"
        return qrCodeImageGenerator.generateQRCodeImage(
            from: qrCodeString,
            size: qrCodeImageSize,
            bottomText: amountText
        )
    }
}

#Preview {
    UnpaidPersonDetailsView(
        unpaidPerson: BillSplit.sample.nonNilPersonList[0]
    )
    .tint(.mint)
}
