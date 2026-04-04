//
//  HeadlinedSectionView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct HeadlinedSectionView<Content: View>: View {
    let headline: String
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: alignment, spacing: 8.0) {
            Text(headline)
                .font(.headline)
            content
        }
    }
}

#Preview {
    HeadlinedSectionView(headline: "Title") {
        Text("Content")
    }
}
