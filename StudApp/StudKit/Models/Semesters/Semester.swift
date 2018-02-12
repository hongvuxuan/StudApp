//
//  Semester.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

@objc(Semester)
public final class Semester: NSManagedObject, CDCreatable, CDIdentifiable, CDUpdatable, CDSortable {
    public static var entity = ObjectIdentifier.Entites.semester

    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var beginsAt: Date
    @NSManaged public var endsAt: Date
    @NSManaged public var coursesBeginAt: Date
    @NSManaged public var coursesEndAt: Date

    @NSManaged public var courses: Set<Course>
    @NSManaged public var state: SemesterState

    public required convenience init(createIn context: NSManagedObjectContext) {
        self.init(context: context)
        state = SemesterState(createIn: context)
    }

    // MARK: - Sorting

    static let defaultSortDescriptors = [
        NSSortDescriptor(keyPath: \Semester.beginsAt, ascending: false),
    ]
}

// MARK: - Utilities

public extension Semester {
    public var isCurrent: Bool {
        let now = Date()
        return now >= beginsAt && now <= endsAt
    }

    public var monthRange: String {
        return "\(beginsAt.formatted(using: .monthAndYear)) – \(endsAt.formatted(using: .monthAndYear))"
    }
}

// MARK: - Core Data Operations

extension Semester {
    public static func fetch(from beginSemester: Semester? = nil, to endSemester: Semester? = nil,
                             in context: NSManagedObjectContext) throws -> [Semester] {
        let beginsAt = beginSemester?.beginsAt ?? .distantPast
        let endsAt = endSemester?.endsAt ?? .distantFuture
        let predicate = NSPredicate(format: "beginsAt >= %@ AND endsAt <= %@", beginsAt as CVarArg, endsAt as CVarArg)
        let request = fetchRequest(predicate: predicate, sortDescriptors: defaultSortDescriptors)
        return try context.fetch(request)
    }

    public static var sortedFetchRequest: NSFetchRequest<SemesterState> {
        return SemesterState.fetchRequest(predicate: NSPredicate(value: true),
                                          sortDescriptors: SemesterState.defaultSortDescriptors,
                                          relationshipKeyPathsForPrefetching: ["semester"])
    }

    public static var nonHiddenFetchRequest: NSFetchRequest<SemesterState> {
        let predicate = NSPredicate(format: "isHidden == NO")
        return SemesterState.fetchRequest(predicate: predicate, sortDescriptors: SemesterState.defaultSortDescriptors,
                                          relationshipKeyPathsForPrefetching: ["semester"])
    }

    public static func fetchNonHidden(in context: NSManagedObjectContext) throws -> [Semester] {
        return try context.fetch(nonHiddenFetchRequest).map { $0.semester }
    }

    public var coursesFetchRequest: NSFetchRequest<CourseState> {
        let predicate = NSPredicate(format: "%@ IN course.semesters", self)
        return CourseState.fetchRequest(predicate: predicate, sortDescriptors: CourseState.defaultSortDescriptors,
                                        relationshipKeyPathsForPrefetching: ["course"])
    }
}
