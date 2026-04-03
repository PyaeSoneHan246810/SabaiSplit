//
//  NumberOfPeopleStepperView.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI

struct NumberOfPeopleStepperView: View {
    @Binding var numberOfPeople: Int
    var body: some View {
        Stepper(
            value: $numberOfPeople,
            in: 2...20
        ) {
            HStack {
                Text("Number of People")
                Spacer()
                Text(numberOfPeople, format: .number)
                    .fontWeight(.semibold)
                    .foregroundStyle(.mint)
            }
        }
        .backgroundCardStyle(height: 60.0)
    }
}

#Preview {
    NumberOfPeopleStepperView(numberOfPeople: .constant(2))
}
