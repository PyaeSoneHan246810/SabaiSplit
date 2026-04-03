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
    var numberOfPerson: Int {
        personList.count
    }
    var numberOfPaidPerson: Int {
        personList.filter { $0.hasPaid }.count
    }
    var isAllPaid: Bool {
        !personList.isEmpty && personList.allSatisfy { $0.hasPaid }
    }
    var ratio: String {
        "\(numberOfPaidPerson)/\(numberOfPerson)"
    }
    var paidAmount: Double {
        personList.filter { $0.hasPaid }.reduce(0) { $0 + $1.amount }
    }
    var remainingAmount: Double {
        personList.filter { !$0.hasPaid }.reduce(0) { $0 + $1.amount }
    }
}

extension BillSplit {
    static var sample: BillSplit {
        BillSplit(
            title: "Sample Bill Title",
            totalAmount: 2000.0,
            tipPercentage: 0.0,
            date: Date(),
            personList: [
                Person(name: "Person 1", amount: 1000, hasPaid: true, paidDate: Date()),
                Person(name: "Person 2", amount: 1000, hasPaid: false, paidDate: nil)
            ]
        )
    }
}
