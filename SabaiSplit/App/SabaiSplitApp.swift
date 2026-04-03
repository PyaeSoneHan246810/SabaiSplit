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
    var body: some Scene {
        WindowGroup {
            StartingView()
        }
        .modelContainer(for: BillSplit.self)
    }
}
