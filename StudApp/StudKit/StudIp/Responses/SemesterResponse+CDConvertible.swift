//
//  SemesterResponse+CDConvertible.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

extension SemesterResponse: CDConvertible {
    @discardableResult
    func coreDataModel(in context: NSManagedObjectContext) throws -> NSManagedObject {
        let (semester, isNew) = try Semester.fetch(byId: id, orCreateIn: context)
        semester.id = id
        semester.title = title
        semester.beginDate = beginDate
        semester.endDate = endDate
        semester.coursesBeginDate = coursesBeginDate
        semester.coursesEndDate = coursesEndDate

        if isNew {
            semester.state.isHidden = !semester.isCurrent
        }

        return semester
    }
}