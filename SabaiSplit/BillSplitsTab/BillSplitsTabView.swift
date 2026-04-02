//
//  BillSplitsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct BillSplitsTabView: View {
    var body: some View {
        Text("Bill Splits Tab View")
            .navigationTitle(Text("Bill Splits"))
    }
}

#Preview {
    BillSplitsTabView()
        .wrapsWithNavigationStack()
}
