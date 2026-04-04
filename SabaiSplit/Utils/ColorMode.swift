//
//  ColorMode.swift
//  SabaiSplit
//
//  Created by Dylan on 4/4/26.
//

import SwiftUI

enum ColorMode: String, Identifiable, CaseIterable {
    case system
    case light
    case dark
    var id: String {
        self.labelText
    }
    var labelText: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            ColorScheme.light
        case .dark:
            ColorScheme.dark
        }
    }
}
