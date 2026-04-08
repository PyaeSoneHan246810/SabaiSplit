//
//  BillSplitsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import SwiftData

struct BillSplitsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BillSplit.date, order: .reverse) private var billSplits: [BillSplit]
    @State private var isCreateBillSplitSheetPresented: Bool = false
    var body: some View {
        BillSplitsListView(
            filterOption: .all,
            onCreateBillSplit: {
                isCreateBillSplitSheetPresented = true
            }
        )
        .navigationTitle(Text("Bill Splits"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Create", systemImage: "plus") {
                    isCreateBillSplitSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isCreateBillSplitSheetPresented) {
            CreateBillSplitView()
                .wrapsWithNavigationStack()
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    BillSplitsTabView()
        .wrapsWithNavigationStack()
        .tint(.mint)
}
