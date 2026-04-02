//
//  QuickSplitTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QuickSplitTabView: View {
    var body: some View {
        Text("Quick Split Tab View")
            .navigationTitle(Text("Quick Split"))
    }
}

#Preview {
    QuickSplitTabView()
        .wrapsWithNavigationStack()
}
