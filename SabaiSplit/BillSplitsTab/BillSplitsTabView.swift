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
        billSplitsListView
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
    @ViewBuilder
    private var billSplitsListView: some View {
        if billSplits.isEmpty {
            ContentUnavailableView {
                Label("No Bill Splits", systemImage: "person.3.fill")
            } description: {
                Text("Create a bill split to save them here.")
            } actions: {
                Button("Create Bill Split", systemImage: "plus") {
                    isCreateBillSplitSheetPresented = true
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            BillSplitsListView(
                billSplits: billSplits
            )
        }
    }
}

#Preview {
    BillSplitsTabView()
        .wrapsWithNavigationStack()
        .tint(.mint)
}
