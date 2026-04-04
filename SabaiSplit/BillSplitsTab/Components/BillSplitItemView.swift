//
//  BillSplitItemView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct BillSplitItemView: View {
    let billSplit: BillSplit
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12.0) {
                Text(billSplit.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                BahtTextView(amount: billSplit.totalAmountIncludingTip)
                    .foregroundStyle(.mint)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12.0) {
                Text("\(billSplit.ratio) paid")
                ProgressView(
                    value: Double(billSplit.numberOfPaidPerson),
                    total: Double(billSplit.numberOfPerson)
                )
                .progressViewStyle(.linear)
                if billSplit.isAllPaid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

#Preview {
    BillSplitItemView(
        billSplit: BillSplit.sample
    )
    .tint(.mint)
}
