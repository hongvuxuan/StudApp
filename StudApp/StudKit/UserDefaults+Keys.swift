//
//  UserDefaults+Keys.swift
//  StudKit
//
//  Created by Steffen Ryll on 18.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

extension UserDefaults {
    static func lastHistoryTransactionTimestampKey(for target: Targets) -> String {
        return "lastHistoryTransactionTimestamp-\(target)"
    }

    static let apiUrl = "apiUrl"

    static let authenticationRealm = "authenticationRealm"

    static let userIdKey = "userId"

    static let storeStateKey = "storeState"

    static let storeStateSubscribedUntilKey = "storeStateSubscribedUntil"
}
