//
//  TipOption.swift
//  SabaiSplit
//
//  Created by Dylan on 3/4/26.
//

import Foundation

enum TipOption: String, Identifiable, CaseIterable {
    case noTip
    case tip10
    case tip15
    case tip20
    case other
    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .noTip:
            "No tip"
        case .tip10:
            "10%"
        case .tip15:
            "15%"
        case .tip20:
            "20%"
        case .other:
            "Other"
        }
    }
}
