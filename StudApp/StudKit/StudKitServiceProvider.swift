//
//  StudKitServiceProvider.swift
//  StudKit
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public class StudKitServiceProvider: ServiceProvider {
    private let currentTarget: Targets
    private let extensionContext: NSExtensionContext?
    private let openUrl: ((URL, ((Bool) -> Void)?) -> Void)?

    public init(currentTarget: Targets, extensionContext: NSExtensionContext? = nil,
                openUrl: ((URL, ((Bool) -> Void)?) -> Void)? = nil) {
        self.currentTarget = currentTarget
        self.extensionContext = extensionContext
        self.openUrl = openUrl
    }

    func provideContextService() -> ContextService {
        return ContextService(currentTarget: currentTarget, extensionContext: extensionContext, openUrl: openUrl)
    }

    func provideJsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func provideCoreDataService() -> CoreDataService {
        return CoreDataService(modelName: "StudKit", appGroupIdentifier: App.groupIdentifier)
    }

    func provideStudIpService() -> StudIpService {
        return StudIpService()
    }

    func provideStudAppService() -> StudAppService {
        guard let baseUrl = URL(string: "http://127.0.0.1:8080/api/v1") else { fatalError("Cannot construct API URL.") }
        return StudAppService(baseUrl: baseUrl)
    }

    public func registerServices(in container: ServiceContainer) {
        container[ContextService.self] = provideContextService()
        container[CacheService.self] = CacheService()
        container[StudAppService.self] = provideStudAppService()
        container[StoreService.self] = StoreService()
        container[JSONDecoder.self] = provideJsonDecoder()
        container[StorageService.self] = StorageService()
        container[CoreDataService.self] = provideCoreDataService()
        container[HistoryService.self] = HistoryService(currentTarget: currentTarget)
        container[StudIpService.self] = provideStudIpService()
    }
}
