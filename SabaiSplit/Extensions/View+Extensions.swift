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
    func primaryButtonStyle() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60.0)
            .foregroundStyle(.white)
            .background(.mint, in: .capsule)
    }
    func primaryDestructiveButtonStyle() -> some View {
        self
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 60.0)
            .foregroundStyle(.white)
            .background(.pink, in: .capsule)
    }
    @ViewBuilder
    func backgroundCardStyle(height: CGFloat? = nil) -> some View {
        self
            .padding(16.0)
            .frame(height: height)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12.0))
    }
}
