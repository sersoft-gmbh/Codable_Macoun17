//
//  IniCodingKey.swift
//  ParsINI
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

struct IniCodingKey: CodingKey {
    let intValue: Int?
    let stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
}

extension IniCodingKey {
    static let `super` = IniCodingKey(stringValue: "super")
}
