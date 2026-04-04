//
//  ICloudStatusProvider.swift
//  SabaiSplit
//
//  Created by Dylan on 5/4/26.
//

import SwiftUI
import Observation
import CloudKit

@Observable
final class ICloudStatusProvider {
    private(set) var accountStatus: CKAccountStatus? = nil
    
    func refreshStatus() async {
        do {
            accountStatus = try await CKContainer.default().accountStatus()
        } catch {
            accountStatus = .couldNotDetermine
        }
    }
}
