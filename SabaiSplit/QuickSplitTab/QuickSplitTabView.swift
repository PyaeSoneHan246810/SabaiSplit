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
    @State private var qrCodeImage: UIImage? = nil
    @State private var isQRCodeImageGenerated: Bool = false
    @State private var isPromptPayNumberEditSheetPresented: Bool = false
    @State private var currentQRCodePromptPayNumber: String? = nil
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
                if isQRCodeImageGenerated {
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
        .sheet(isPresented: $isPromptPayNumberEditSheetPresented) {
            EditPromptPayPhoneNumberView(
                isViewPresented: $isPromptPayNumberEditSheetPresented,
                promptPayPhoneNumber: $promptPayPhoneNumber,
                onSave: {
                    generateQrCodeImage()
                }
            )
            .wrapsWithNavigationStack()
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
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
            BahtTextView(amount: amountPerPerson)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .backgroundCardStyle()
    }
    
    var generateQrCodeButtonView: some View {
        Button {
            generateQrCodeImage()
        } label: {
            Label("Generate QR Code", systemImage: "qrcode")
                .primaryButtonStyle()
        }
        .disabled(totalAmount == 0.0 || amountPerPerson == 0.0)
        .opacity((totalAmount == 0.0 || amountPerPerson == 0.0) ? 0.5 : 1.0)
    }
    
    var scanToPayView: some View {
        ScanToPayView(
            qrCodeImage: qrCodeImage,
            qrCodeImageSize: qrCodeImageSize,
            promptPayPhoneNumber: currentQRCodePromptPayNumber ?? "-",
            amount: amountPerPerson
        )
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
    
    func generateQrCodeImage() {
        guard let promptPayPhoneNumber else {
            isPromptPayNumberEditSheetPresented = true
            return
        }
        withAnimation {
            isQRCodeImageGenerated = false
            currentQRCodePromptPayNumber = promptPayPhoneNumber
            let qrCodeString = PromptPayQRStringGenerator.generateQRString(
                promptPayPhoneNumber: promptPayPhoneNumber,
                amount: amountPerPerson
            )
            if let qrCodeString {
                let amountText = "฿\(String(format: "%.2f", amountPerPerson))"
                qrCodeImage = qrCodeImageGenerator.generateQRCodeImage(from: qrCodeString, size: qrCodeImageSize, bottomText: amountText)
            }
            isQRCodeImageGenerated = true
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
            qrCodeImage = nil
            isQRCodeImageGenerated = false
            currentQRCodePromptPayNumber = nil
        }
    }
}

#Preview {
    QuickSplitTabView()
        .wrapsWithNavigationStack()
        .tint(.mint)
}
