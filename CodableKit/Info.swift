//
//  Info.swift
//  CodableKit
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

public struct Info: Codable {
    public let title: String
    public let copyright: String
    public let year: Int
    public let developers: [String]

    public let demos: Demo?
    public let company: Company
    public let conference: Conference
}

public extension Info {
    public struct Demo: Codable {
        public let demoCount: UInt
        public let bestDemo: String
    }

    public struct Company: Codable {
        public let name: String
        public let foundingYear: UInt16
        public let employeeCount: UInt8
    }

    public struct Conference: Codable {
        public let name: String
        public let isAnniversary: Bool
    }
}

// MARK: - Coding Keys
private extension Info.Demo {
    private enum CodingKeys: String, CodingKey {
        case demoCount = "demo_count"
        case bestDemo = "best_demo"
    }
}

private extension Info.Company {
    private enum CodingKeys: String, CodingKey {
        case name
        case foundingYear = "founding_year"
        case employeeCount = "employee_count"
    }
}

private extension Info.Conference {
    private enum CodingKeys: String, CodingKey {
        case name
        case isAnniversary = "is_anniversary"
    }
}
