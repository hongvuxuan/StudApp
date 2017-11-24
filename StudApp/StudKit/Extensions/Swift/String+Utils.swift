//
//  String+Utils.swift
//  StudKit
//
//  Created by Steffen Ryll on 04.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import Foundation

public extension String {
    /// Returns `nil` in case of an empty string. Otherwise, this method returns the string itself.
    public var nilWhenEmpty: String? {
        return isEmpty ? nil : self
    }

    /// Returns a localized string with this key.
    ///
    /// - Parameters:
    ///   - comment: Optional comment describing the use case.
    ///   - arguments: Arguments to be interpolated into the localized string.
    /// - Returns: Localized string with interpolated parameters.
    public func localized(withComment comment: String = "", arguments: CVarArg...) -> String {
        let localizedString = NSLocalizedString(self, tableName: nil, bundle: StudKitServiceProvider.kitBundle,
                                                value: "###\(self)###", comment: comment)
        return String(format: localizedString, arguments: arguments)
    }
}
