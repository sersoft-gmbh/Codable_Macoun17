//
//  Conference.swift
//  CodableKit
//
//  Created by Florian Friedrich on 16.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

public struct Conference: Equatable, Codable {
    public let name: String
    public let participants: [Developer]

    /* demo1.json & demo2.json
    public let dateFrom: Date
    public let dateTo: Date
    // */

    /* demo3.json
    public let dateRange: Range<Date>

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        participants = try container.decode(Array<Developer>.self, forKey: .participants)

        let dateRangeContainer = try container.nestedContainer(keyedBy: DateRangeCodingKeys.self, forKey: .dateRange)
        let dateFrom = try dateRangeContainer.decode(Date.self, forKey: .from)
        let dateTo = try dateRangeContainer.decode(Date.self, forKey: .to)
        dateRange = dateFrom..<dateTo
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(participants, forKey: .participants)

        var dateRangeContainer = container.nestedContainer(keyedBy: DateRangeCodingKeys.self, forKey: .dateRange)
        try dateRangeContainer.encode(dateRange.lowerBound, forKey: .from)
        try dateRangeContainer.encode(dateRange.upperBound, forKey: .to)
    }
    // */
    
    public static func ==(lhs: Conference, rhs: Conference) -> Bool {
        return lhs.name == rhs.name
    }
}

/* demo2.json
private extension Conference {
    private enum CodingKeys: String, CodingKey {
        case name
        case participants
        case dateFrom = "date_from"
        case dateTo = "date_to"
    }
}
// */

/* demo3.json
private extension Conference {
    private enum CodingKeys: String, CodingKey {
        case name
        case participants
        case dateRange = "date_range"
    }

    private enum DateRangeCodingKeys: String, CodingKey {
        case from
        case to
    }
}
// */
