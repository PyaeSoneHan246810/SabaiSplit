//
//  SabaiSplitApp.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI
import SwiftData

@main
struct SabaiSplitApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppStorageKeys.colorMode) private var selectedColorMode: ColorMode = .system
    @State private var iCloudStatusProvider: ICloudStatusProvider = .init()
    var body: some Scene {
        WindowGroup {
            StartingView()
                .preferredColorScheme(selectedColorMode.colorScheme)
                .environment(iCloudStatusProvider)
                .onChange(of: scenePhase) { _, newValue in
                    if newValue == .active {
                        refreshCloudStatus()
                    }
                }
        }
        .modelContainer(for: BillSplit.self)
    }
    private func refreshCloudStatus() {
        Task {
            await iCloudStatusProvider.refreshStatus()
        }
    }
}
