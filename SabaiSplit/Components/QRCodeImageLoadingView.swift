//
//  QRCodeImageLoadingView.swift
//  SabaiSplit
//
//  Created by Dylan on 2/4/26.
//

import SwiftUI

struct QRCodeImageLoadingView: View {
    let size: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: 12.0)
            .fill(Color(uiColor: .systemGray6))
            .frame(width: size, height: size)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    QRCodeImageLoadingView(size: 250.0)
}
