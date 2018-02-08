//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CloudKit

public final class SignInViewModel {
    public enum Errors: LocalizedError {

        public var errorDescription: String? {
            fatalError()
        }
    }

    private let coreDataService = ServiceContainer.default[CoreDataService.self]
    private let studIpService = ServiceContainer.default[StudIpService.self]
    private let oAuth1: OAuth1<StudIpOAuth1Routes>

    public let organization: OrganizationRecord

    // MARK: - Life Cycle

    public init(organization: OrganizationRecord) {
        self.organization = organization

        oAuth1 = OAuth1<StudIpOAuth1Routes>(service: StudIpService.serviceName, callbackUrl: App.signInCallbackUrl,
                                            consumerKey: organization.consumerKey, consumerSecret: organization.consumerSecret)
        oAuth1.baseUrl = organization.apiUrl
    }

    // MARK: - Providing Metadata

    public func organizationIcon(handler: @escaping ResultHandler<UIImage>) {
        let container = CKContainer(identifier: App.iCloudContainerIdentifier)
        container.database(with: .public).fetch(withRecordID: organization.recordId) { record, error in
            DispatchQueue.main.async {
                guard
                    let record = record,
                    var organization = OrganizationRecord(from: record),
                    let icon = organization.icon
                else { return handler(.failure(error)) }

                handler(.success(icon))
            }
        }
    }

    // MARK: - Signing In

    public func authorizationUrl(handler: @escaping ResultHandler<URL>) {
        oAuth1.createRequestToken { result in
            handler(result.replacingValue(self.oAuth1.authorizationUrl))
        }
    }

    public func handleAuthorizationCallback(url: URL, handler: @escaping ResultHandler<Void>) {
        oAuth1.createAccessToken(fromAuthorizationCallbackUrl: url) { result in
            guard result.isSuccess else { return handler(result) }

            self.studIpService.signIn(apiUrl: self.organization.apiUrl, authorizing: self.oAuth1) { result in
                self.updateSemesters()
                handler(result.replacingValue(()))
            }
        }
    }

    private func updateSemesters() {
        coreDataService.performBackgroundTask { context in
            Semester.update(in: context) { _ in
                try? context.saveWhenChanged()
            }
        }
    }
}
