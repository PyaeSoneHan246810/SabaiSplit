//
//  RootTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Quick Split", systemImage: "qrcode") {
                QuickSplitTabView()
                    .wrapsWithNavigationStack()
            }
            Tab("Bill Splits", systemImage: "person.3") {
                BillSplitsTabView()
                    .wrapsWithNavigationStack()
            }
            Tab("Statistics", systemImage: "chart.bar") {
                StatisticsTabView()
                    .wrapsWithNavigationStack()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsTabView()
                    .wrapsWithNavigationStack()
            }
        }
        .tint(.mint)
    }
}

#Preview {
    RootTabView()
}
