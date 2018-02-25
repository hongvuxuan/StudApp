//
//  Organization+StudIp.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension Organization {
    public func updateSemesters(in context: NSManagedObjectContext, completion: @escaping ResultHandler<[Semester]>) {
        let studIpService = ServiceContainer.default[StudIpService.self]
        studIpService.api.requestCollection(.semesters) { (result: Result<[SemesterResponse]>) in
            let result = result.map { response -> [Semester] in
                guard let organization = context.object(with: self.objectID) as? Organization else { fatalError() }
                return try Organization.updateSemesters(Semester.fetchRequest(), with: response, organization: organization,
                                                        in: context)
            }
            completion(result)
        }
    }

    private static func updateSemesters(_ existingObjects: NSFetchRequest<Semester>, with response: [SemesterResponse],
                                        organization: Organization, in context: NSManagedObjectContext) throws -> [Semester] {
        let semesters = try Semester.update(existingObjects, with: response, in: context) {
            try $0.coreDataObject(organization: organization, in: context)
        }

        if #available(iOSApplicationExtension 11.0, *) {
            NSFileProviderManager.default.signalEnumerator(for: .rootContainer) { _ in }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }

        return semesters
    }
}