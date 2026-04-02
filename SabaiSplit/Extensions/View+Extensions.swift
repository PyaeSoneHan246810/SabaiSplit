//
//  View+Extensions.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

extension View {
    func wrapsWithNavigationStack() -> some View {
        NavigationStack {
            self
        }
    }
}
