//
//  FileProviderEnumeratorChangeCache.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import FileProvider
import StudKit

/// Caches changes to a data source section.
public class FileProviderEnumeratorChangeCache {
    public private(set) var updatedItems = [CDIdentifiable & FileProviderItemConvertible]()

    public private(set) var deletedItemIdentifiers = [NSFileProviderItemIdentifier]()

    /// File provider sync anchor, containing a UNIX timestamp.
    public private(set) var currentSyncAnchor = FileProviderEnumeratorChangeCache.syncAnchor()

    public init() {}

    /// Generates a sync anchor for the date given. Defaults to now.
    private static func syncAnchor(for date: Date = Date()) -> NSFileProviderSyncAnchor {
        guard let data = String(date.timeIntervalSince1970).data(using: .utf8) else {
            fatalError("Cannot generate sync anchor data from current time.")
        }
        return NSFileProviderSyncAnchor(data)
    }

    /// Clears the cache.
    public func flush() {
        updatedItems.removeAll()
        deletedItemIdentifiers.removeAll()
        currentSyncAnchor = FileProviderEnumeratorChangeCache.syncAnchor()
    }
}

// MARK: - Data Source Section Delegate

extension FileProviderEnumeratorChangeCache: DataSourceSectionDelegate {
    public func data<Section: DataSourceSection>(changedIn row: Section.Row, at _: Int, change: DataChange<Section.Row, Int>,
                                                 in _: Section) {
        guard let item = row as? CDIdentifiable & FileProviderItemConvertible else { fatalError() }
        switch change {
        case .insert, .update:
            updatedItems.append(item)
        case .delete:
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: item.objectIdentifier.rawValue)
            deletedItemIdentifiers.append(itemIdentifier)
        case .move:
            break
        }
    }
}
