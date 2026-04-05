//
//  FilteredBillSplitsView.swift
//  SabaiSplit
//
//  Created by Dylan on 5/4/26.
//

import SwiftUI
import SwiftData

struct FilteredBillSplitsView: View {
    @Query(sort: \BillSplit.date, order: .reverse) private var allBillSplits: [BillSplit]
    let filterOption: FilterOption
    private var filteredBillSplits: [BillSplit] {
        allBillSplits.filter {
            switch filterOption {
            case .completed:
                $0.isAllPaid
            case .inProgress:
                !$0.isAllPaid
            }
        }
    }
    private var navigationTitle: String {
        switch filterOption {
        case .completed:
            "Completed Bill Splits"
        case .inProgress:
            "Active Bill Splits"
        }
    }
    var body: some View {
        Group {
            if filteredBillSplits.isEmpty {
                ContentUnavailableView {
                    Label("No Bill Splits", systemImage: "person.3.fill")
                } description: {
                    Text("Create a bill split to get started.")
                }
            } else {
                BillSplitsListView(
                    billSplits: filteredBillSplits
                )
            }
        }
        .navigationTitle(Text(navigationTitle))
    }
}

enum FilterOption: String, Identifiable {
    case completed
    case inProgress
    var id: String {
        self.rawValue
    }
}

#Preview {
    FilteredBillSplitsView(
        filterOption: .completed
    )
    .wrapsWithNavigationStack()
    .tint(.mint)
}
