//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreSpotlight

public class StudIpService {
    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    convenience init() {
        self.init(api: Api<StudIpRoutes>())

        /*guard let apiUrl = self.apiUrl else { return }
        let oAuth1 = try? OAuth1<StudIpOAuth1Routes>(fromPersistedService: StudIpService.serviceName)
        oAuth1?.baseUrl = apiUrl

        api.baseUrl = apiUrl
        api.authorizing = oAuth1*/
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return api.authorizing?.isAuthorized ?? false
    }

    func sign(into organization: Organization, authorizing: ApiAuthorizing, completion: @escaping ResultHandler<User>) {
        signOut()

        api.baseUrl = organization.apiUrl
        api.authorizing = authorizing

        try? (authorizing as? PersistableApiAuthorizing)?.persistCredentials()

        let coreDataService = ServiceContainer.default[CoreDataService.self]

        User.updateCurrent(organization: organization, in: coreDataService.viewContext) { result in
            guard result.isSuccess else {
                self.signOut()
                return completion(result)
            }

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            completion(result)
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        User.currentId = nil

        api.baseUrl = nil
        api.removeLastRouteAccesses()
        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        let coreDataService = ServiceContainer.default[CoreDataService.self]
        try? coreDataService.removeAllObjects(in: coreDataService.viewContext)
        try? coreDataService.viewContext.saveAndWaitWhenChanged()

        let storageService = ServiceContainer.default[StorageService.self]
        try? storageService.removeAllDownloads()

        CSSearchableIndex.default().deleteAllSearchableItems { _ in }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}
