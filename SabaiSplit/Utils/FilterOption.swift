//
//  FilterOption.swift
//  SabaiSplit
//
//  Created by Dylan on 8/4/26.
//

import Foundation

enum FilterOption: String, Identifiable {
    case all
    case completed
    case inProgress
    var id: String {
        self.rawValue
    }
}
