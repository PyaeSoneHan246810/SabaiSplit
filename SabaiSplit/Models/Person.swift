//
//  Person.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import SwiftUI
import SwiftData

@Model
final class Person {
    var name: String = ""
    var amount: Double = 0.0
    var hasPaid: Bool = false
    var paidDate: Date? = nil
    var billSplit: BillSplit? = nil
    init(name: String, amount: Double, hasPaid: Bool = false, paidDate: Date? = nil, billSplit: BillSplit? = nil) {
        self.name = name
        self.amount = amount
        self.hasPaid = hasPaid
        self.paidDate = paidDate
        self.billSplit = billSplit
    }
}
