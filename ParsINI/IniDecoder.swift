//
//  IniDecoder.swift
//  ParsINI
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

public final class IniDecoder {
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        guard let str = String(data: data, encoding: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Data could not be converted to String!"))
        }
        let content: IniContent
        do {
            content = try IniParser.parse(string: str)
        } catch let iniError as IniError {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The INI data was not valid!", underlyingError: iniError))
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "An unknown error occurred!", underlyingError: error))
        }
        // TODO: This will not allow toplevel to have the a key which is also a section name.
        let rootContainer: [String: Any] = content.topLevel.reduce(into: content.sections) { $0.updateValue($1.value, forKey: $1.key) }
        let storage = IniDecodingStorage(value: rootContainer)
        let decoder = _IniDecoder(storage: storage, userInfo: userInfo)
        return try decoder.singleValueContainer().decode(type)
    }
}

internal final class _IniDecoder: Decoder {
    let userInfo: [CodingUserInfoKey: Any]
    var codingPath: [CodingKey]
    var storage: IniDecodingStorage

    init(storage: IniDecodingStorage, codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.storage = storage
        self.userInfo = userInfo
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let box = IniDecodingBox(value: storage.topContainer, at: codingPath, decoder: self)
        return try KeyedDecodingContainer(IniKeyedDecodingContainer(box: box, decoder: self))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let box = IniDecodingBox(value: storage.topContainer, at: codingPath, decoder: self)
        return try IniUnkeyedDecodingContainer(box: box, decoder: self)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return IniDecodingBox(value: storage.topContainer, at: codingPath, decoder: self)
    }
}
