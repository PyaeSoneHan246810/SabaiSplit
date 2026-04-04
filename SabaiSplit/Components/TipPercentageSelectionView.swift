//
//  TipOptionSelectionView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct TipPercentageSelectionView: View {
    @Binding var selectedTipOption: TipOption
    @Binding var tipPercentage: Double
    @Binding var tipPercentageText: String
    @State private var isOtherTipInputVisiable: Bool = false
    @FocusState private var isTipPercentageFocused: Bool
    private func isTipOptionSelected(_ option: TipOption) -> Bool {
        option == selectedTipOption
    }
    var body: some View {
        VStack(spacing: 8.0) {
            HStack(spacing: 4.0) {
                ForEach(TipOption.allCases) { tipOption in
                    Text(tipOption.label)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40.0)
                        .background(Color(uiColor: .secondarySystemBackground), in: .capsule)
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
                .backgroundCardStyle(height: 60.0)
            }
        }
        .onChange(of: selectedTipOption) { _, newOption in
            withAnimation {
                switch newOption {
                case .noTip:
                    tipPercentage = 0.0
                    tipPercentageText = ""
                    isOtherTipInputVisiable = false
                case .tip10:
                    tipPercentage = 10.0
                    tipPercentageText = ""
                    isOtherTipInputVisiable = false
                case .tip15:
                    tipPercentage = 15.0
                    tipPercentageText = ""
                    isOtherTipInputVisiable = false
                case .tip20:
                    tipPercentage = 20.0
                    tipPercentageText = ""
                    isOtherTipInputVisiable = false
                case .other:
                    tipPercentage = 0.0
                    tipPercentageText = ""
                    isOtherTipInputVisiable = true
                }
            }
        }
    }
    private func formatTipPercentage() {
        if tipPercentage > 0 {
            tipPercentageText = String(format: "%.1f", tipPercentage)
        } else {
            tipPercentageText = ""
        }
    }
}

#Preview {
    TipPercentageSelectionView(
        selectedTipOption: .constant(.noTip),
        tipPercentage: .constant(0.0),
        tipPercentageText: .constant("")
    )
}
