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
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20.0) {
                ScanToPayView(
                    qrCodeImage: qrCodeImage,
                    qrCodeImageSize: qrCodeImageSize,
                    promptPayPhoneNumber: promptPayPhoneNumber ?? "-",
                    amount: unpaidPerson.amount
                )
                Button {
                    unpaidPerson.hasPaid = true
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Label("Mark as paid", systemImage: "checkmark")
                        .primaryButtonStyle()
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .navigationTitle(unpaidPerson.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    dismiss()
                }
            }
        }
        .onAppear {
            qrCodeImage = generateQrCodeImage(amount: unpaidPerson.amount)
        }
    }
}

private extension UnpaidPersonDetailsView {
    func generateQrCodeImage(amount: Double) -> UIImage? {
        guard let promptPayPhoneNumber else { return nil }
        guard amount > 0.0 else { return nil }
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
        unpaidPerson: BillSplit.sample.personList.first!
    )
    .tint(.mint)
}
