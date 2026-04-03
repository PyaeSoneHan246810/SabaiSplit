//
//  BillSplit.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI
import SwiftData

@Model
final class BillSplit {
    var title: String = ""
    var totalAmount: Double = 0.0
    var tipPercentage: Double = 0.0
    var date: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \Person.billSplit)
    var personList: [Person] = []
    init(title: String, totalAmount: Double, tipPercentage: Double, date: Date = Date(), personList: [Person] = []) {
        self.title = title
        self.totalAmount = totalAmount
        self.tipPercentage = tipPercentage
        self.date = date
        self.personList = personList
    }
}
