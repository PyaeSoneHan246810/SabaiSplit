//
//  StatisticCardView.swift
//  SabaiSplit
//
//  Created by Dylan on 4/4/26.
//

import SwiftUI

struct StatisticCardView: View {
    let title: String
    let label: String
    let titleColor: Color
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(titleColor)
            Text(label)
                .font(.footnote)
        }
        .padding(10.0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12.0))
    }
}

#Preview {
    StatisticCardView(
        title: "12",
        label: "Total bill splits",
        titleColor: Color.mint
    )
}
