//
//  RootTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct RootTabView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false
    @State private var isWelcomeSheetPresented: Bool = false
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
        .onAppear {
            isWelcomeSheetPresented = !hasCompletedOnboarding
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            isWelcomeSheetPresented = !hasCompletedOnboarding
        }
        .sheet(isPresented: $isWelcomeSheetPresented) {
            WelcomeView()
                .wrapsWithNavigationStack()
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    RootTabView()
}
