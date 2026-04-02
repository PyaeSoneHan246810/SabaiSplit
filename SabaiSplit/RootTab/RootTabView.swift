//
//  RootTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct RootTabView: View {
    @AppStorage(AppStorageKeys.promptPayPhoneNumber) private var promptPayPhoneNumber: String?
    @State private var isAddNumberSheetPresented: Bool = false
    var body: some View {
        mainTabView
        .onAppear {
            isAddNumberSheetPresented = promptPayPhoneNumber == nil
        }
        .onChange(of: promptPayPhoneNumber) { _, newValue in
            isAddNumberSheetPresented = newValue == nil
        }
        .sheet(isPresented: $isAddNumberSheetPresented) {
            WelcomeView()
        }
    }
}

private extension RootTabView {
    var mainTabView: some View {
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
