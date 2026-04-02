//
//  QuickSplitTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QuickSplitTabView: View {
    @State private var totalAmount: Double = 0.0
    @State private var totalAmountText: String = ""
    @State private var numberOfPeople: Int = 2
    @State private var tipPercentage: Double = 0.0
    @State private var tipPercentageText: String = ""
    @State private var selectedTipOption: TipOptions = .noTip
    @State private var isOtherTipInputVisiable: Bool = false
    @State private var amountForEachPerson: Double = 0.0
    @State private var qrCodeString: String? = nil
    @State private var qrCodeImage: UIImage? = nil
    @State private var isqrCodeImageGenerated: Bool = false
    @FocusState private var isTotalAmountFocused: Bool
    @FocusState private var isTipPercentageFocused: Bool
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
    private func isTipOptionSelected(_ option: TipOptions) -> Bool {
        option == selectedTipOption
    }
    private enum TipOptions: String, Identifiable, CaseIterable {
        case noTip
        case tip10
        case tip15
        case tip20
        case other
        var id: String { self.rawValue }
        var label: String {
            switch self {
            case .noTip:
                "No tip"
            case .tip10:
                "10%"
            case .tip15:
                "15%"
            case .tip20:
                "20%"
            case .other:
                "Other"
            }
        }
    }
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
                    scanToPayView
                    resetButtonView
                }
            }
        }
        .contentMargins(16.0)
        .scrollIndicators(.hidden)
        .navigationTitle(Text("Quick Split"))
        .onChange(of: totalAmount) {
            calculateAmountForEachPerson()
        }
        .onChange(of: numberOfPeople) {
            calculateAmountForEachPerson()
        }
        .onChange(of: tipPercentage) {
            calculateAmountForEachPerson()
        }
    }
}

private extension QuickSplitTabView {
    var editTotalAmountView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Total Amount")
                .font(.headline)
            HStack(spacing: 16.0) {
                TextField("0.00", text: $totalAmountText)
                    .keyboardType(.decimalPad)
                    .focused($isTotalAmountFocused)
                    .onChange(of: totalAmountText) { _, newValue in
                        if let value = Double(newValue) {
                            totalAmount = value
                        } else if newValue.isEmpty {
                            totalAmount = 0.0
                        }
                    }
                    .onChange(of: isTotalAmountFocused) { _, isFocused in
                        if !isFocused {
                            formatTotalAmount()
                        }
                    }
                Image(systemName: "bahtsign")
            }
            .applyBackgroundStyle(height: 60.0)
        }
    }
    
    var editSplitBetweenView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Split Between")
                .font(.headline)
            Stepper(
                value: $numberOfPeople,
                in: 2...20
            ) {
                HStack {
                    Text("Number of People")
                    Spacer()
                    Text(numberOfPeople, format: .number)
                        .fontWeight(.semibold)
                        .foregroundStyle(.mint)
                }
            }
            .applyBackgroundStyle(height: 60.0)
        }
    }
    
    var editTipPercentageView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Tip Percentage")
                .font(.headline)
            HStack(spacing: 4.0) {
                ForEach(TipOptions.allCases) { tipOption in
                    Text(tipOption.label)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40.0)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground), in: .capsule)
                        .overlay {
                            if isTipOptionSelected(tipOption) {
                                Capsule()
                                    .stroke(Color.mint, lineWidth: 1.0)
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                selectedTipOption = tipOption
                            }
                        }
                }
            }
            if isOtherTipInputVisiable {
                HStack(spacing: 16.0) {
                    TextField("0.0", text: $tipPercentageText)
                        .keyboardType(.decimalPad)
                        .focused($isTipPercentageFocused)
                        .onChange(of: tipPercentageText) { _, newValue in
                            if let value = Double(newValue) {
                                tipPercentage = value
                            } else if newValue.isEmpty {
                                tipPercentage = 0.0
                            }
                        }
                        .onChange(of: isTipPercentageFocused) { _, isFocused in
                            if !isFocused {
                                formatTipPercentage()
                            }
                        }
                    Image(systemName: "percent")
                }
                .applyBackgroundStyle(height: 60.0)
            }
        }
        .onChange(of: selectedTipOption) { _, newOption in
            withAnimation {
                switch newOption {
                case .noTip:
                    tipPercentage = 0.0
                    isOtherTipInputVisiable = false
                case .tip10:
                    tipPercentage = 10.0
                    isOtherTipInputVisiable = false
                case .tip15:
                    tipPercentage = 15.0
                    isOtherTipInputVisiable = false
                case .tip20:
                    tipPercentage = 20.0
                    isOtherTipInputVisiable = false
                case .other:
                    tipPercentage = 0.0
                    isOtherTipInputVisiable = true
                }
            }
        }
    }
    
    var amountForEachPersonView: some View {
        VStack(alignment: .center, spacing: 8.0) {
            Text("Amount For Each Person")
                .font(.headline)
            Text("฿\(amountForEachPerson, format: .number.precision(.fractionLength(2)))")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(.mint)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .applyBackgroundStyle()
    }
    
    var generateQrCodeButtonView: some View {
        Button {
            generateQrCode()
        } label: {
            Label("Generate QR Code", systemImage: "qrcode")
                .applyPrimaryButtonStyle()
        }
        .disabled(totalAmount == 0.0 || amountForEachPerson == 0.0)
        .opacity((totalAmount == 0.0 || amountForEachPerson == 0.0) ? 0.5 : 1.0)
    }
    
    var scanToPayView: some View {
        VStack(spacing: 12.0) {
            Text("Scan PromptPay QR")
                .font(.headline)
            QRCodeImageView(uiImage: qrCodeImage, size: qrCodeImageSize)
            qrCodeInfoView
            Text("Scan this QR code with any Thai banking app.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .applyBackgroundStyle()
    }
    
    var qrCodeInfoView: some View {
        VStack(spacing: 4.0) {
            HStack {
                Text("Phone Number:")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("0617862720")
                    .font(.headline)
            }
            Divider()
            HStack {
                Text("Amount:")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("฿\(amountForEachPerson, format: .number.precision(.fractionLength(2)))")
                    .font(.headline)
                    .foregroundStyle(.mint)
            }
        }
    }
    
    var resetButtonView: some View {
        Button {
            resetCalculation()
        } label: {
            Text("Reset")
                .applyPrimaryDestructiveButtonStyle()
        }
    }
}

private extension QuickSplitTabView {
    func formatTotalAmount() {
        if totalAmount > 0 {
            totalAmountText = String(format: "%.2f", totalAmount)
        } else {
            totalAmountText = ""
        }
    }
    
    func formatTipPercentage() {
        if tipPercentage > 0 {
            tipPercentageText = String(format: "%.1f", tipPercentage)
        } else {
            tipPercentageText = ""
        }
    }
    
    func calculateAmountForEachPerson() {
        let tipAmount = totalAmount * (tipPercentage / 100.0)
        let totalWithTip = totalAmount + tipAmount
        amountForEachPerson = totalWithTip / Double(numberOfPeople)
    }
    
    func generateQrCode() {
        guard totalAmount > 0.0 && amountForEachPerson > 0.0 else {
            return
        }
        withAnimation {
            isqrCodeImageGenerated = false
            qrCodeString = PromptPayQRStringGenerator.generateQRString(
                promptPayPhoneNumber: "0946341761",
                amount: amountForEachPerson
            )
            if let qrCodeString {
                qrCodeImage = qrCodeImageGenerator.generateQRCodeImage(from: qrCodeString, size: qrCodeImageSize)
            }
            isqrCodeImageGenerated = true
        }
    }
    
    func resetCalculation() {
        withAnimation {
            totalAmount = 0.0
            totalAmountText = ""
            numberOfPeople = 2
            tipPercentage = 0.0
            tipPercentageText = ""
            selectedTipOption = .noTip
            isOtherTipInputVisiable = false
            amountForEachPerson = 0.0
            qrCodeString = nil
            qrCodeImage = nil
            isqrCodeImageGenerated = false
        }
    }
}

private extension View {
    @ViewBuilder
    func applyBackgroundStyle(height: CGFloat? = nil) -> some View {
        if let height {
            self
                .padding(16.0)
                .frame(height: height)
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12.0))
        } else {
            self
                .padding(16.0)
                .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12.0))
        }
    }
}

#Preview {
    QuickSplitTabView()
        .wrapsWithNavigationStack()
}
