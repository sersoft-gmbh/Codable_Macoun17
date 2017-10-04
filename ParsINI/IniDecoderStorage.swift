//
//  IniDecoderStorage.swift
//  ParsINI
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

struct IniDecodingStorage {
    private(set) var containers: [Any] = []

    init() {}
    init(value: Any) { containers = [value] }

    var isEmpty: Bool { return containers.isEmpty }
    var count: Int { return containers.count }

    var topContainer: Any {
        guard let topLevel = containers.last else {
            preconditionFailure("Storage is empty!")
        }
        return topLevel
    }

    mutating func push(container: Any) {
        containers.append(container)
    }

    mutating func popContainer() {
        precondition(!containers.isEmpty, "Storage is empty!")
        containers.removeLast()
    }
}
