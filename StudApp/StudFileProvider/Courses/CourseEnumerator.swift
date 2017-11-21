//
//  CourseEnumerator.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

/// Enumerates all courses in a semester.
final class CourseEnumerator: CachingFileEnumerator {
    private let viewModel: CourseListViewModel

    // MARK: - Life Cycle

    /// Creates a new course enumerator.
    ///
    /// - Parameter itemIdentifier: Item identifier for the containing item, which should be a course item.
    override init(itemIdentifier: NSFileProviderItemIdentifier) {
        let coreDataService = ServiceContainer.default[CoreDataService.self]

        guard let semester = try? Semester.fetch(byId: itemIdentifier.id, in: coreDataService.viewContext),
            let unwrappedSemester = semester else {
            fatalError("Cannot find semester with identifier '\(itemIdentifier)'.")
        }

        viewModel = CourseListViewModel(semester: unwrappedSemester)

        super.init(itemIdentifier: itemIdentifier)

        viewModel.delegate = cache
        viewModel.fetch()
        viewModel.update()
    }

    // MARK: - Providing Items

    override var items: [NSFileProviderItem] {
        return viewModel.flatMap { try? $0.fileProviderItem(context: coreDataService.viewContext) }
    }
}
