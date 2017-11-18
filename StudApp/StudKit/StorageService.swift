//
//  StorageService.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class StorageService {
    let defaults = UserDefaults(suiteName: StudKitServiceProvider.appGroupIdentifier)

    lazy var documentsUrl: URL = {
        let identifier = StudKitServiceProvider.appGroupIdentifier
        guard let appGroupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            fatalError("Cannot create URL for app group directory with identifier '\(identifier)'.")
        }
        return appGroupUrl.appendingPathComponent("Dcouments", isDirectory: true)
    }()
}
