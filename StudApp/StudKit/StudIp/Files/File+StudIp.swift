//
//  File+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 12.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

extension File {
    public static func updateFolder(withId id: String, in context: NSManagedObjectContext, handler: @escaping ResultHandler<File>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestDecoded(.folder(withId: id)) { (result: Result<FolderResponse>) in
            handler(result.map { try updateFolder(from: $0, in: context) })
        }
    }

    static func updateFolder(from response: FolderResponse, in context: NSManagedObjectContext) throws -> File {
        guard let folder = try File.update(using: [response], in: context).first else { fatalError() }

        CSSearchableIndex.default().indexSearchableItems(folder.searchableChildrenItems) { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: folder.objectIdentifier.rawValue)
            NSFileProviderManager.default.signalEnumerator(for: itemIdentifier) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return folder
    }

    @discardableResult
    public func download(handler: @escaping ResultHandler<URL>) -> Progress? {
        guard !state.isMostRecentVersionDownloaded else {
            handler(.success(localUrl(in: .fileProvider)))
            return nil
        }

        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .downloads))
        try? FileManager.default.createIntermediateDirectories(forFileAt: localUrl(in: .fileProvider))

        let downloadDate = Date()
        state.isDownloading = true

        let studIpService = ServiceContainer.default[StudIpService.self]
        let destination = localUrl(in: .downloads)
        let task = studIpService.api.download(.fileContents(forFileId: id), to: destination, startsResumed: false) { result in
            self.state.isDownloading = false

            guard result.isSuccess else {
                return handler(.failure(result.error))
            }

            self.state.downloadedAt = downloadDate
            try? self.managedObjectContext?.saveWhenChanged()

            return handler(.success(self.localUrl(in: .fileProvider)))
        }

        guard let downloadTask = task else { return nil }

        if #available(iOSApplicationExtension 11.0, *) {
            let itemIdentifier = NSFileProviderItemIdentifier(rawValue: objectIdentifier.rawValue)
            NSFileProviderManager.default.register(downloadTask, forItemWithIdentifier: itemIdentifier) { _ in
                downloadTask.resume()
            }
            return downloadTask.progress
        }

        downloadTask.resume()
        return nil
    }

    public func removeDownload() throws {
        state.downloadedAt = nil
        try? FileManager.default.removeItem(at: localUrl(in: .downloads))
        try? FileManager.default.removeItem(at: localUrl(in: .fileProvider))
        try managedObjectContext?.saveWhenChanged()
    }

    public var url: URL? {
        let studIpService = ServiceContainer.default[StudIpService.self]
        guard
            let baseUrl = studIpService.api.baseUrl?.deletingLastPathComponent(),
            let url = URL(string: "\(baseUrl)/download/force_download/0/\(id)/\(name)")
        else { return nil }
        return url
    }
}
