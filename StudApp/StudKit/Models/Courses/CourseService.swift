//
//  CourseService.swift
//  StudKit
//
//  Created by Steffen Ryll on 22.07.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

public final class CourseService {
    private let studIp: StudIpService
    private let userId = "f1480088c469549fb9bb29cfef4fa1ad"

    init() {
        studIp = ServiceContainer.default[StudIpService.self]
    }

    public func update(in context: NSManagedObjectContext, handler: @escaping ResultHandler<[Course]>) {
        // TODO: Use user id that is NOT hard-coded.
        studIp.api.requestCompleteCollection(.courses(forUserId: userId)) { (result: Result<[CourseResponse]>) in
            Course.update(using: result, in: context, handler: handler)

            guard let semesters = try? Semester.fetchNonHidden(in: context) else { return }
            for semester in semesters {
                NSFileProviderManager.default.signalEnumerator(for: semester.itemIdentifier) { _ in }
            }
            NSFileProviderManager.default.signalEnumerator(for: .workingSet) { _ in }
        }
    }
}