//
//  StatisticsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct StatisticsTabView: View {
    var body: some View {
        Text("Statistics Tab View")
            .navigationTitle(Text("Statistics"))
    }
}

#Preview {
    StatisticsTabView()
        .wrapsWithNavigationStack()
}
