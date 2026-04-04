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
    @AppStorage(AppStorageKeys.colorMode) private var selectedColorMode: ColorMode = .system
    var body: some Scene {
        WindowGroup {
            StartingView()
                .preferredColorScheme(selectedColorMode.colorScheme)
        }
        .modelContainer(for: BillSplit.self)
    }
}
