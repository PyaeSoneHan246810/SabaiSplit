//
//  BahtTextView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct BahtTextView: View {
    let amount: Double
    var body: some View {
        Text("฿\(amount, format: .number.precision(.fractionLength(2)))")
    }
}

#Preview {
    BahtTextView(amount: 2000.0)
}
