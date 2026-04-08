//
//  FilteredBillSplitsView.swift
//  SabaiSplit
//
//  Created by Dylan on 5/4/26.
//

import SwiftUI
import SwiftData

struct FilteredBillSplitsView: View {
    let filterOption: FilterOption
    private var navigationTitle: String {
        switch filterOption {
        case .all:
            "All Bill Splits"
        case .completed:
            "Completed Bill Splits"
        case .inProgress:
            "Active Bill Splits"
        }
    }
    var body: some View {
        BillSplitsListView(filterOption: filterOption)
        .navigationTitle(Text(navigationTitle))
    }
}

#Preview {
    FilteredBillSplitsView(
        filterOption: .completed
    )
    .wrapsWithNavigationStack()
    .tint(.mint)
}
