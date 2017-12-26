//
//  EventResponse.swift
//  StudKit
//
//  Created by Steffen Ryll on 26.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

struct EventResponse: Decodable {
    let id: String
    let startsAt: Date
    let endsAt: Date
    let isCanceled: Bool
    let cancellationReason: String?
    let location: String?
    let summary: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id = "event_id"
        case startsAt = "start"
        case endsAt = "end"
        case isCanceled = "deleted"
        case cancellationReason = "canceled"
        case location = "room"
        case summary = "description"
        case category = "categories"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        startsAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .startsAt)
        endsAt = try StudIp.decodeTimeIntervalStringAsDate(in: container, forKey: .endsAt)
        isCanceled = try container.decodeIfPresent(Bool.self, forKey: .isCanceled) ?? false
        cancellationReason = try StudIp.decodeCancellationReason(in: container, forKey: .cancellationReason)
        location = isCanceled ? nil : try StudIp.decodeLocation(in: container, forKey: .location)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)?.nilWhenEmpty
        category = try container.decodeIfPresent(String.self, forKey: .category)?.nilWhenEmpty
    }
}
