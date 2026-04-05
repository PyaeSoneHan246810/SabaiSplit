//
//  BillSplitsListView.swift
//  SabaiSplit
//
//  Created by Dylan on 5/4/26.
//

import SwiftUI
import SwiftData

struct BillSplitsListView: View {
    @Environment(\.modelContext) private var modelContext
    let billSplits: [BillSplit]
    @State private var isDeleteAllConfirmationPresented: Bool = false
    var body: some View {
        List {
            ForEach(billSplits) { billSplit in
                NavigationLink {
                    BillSplitDetailsView(billSplit: billSplit)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Delete All", systemImage: "trash", role: .destructive) {
                    isDeleteAllConfirmationPresented = true
                }
                .tint(.pink)
                .alert(
                    "Delete All",
                    isPresented: $isDeleteAllConfirmationPresented,
                    actions: {
                        Button("Confirm", role: .destructive) {
                            deleteAllBillSplit()
                        }
                    }, message: {
                        Text("Are you sure to delete all of the bill splits here?")
                    }
                )
            }
        }
    }
    private func deleteBillSplit(_ billSplit: BillSplit) {
        modelContext.delete(billSplit)
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    private func deleteAllBillSplit() {
        billSplits.forEach { billSplit in
            modelContext.delete(billSplit)
        }
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    BillSplitsListView(billSplits: [BillSplit.sample])
        .wrapsWithNavigationStack()
        .tint(.mint)
}
