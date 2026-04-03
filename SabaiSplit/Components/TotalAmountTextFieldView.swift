//
//  TotalAmountTextFieldView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct TotalAmountTextFieldView: View {
    @Binding var totalAmount: Double
    @Binding var totalAmountText: String
    @FocusState private var isTotalAmountFocused: Bool
    var body: some View {
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
        .backgroundCardStyle(height: 60.0)
    }
    private func formatTotalAmount() {
        if totalAmount > 0 {
            totalAmountText = String(format: "%.2f", totalAmount)
        } else {
            totalAmountText = ""
        }
    }
}

#Preview {
    TotalAmountTextFieldView(
        totalAmount: .constant(0.0),
        totalAmountText: .constant("")
    )
}
