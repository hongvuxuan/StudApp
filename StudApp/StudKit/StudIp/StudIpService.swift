//
//  StudIpService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import CoreSpotlight

public class StudIpService {
    let api: Api<StudIpRoutes>

    init(api: Api<StudIpRoutes>) {
        self.api = api
    }

    convenience init() {
        self.init(api: Api<StudIpRoutes>())

        guard let currentUser = User.current else { return }
        let oAuth1 = try? OAuth1<StudIpOAuth1Routes>(fromPersistedService: currentUser.objectIdentifier.rawValue)
        let apiUrl = currentUser.organization.apiUrl
        oAuth1?.baseUrl = apiUrl

        api.baseUrl = apiUrl
        api.authorizing = oAuth1
    }

    /// Whether the user is currently signed in.
    ///
    /// - Warning: This does not garantuee that the credential is actually correct as this implementation only relies on a
    ///            credential being stored. Thus, the password might have changed in the meantime.
    public var isSignedIn: Bool {
        return api.authorizing?.isAuthorized ?? false
    }

    func sign(into organization: Organization, authorizing: ApiAuthorizing, completion: @escaping ResultHandler<User>) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]
        var persistableApiAuthorizing = authorizing as? PersistableApiAuthorizing

        signOut()

        api.baseUrl = organization.apiUrl
        api.authorizing = authorizing

        let group = DispatchGroup()

        var discoveryResult: Result<ApiRoutesAvailablity>!
        group.enter()
        organization.updateDiscovery(in: coreDataService.viewContext) { result in
            discoveryResult = result
            group.leave()
        }

        var userResult: Result<User>!
        group.enter()
        User.updateCurrent(organization: organization, in: coreDataService.viewContext) { result in
            userResult = result
            group.leave()
        }

        group.notify(queue: .main) {
            guard discoveryResult.isSuccess, let user = userResult.value else {
                self.signOut()
                return completion(userResult)
            }

            User.current = user
            persistableApiAuthorizing?.service = user.objectIdentifier.rawValue
            try? persistableApiAuthorizing?.persistCredentials()
            try? coreDataService.viewContext.saveAndWaitWhenChanged()

            if #available(iOSApplicationExtension 11.0, *) {
                NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            }

            completion(userResult)
        }
    }

    /// Removes the default credential used for authentication, replaces it with an empty credential, and clears the database.
    func signOut() {
        try? (api.authorizing as? PersistableApiAuthorizing)?.removeCredentials()

        api.baseUrl = nil
        api.authorizing = nil
        api.removeLastRouteAccesses()
        User.current = nil

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

    func update(in context: NSManagedObjectContext, completion: @escaping () -> Void) {
        guard let user = User.current else { return completion() }
        guard let organization = context.object(with: user.organization.objectID) as? Organization else { fatalError() }

        let group = DispatchGroup()

        group.enter()
        organization.updateDiscovery(in: context) { _ in group.leave() }

        group.enter()
        User.updateCurrent(organization: organization, in: context) { _ in group.leave() }

        group.enter()
        user.organization.updateSemesters(in: context) { result in
            defer { group.leave() }
            guard result.isSuccess else { return }

            group.enter()
            user.updateAuthoredCourses(in: context) { _ in
                defer { group.leave() }
                guard result.isSuccess else { return }

                for course in user.authoredCourses {
                    group.enter()
                    course.updateAnnouncements(in: context) { _ in group.leave() }

                    group.enter()
                    course.updateChildFiles(in: context) { _ in group.leave() }
                }
            }
        }

        group.notify(queue: .main) { completion() }
    }
}
