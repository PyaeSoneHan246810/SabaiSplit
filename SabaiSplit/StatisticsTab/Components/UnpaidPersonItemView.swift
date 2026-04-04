//
//  UnpaidPersonItemView.swift
//  SabaiSplit
//
//  Created by Dylan on 4/4/26.
//

import SwiftUI

struct UnpaidPersonItemView: View {
    let person: Person
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if let billSplit = person.billSplit {
                    Text(billSplit.title)
                        .font(.footnote)
                }
            }
            Spacer()
            BahtTextView(amount: person.amount)
                .font(.headline)
                .foregroundStyle(.pink)
        }
        .backgroundCardStyle()
    }
}

#Preview {
    UnpaidPersonItemView(person: BillSplit.sample.nonNilPersonList.first!)
}
