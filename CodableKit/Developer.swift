//
//  Developer.swift
//  CodableKit
//
//  Created by Florian Friedrich on 16.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

public struct Developer: Equatable, Codable {
    public let id: Int
    public let name: String
    public let isSpeaker: Bool

    /* demo1.json
    public let company: String?
    // */

    /* demo2.json & demo3.json
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isSpeaker = try container.decode(Bool.self, forKey: .isSpeaker)
        company = try container.decode(String?.self, forKey: .company)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isSpeaker, forKey: .isSpeaker)
        try container.encode(company, forKey: .company)
    }
    // */
    
    public static func ==(lhs: Developer, rhs: Developer) -> Bool {
        return lhs.id == rhs.id
    }
}

/* demo2.json & demo3.json
private extension Developer {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isSpeaker = "is_speaker"
        case company
    }
}
// */
