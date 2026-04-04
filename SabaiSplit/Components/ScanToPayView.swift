//
//  ScanToPayView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct ScanToPayView: View {
    let qrCodeImage: UIImage?
    let qrCodeImageSize: CGFloat
    let promptPayPhoneNumber: String?
    let amount: Double
    var body: some View {
        VStack(spacing: 12.0) {
            Text("Scan PromptPay QR Code")
                .font(.headline)
            QRCodeImageView(uiImage: qrCodeImage, size: qrCodeImageSize)
            VStack(spacing: 4.0) {
                HStack {
                    Text("PromptPay Phone Number:")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let promptPayPhoneNumber {
                        Text(promptPayPhoneNumber)
                            .font(.headline)
                    }
                }
                Divider()
                HStack {
                    Text("Amount:")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    BahtTextView(amount: amount)
                        .font(.headline)
                        .foregroundStyle(.mint)
                }
            }
            Text("Scan this QR code with any Thai banking app.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .backgroundCardStyle()
    }
}
