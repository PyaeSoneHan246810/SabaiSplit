//
//  BillSplitsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct BillSplitsTabView: View {
    @State private var isCreateBillSplitSheetPresented: Bool = false
    var body: some View {
        Text("Bill Splits Tab View")
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
}
