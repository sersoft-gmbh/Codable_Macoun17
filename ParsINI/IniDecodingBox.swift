//
//  IniDecodingBox.swift
//  ParsINI
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import struct Foundation.Decimal

struct IniDecodingBox {
    let codingPath: [CodingKey]
    let value: Any
    let decoder: _IniDecoder

    init(value: Any, at codingPath: [CodingKey], decoder: _IniDecoder) {
        self.value = value
        self.codingPath = codingPath
        self.decoder = decoder
    }
}

extension IniDecodingBox {
    var valueIsNil: Bool {
        return (value as? OptionalProtocol)?.isNil ?? false
    }

    private func expectNonOptional<T>(_ type: T.Type) throws {
        guard !valueIsNil else {
            throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: "Expected \(type) but found nil instead!"))
        }
    }

    func directCast<T>(to type: T.Type = T.self) throws -> T {
        try expectNonOptional(type)
        guard let target = value as? T else {
            throw DecodingError._typeMismatch(at: codingPath, expected: T.self, found: value)
        }
        return target
    }

    func decodeNil() -> Bool {
        return valueIsNil
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try directCast()
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try directCast()
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try directCast()
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try directCast()
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try directCast()
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try directCast()
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try directCast()
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try directCast()
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try directCast()
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try directCast()
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try directCast()
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try directCast()
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try directCast()
    }

    func decode(_ type: String.Type) throws -> String {
        return try directCast()
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoded: T
        if type == Decimal.self || type == NSDecimalNumber.self {
            decoded = try (value as? Decimal ?? Decimal(decode(Double.self))) as! T
        } else {
            decoder.storage.push(container: value)
            decoded = try .init(from: decoder)
            decoder.storage.popContainer()
        }
        return decoded
    }
}

// Hack around checking for Optionals
fileprivate protocol OptionalProtocol {
    var isNil: Bool { get }
}
extension Optional: OptionalProtocol {
    var isNil: Bool { return self == nil }
}

extension DecodingError {
    static func _typeMismatch<T>(at codingPath: [CodingKey], expected: T.Type, found: Any) -> DecodingError {
        let description = "Expected to decode \(expected) but found \(typeDescription(of: found)) instead."
        return .typeMismatch(expected, .init(codingPath: codingPath, debugDescription: description))
    }

    fileprivate static func typeDescription(of value: Any) -> String {
        switch true {
        case value is OptionalProtocol,
             value is NSNull:
            return "nil"
        case value is String:
            return "a string"
        case value is NSNumber:
            return "a number"
        case value is [Any]:
            return "an array"
        case value is [String: Any]:
            return "a dictionary"
        default:
            return "\(type(of: value))"
        }
    }
}
