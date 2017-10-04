//
//  JSONFile.swift
//  Codable
//
//  Created by Florian Friedrich on 29.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import Foundation

struct JSONFile: Equatable {
    let name: String
    let file: URL

    static func ==(lhs: JSONFile, rhs: JSONFile) -> Bool {
        return lhs.name == rhs.name && lhs.file == rhs.file
    }
}

extension JSONFile {
    static let allFiles: [JSONFile] = [
        JSONFile(name: "Demo 1", file: Bundle.main.url(forResource: "demo1", withExtension: "json")!),
        JSONFile(name: "Demo 2", file: Bundle.main.url(forResource: "demo2", withExtension: "json")!),
        JSONFile(name: "Demo 3", file: Bundle.main.url(forResource: "demo3", withExtension: "json")!)
    ]
}
