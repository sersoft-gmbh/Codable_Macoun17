//
//  IniDecodingContainers.swift
//  ParsINI
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

extension IniDecodingBox: SingleValueDecodingContainer {}

struct IniKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    private let decoder: _IniDecoder
    private let container: [String: Any]

    let codingPath: [CodingKey]

    let allKeys: [Key]

    init(decoder: _IniDecoder, container: [String: Any]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.allKeys = container.keys.flatMap(Key.init)
    }

    init(box: IniDecodingBox, decoder: _IniDecoder) throws {
        try self.init(decoder: decoder, container: box.directCast())
    }

    private func box(forKey key: Key) throws -> IniDecodingBox {
        guard let val = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "Key \(key) (\(key.stringValue)) not found"))
        }
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        return IniDecodingBox(value: val, at: decoder.codingPath, decoder: decoder)
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        return _IniDecoder(storage: .init(value: container[key.stringValue] as Any),
                           codingPath: codingPath, userInfo: decoder.userInfo)
    }

    // MARK: - Container protocols
    func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return try box(forKey: key).decodeNil()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try box(forKey: key).decode(type)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try box(forKey: key).decode(type)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        return try box(forKey: key).decode(type.self)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return try KeyedDecodingContainer(IniKeyedDecodingContainer<NestedKey>(box: box(forKey: key), decoder: decoder))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try IniUnkeyedDecodingContainer(box: box(forKey: key), decoder: decoder)
    }

    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: IniCodingKey.super)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

struct IniUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    private let decoder: _IniDecoder
    private let container: [Any]

    let codingPath: [CodingKey]

    private(set) var currentIndex: Int
    var count: Int? { return container.count }
    var isAtEnd: Bool { return currentIndex >= container.count }

    init(decoder: _IniDecoder, container: [Any]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = container.startIndex
    }

    init(box: IniDecodingBox, decoder: _IniDecoder) throws {
        try self.init(decoder: decoder, container: box.directCast())
    }

    private mutating func withBox<T>(do work: (IniDecodingBox) throws -> T) throws -> T {
        let key = IniCodingKey(index: currentIndex)
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, .init(codingPath: codingPath + [key],
                                                          debugDescription: "Unkeyed container is at end"))
        }
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        let box = IniDecodingBox(value: container[currentIndex], at: decoder.codingPath, decoder: decoder)
        let value = try work(box)
        currentIndex += 1
        return value
    }

    // MARK: - Container
    mutating func decodeNil() throws -> Bool {
        return try withBox { $0.decodeNil() }
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try withBox { try $0.decode(type) }
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try withBox { try $0.decode(type) }
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return try withBox { try KeyedDecodingContainer(IniKeyedDecodingContainer<NestedKey>(box: $0, decoder: decoder)) }
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try withBox { try IniUnkeyedDecodingContainer(box: $0, decoder: decoder) }
    }

    mutating func superDecoder() throws -> Decoder {
        return try withBox { _IniDecoder(storage: .init(value: $0.value), codingPath: $0.codingPath, userInfo: decoder.userInfo) }
    }
}
