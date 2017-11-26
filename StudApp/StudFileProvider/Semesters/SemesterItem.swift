//
//  SemesterItem.swift
//  StudFileProvider
//
//  Created by Steffen Ryll on 11.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData
import FileProvider
import MobileCoreServices
import StudKit

final class SemesterItem: NSObject, NSFileProviderItem {
    // MARK: - Life Cycle

    init(from semester: Semester, childItemCount: Int, parentItemIdentifier: NSFileProviderItemIdentifier = .rootContainer) {
        itemIdentifier = semester.itemIdentifier
        filename = semester.title

        self.childItemCount = childItemCount as NSNumber

        self.parentItemIdentifier = parentItemIdentifier

        lastUsedDate = semester.state.lastUsedAt

        tagData = semester.state.tagData
        favoriteRank = !semester.state.isUnranked ? semester.state.favoriteRank as NSNumber : nil
    }

    convenience init(from semester: Semester) throws {
        let childItemCount = semester.courses.count
        self.init(from: semester, childItemCount: childItemCount, parentItemIdentifier: .rootContainer)
    }

    // MARK: - File Provider Item Conformance

    // MARK: Required Properties

    let itemIdentifier: NSFileProviderItemIdentifier

    let filename: String

    let typeIdentifier = kUTTypeFolder as String

    let capabilities: NSFileProviderItemCapabilities = [.allowsContentEnumerating, .allowsReading]

    // MARK: Managing Content

    let childItemCount: NSNumber?

    // MARK: Specifying Content Location

    let parentItemIdentifier: NSFileProviderItemIdentifier

    // MARK: Tracking Usage

    let lastUsedDate: Date?

    // MARK: Managing Metadata

    let tagData: Data?

    let favoriteRank: NSNumber?
}
