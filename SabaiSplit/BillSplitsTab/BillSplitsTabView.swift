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
        List {
            ForEach(billSplits) { billSplit in
                NavigationLink {
                    
                } label: {
                    BillSplitItemView(billSplit: billSplit)
                }
                .navigationLinkIndicatorVisibility(.hidden)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let billSplit = billSplits[index]
                    deleteBillSplit(billSplit)
                }
            }
        }
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

private extension BillSplitsTabView {
    func deleteBillSplit(_ billSplit: BillSplit) {
        modelContext.delete(billSplit)
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    BillSplitsTabView()
        .wrapsWithNavigationStack()
}
