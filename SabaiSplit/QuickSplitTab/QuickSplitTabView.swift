//
//  QuickSplitTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QuickSplitTabView: View {
    @State private var totalAmount: Double = 0.0
    @State private var numberOfPeople: Int = 2
    @State private var tipPercentage: Double = 0.0
    @State private var selectedTipOption: TipOptions = .noTip
    @State private var isOtherTipInputVisiable: Bool = false
    @State private var amountForEachPerson: Double = 0.0
    @State private var qrCodeString: String? = nil
    @State private var qrCodeImage: UIImage? = nil
    @State private var isqrCodeImageGenerated: Bool = false
    private let qrCodeImageGenerator = QrCodeImageGenerator()
    private let qrCodeImageSize: CGFloat = 300.0
    private func isTipOptionSelected(_ option: TipOptions) -> Bool {
        option == selectedTipOption
    }
    private let totalAmountNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }()
    private let tipPercentageNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.zeroSymbol = ""
        return formatter
    }()
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
    }
}

private extension QuickSplitTabView {
    var editTotalAmountView: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Total Amount")
                .font(.headline)
            HStack(spacing: 16.0) {
                TextField(
                    "0.00",
                    value: $totalAmount,
                    formatter: totalAmountNumberFormatter
                )
                .keyboardType(.decimalPad)
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
            Text("Tip Amount")
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
                    TextField("0.0", value: $tipPercentage, formatter: tipPercentageNumberFormatter)
                    .keyboardType(.decimalPad)
                    Image(systemName: "percent")
                }
                .applyBackgroundStyle(height: 60.0)
            }
        }
        .onChange(of: selectedTipOption) { oldOption, newOption in
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
            
        } label: {
            Text("Reset")
                .applyPrimaryDestructiveButtonStyle()
        }
    }
}

private extension QuickSplitTabView {
    func generateQrCode() {
        withAnimation {
            isqrCodeImageGenerated = false
            if let qrString = PromptPayQRStringGenerator.generateQRString(
                promptPayPhoneNumber: "0946341761",
                amount: amountForEachPerson
            ) {
                qrCodeImage = qrCodeImageGenerator.generateQRCodeImage(from: qrString, size: qrCodeImageSize)
            }
            isqrCodeImageGenerated = true
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
