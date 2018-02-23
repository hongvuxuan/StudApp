//
//  FolderResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 16.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import CoreData
import MobileCoreServices

struct FolderResponse: IdentifiableResponse {
    let id: String
    let userId: String?
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let summary: String?
    let folders: Set<FolderResponse>?
    let documents: Set<DocumentResponse>?

    init(id: String, userId: String? = nil, name: String = "", createdAt: Date = .distantPast, modifiedAt: Date = .distantPast,
         summary: String? = nil, folders: Set<FolderResponse>? = nil, documents: Set<DocumentResponse>? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.summary = summary
        self.folders = folders
        self.documents = documents
    }
}

// MARK: - Coding

extension FolderResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case createdAt = "mkdate"
        case modifiedAt = "chdate"
        case summary = "description"
        case folders = "subfolders"
        case documents = "file_refs"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)?.nilWhenEmpty
        name = try container.decode(String.self, forKey: .name)
        createdAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .createdAt)
        modifiedAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .modifiedAt)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        folders = try container.decodeIfPresent(Set<FolderResponse>.self, forKey: .folders)
        documents = try container.decodeIfPresent(Set<DocumentResponse>.self, forKey: .documents)
    }
}

// MARK: - Converting to a Core Data Object

extension FolderResponse {
    @discardableResult
    func coreDataObject(course: Course, parent: File? = nil, in context: NSManagedObjectContext) throws -> File {
        let (folder, _) = try File.fetch(byId: id, orCreateIn: context)
        folder.organization = course.organization
        folder.typeIdentifier = kUTTypeFolder as String
        folder.parent = parent ?? folder.parent
        folder.course = course
        folder.owner = try User.fetch(byId: userId, in: context)
        folder.name = name
        folder.createdAt = createdAt
        folder.modifiedAt = modifiedAt
        folder.size = -1
        folder.downloadCount = -1
        folder.summary = summary
        let folders = try self.folders(parent: folder, course: course, in: context) ?? []
        let documents = try self.documents(parent: folder, course: course, in: context) ?? []
        folder.children = folder.children.union(folders).union(documents)
        return folder
    }

    func folders(parent: File, course: Course, in context: NSManagedObjectContext) throws -> [File]? {
        guard let folders = folders else { return nil }
        return try File.update(parent.childFoldersFetchRequest, with: folders, in: context) { response in
            try response.coreDataObject(course: course, parent: parent, in: context)
        }
    }

    func documents(parent: File, course: Course, in context: NSManagedObjectContext) throws -> [File]? {
        guard let documents = documents else { return nil }
        return try File.update(parent.childDocumentsFetchRequest, with: documents, in: context) { response in
            try response.coreDataObject(course: course, parent: parent, in: context)
        }
    }
}
