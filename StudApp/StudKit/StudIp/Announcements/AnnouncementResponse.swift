//
//  AnnouncementResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 15.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import CoreData

struct AnnouncementResponse: Decodable {
    let id: String
    private let coursePaths: [String]
    private let rawCreatedAt: String
    private let rawModifiedAt: String
    private let rawExpiresAfter: String
    let title: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case id = "news_id"
        case coursePaths = "ranges"
        case rawCreatedAt = "mkdate"
        case rawModifiedAt = "chdate"
        case rawExpiresAfter = "expire"
        case title = "topic"
        case body
    }

    init(id: String, coursePaths: [String] = [], rawCreatedAt: String, rawModifiedAt: String, rawExpiresAfter: String,
         title: String, body: String = "") {
        self.id = id
        self.coursePaths = coursePaths
        self.rawCreatedAt = rawCreatedAt
        self.rawModifiedAt = rawModifiedAt
        self.rawExpiresAfter = rawExpiresAfter
        self.title = title
        self.body = body
    }
}

// MARK: - Utilities

extension AnnouncementResponse {
    var createdAt: Date? {
        guard let interval = TimeInterval(rawCreatedAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var modifiedAt: Date? {
        guard let interval = TimeInterval(rawModifiedAt) else { return nil }
        return Date(timeIntervalSince1970: interval)
    }

    var expiresAt: Date? {
        guard let createdAt = createdAt else { return nil }
        return createdAt + TimeInterval(rawExpiresAfter)!
    }

    var courseIds: [String] {
        return coursePaths.flatMap { StudIp.transformIdPath($0) }
    }
}

// MARK: - Converting to a Core Data Object

extension AnnouncementResponse {
    func coreDataObject(in context: NSManagedObjectContext) throws -> Announcement {
        // TODO: Move to parsing
        guard
            let createdAt = createdAt,
            let modifiedAt = modifiedAt,
            let expiresAt = expiresAt
        else { throw NSError(domain: Announcement.entity.rawValue, code: 0) }

        let (announcement, _) = try Announcement.fetch(byId: id, orCreateIn: context)
        let courses = try Course.fetch(byIds: courseIds, in: context)
        announcement.id = id
        announcement.courses = Set(courses)
        announcement.createdAt = createdAt
        announcement.modifiedAt = modifiedAt
        announcement.expiresAt = expiresAt
        announcement.title = title
        announcement.body = body
        return announcement
    }
}
