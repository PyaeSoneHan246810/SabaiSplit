//
//  QuickSplitTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QuickSplitTabView: View {
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    @State private var totalAmount: Double = 0.0
    @State private var totalAmountText: String = ""
    @State private var numberOfPeople: Int = 2
    @State private var selectedTipOption: TipOption = .noTip
    @State private var tipPercentage: Double = 0.0
    @State private var tipPercentageText: String = ""
    @State private var amountPerPerson: Double = 0.0
    @State private var qrCodeString: String? = nil
    @State private var qrCodeImage: UIImage? = nil
    @State private var isqrCodeImageGenerated: Bool = false
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 32.0) {
                VStack(spacing: 20.0) {
                    editTotalAmountView
                    editSplitBetweenView
                    editTipPercentageView
                    amountForEachPersonView
                    generateQrCodeButtonView
                }
                if isqrCodeImageGenerated {
                    VStack(spacing: 20.0) {
                        scanToPayView
                        resetButtonView
                    }
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Quick Split"))
        .onChange(of: totalAmount) {
            calculateAmountPerPerson()
        }
        .onChange(of: numberOfPeople) {
            calculateAmountPerPerson()
        }
        .onChange(of: tipPercentage) {
            calculateAmountPerPerson()
        }
    }
}

private extension QuickSplitTabView {
    var editTotalAmountView: some View {
        HeadlinedSectionView(headline: "Total Amount") {
            TotalAmountTextFieldView(
                totalAmount: $totalAmount,
                totalAmountText: $totalAmountText
            )
        }
    }
    
    var editSplitBetweenView: some View {
        HeadlinedSectionView(headline: "Split Between") {
            NumberOfPeopleStepperView(
                numberOfPeople: $numberOfPeople
            )
        }
    }
    
    var editTipPercentageView: some View {
        HeadlinedSectionView(headline: "Tip Percentage") {
            TipPercentageSelectionView(
                selectedTipOption: $selectedTipOption,
                tipPercentage: $tipPercentage,
                tipPercentageText: $tipPercentageText
            )
        }
    }
    
    var amountForEachPersonView: some View {
        HeadlinedSectionView(headline: "Amount For Each Person", alignment: .center) {
            Text("฿\(amountPerPerson, format: .number.precision(.fractionLength(2)))")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .backgroundCardStyle()
    }
    
    var generateQrCodeButtonView: some View {
        Button {
            generateQrCode()
        } label: {
            Label("Generate QR Code", systemImage: "qrcode")
                .primaryButtonStyle()
        }
        .disabled(totalAmount == 0.0 || amountPerPerson == 0.0)
        .opacity((totalAmount == 0.0 || amountPerPerson == 0.0) ? 0.5 : 1.0)
    }
    
    var scanToPayView: some View {
        VStack(spacing: 12.0) {
            Text("Scan PromptPay QR Code")
                .font(.headline)
            QRCodeImageView(uiImage: qrCodeImage, size: qrCodeImageSize)
            VStack(spacing: 4.0) {
                HStack {
                    Text("Prompt Pay Phone Number:")
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
                    Text("฿\(amountPerPerson, format: .number.precision(.fractionLength(2)))")
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
    
    var resetButtonView: some View {
        Button {
            resetCalculation()
        } label: {
            Text("Reset")
                .primaryDestructiveButtonStyle()
        }
    }
}

private extension QuickSplitTabView {
    
    func calculateAmountPerPerson() {
        let tipAmount = totalAmount * (tipPercentage / 100.0)
        let totalWithTip = totalAmount + tipAmount
        amountPerPerson = totalWithTip / Double(numberOfPeople)
    }
    
    func generateQrCode() {
        guard let promptPayPhoneNumber else { return }
        guard totalAmount > 0.0 && amountPerPerson > 0.0 else {
            return
        }
        withAnimation {
            isqrCodeImageGenerated = false
            qrCodeString = PromptPayQRStringGenerator.generateQRString(
                promptPayPhoneNumber: promptPayPhoneNumber,
                amount: amountPerPerson
            )
            if let qrCodeString {
                let amountText = "฿\(String(format: "%.2f", amountPerPerson))"
                qrCodeImage = qrCodeImageGenerator.generateQRCodeImage(from: qrCodeString, size: qrCodeImageSize, bottomText: amountText)
            }
            isqrCodeImageGenerated = true
        }
    }
    
    func resetCalculation() {
        withAnimation {
            totalAmount = 0.0
            totalAmountText = ""
            numberOfPeople = 2
            selectedTipOption = .noTip
            tipPercentage = 0.0
            tipPercentageText = ""
            amountPerPerson = 0.0
            qrCodeString = nil
            qrCodeImage = nil
            isqrCodeImageGenerated = false
        }
    }
}

#Preview {
    QuickSplitTabView()
        .wrapsWithNavigationStack()
}
