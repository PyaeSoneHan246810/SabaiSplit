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
    @Query(sort: \BillSplit.date, order: .reverse) private var allBillSplits: [BillSplit]
    @State private var isDeleteAllConfirmationPresented: Bool = false
    @State private var errorMessage: String? = nil
    let filterOption: FilterOption
    var onCreateBillSplit: (() -> Void)?
    private var filteredBillSplits: [BillSplit] {
        switch filterOption {
        case .all:
            allBillSplits
        case .completed:
            allBillSplits.filter { $0.isAllPaid }
        case .inProgress:
            allBillSplits.filter { !$0.isAllPaid }
        }
    }
    private var noBillSplitsTitle: String {
        switch filterOption {
        case .all:
            "No Bill Splits"
        case .completed:
            "No Completed Bill Splits"
        case .inProgress:
            "No Active Bill Splits"
        }
    }
    private var noBillSplitsDesc: String {
        switch filterOption {
        case .all:
            "Create a bill split to save them here."
        case .completed, .inProgress:
            "Create a bill split to get started."
        }
    }
    private var deleteAllMessage: String {
        switch filterOption {
        case .all:
            "Are you sure to delete all bill splits?"
        case .completed:
            "Are you sure to delete all completed bill splits?"
        case .inProgress:
            "Are you sure to delete all active bill splits?"
        }
    }
    var body: some View {
        Group {
            if filteredBillSplits.isEmpty {
                emptyBillSplitsListView
            } else {
                filteredBillSplitsListView
            }
        }
        .alert("Unable to Delete", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private extension BillSplitsListView {
    var emptyBillSplitsListView: some View {
        ContentUnavailableView {
            Label(noBillSplitsTitle, systemImage: "person.3.fill")
        } description: {
            Text(noBillSplitsDesc)
        } actions: {
            if filterOption == .all {
                Button("Create Bill Split", systemImage: "plus") {
                    onCreateBillSplit?()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    var filteredBillSplitsListView: some View {
        List {
            ForEach(filteredBillSplits) { billSplit in
                NavigationLink {
                    BillSplitDetailsView(billSplit: billSplit)
                } label: {
                    BillSplitItemView(billSplit: billSplit)
                }
                .navigationLinkIndicatorVisibility(.hidden)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let billSplit = filteredBillSplits[index]
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
                            do {
                                try deleteAllBillSplit()
                            } catch {
                                errorMessage = "Could not delete all bill splits. Please try again."
                            }
                        }
                    }, message: {
                        Text(deleteAllMessage)
                    }
                )
            }
        }
    }
}

private extension BillSplitsListView {
    func deleteBillSplit(_ billSplit: BillSplit) {
        modelContext.delete(billSplit)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Could not delete this bill split. Please try again."
        }
    }
    func deleteAllBillSplit() throws {
        switch filterOption {
        case .all:
            try modelContext.delete(model: BillSplit.self)
        case .completed, .inProgress:
            filteredBillSplits.forEach { billSplit in
                modelContext.delete(billSplit)
            }
        }
        try modelContext.save()
    }
}

#Preview {
    BillSplitsListView(filterOption: .all)
        .wrapsWithNavigationStack()
        .tint(.mint)
}
