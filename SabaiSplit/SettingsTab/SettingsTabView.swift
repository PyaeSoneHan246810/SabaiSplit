//
//  SettingsTabView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        Text("Settings Tab View")
            .navigationTitle(Text("Settings"))
    }
}

#Preview {
    SettingsTabView()
        .wrapsWithNavigationStack()
}
