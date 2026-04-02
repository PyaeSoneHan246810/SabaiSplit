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
    func applyPrimaryButtonStyle() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60.0)
            .foregroundStyle(.white)
            .background(.mint, in: .capsule)
    }
    func applyPrimaryDestructiveButtonStyle() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60.0)
            .foregroundStyle(.white)
            .background(.pink, in: .capsule)
    }
}
