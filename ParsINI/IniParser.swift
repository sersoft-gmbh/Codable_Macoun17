//
//  IniParser.swift
//  ParsINI
//
//  Created by Florian Friedrich on 24.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import Foundation

public struct IniContent: CustomStringConvertible {
    public let topLevel: [String: Any]
    public let sections: [String: [String: Any]]
    
    public var description: String {
        return """
        INI
        \(topLevel)
        sections:
        \(sections)
        """
    }
}

public enum IniError: Error, CustomStringConvertible {
    case internalParsingError(Error)
    case malformedData(String)
    
    public var description: String {
        switch self {
        case .internalParsingError(let err):
            return "Internal parsing error: \(err)"
        case .malformedData(let data):
            return "Malformed Data! Around '\(data)'"
        }
    }
}

public struct IniParser {
    private init() {}

    public static func parse(string: String) throws -> IniContent {
        do {
            var cleanedString = try stripCommentsAndEmptyLines(from: string)
            guard !cleanedString.isEmpty else { return IniContent(topLevel: [:], sections: [:]) }
            let topLevel = try parseTopLevelContent(from: &cleanedString)
            guard !cleanedString.isEmpty else { return IniContent(topLevel: topLevel, sections: [:]) }
            let sections = try parseSections(from: &cleanedString)
            return IniContent(topLevel: topLevel, sections: sections)
        } catch let error as IniError {
            throw error
        } catch {
            throw IniError.internalParsingError(error)
        }
    }
    
    private static func stripCommentsAndEmptyLines(from string: String) throws -> String {
        return try string.replacing(pattern: "^(|(;|#).*?)\n", with: "", options: [.caseInsensitive, .anchorsMatchLines])
    }
    
    private static func parseTopLevelContent(from string: inout String) throws -> [String: Any] {
        guard string.first != "[" else { return [:] } // We have a section already -> No top level content.
        let endIndex = try string.firstRange(ofPattern: "^\\[", options: [.caseInsensitive, .anchorsMatchLines])?.lowerBound ?? string.endIndex
        defer { string.removeSubrange(..<endIndex) }
        return try parseContent(from: String(string[..<endIndex]))
    }
    
    private static func parseSections(from string: inout String) throws -> [String: [String: Any]] {
        defer { string.removeAll() }
        let matches = try string.matchGroups(ofPattern: "\\[([^\\]]+)\\]\\n([^^\\[]*)", options: [.caseInsensitive, .anchorsMatchLines])
        return try Dictionary(matches.map {
            guard $0.count == 3 else { throw IniError.malformedData($0.joined()) }
            return ($0[1], $0[2])
        }) { $0 + $1 }.mapValues { try parseContent(from: $0) }
    }
    
    private static func parseContent(from string: String) throws -> [String: Any] {
        return try Dictionary(string.split(separator: "\n").map {
            var keyValue = $0.split(separator: "=", omittingEmptySubsequences: false)
            guard keyValue.count >= 2 else { throw IniError.malformedData(String($0)) }
            return (String(keyValue.removeFirst()), try parseValue(from: keyValue.joined(separator: "=")))
        }) { _, second in second } // the latter overwrites previous keys
    }

    private static func parseValue(from string: String) throws -> Any {
        guard !string.isEmpty else { return nil as Optional<Any> as Any }

        if string.isEnclosed(in: "\"") { // Definitively a String
            return try parseString(from: string)
        }
        if string.isEnclosed(in: "[", and: "]") {
            return try parseArray(from: string)
        }
        return try parseBool(from: string) ?? parseNumber(from: string) ?? parseString(from: string)
    }

    private static func parseString(from string: String) throws -> String {
        let trimmed = string.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        return trimmed.hasSuffix("\\") ? trimmed + "\"" : trimmed
    }

    private static func parseArray(from string: String) throws -> Array<Any> {
        let trimmed = string[string.index(after: string.startIndex)..<string.index(before: string.endIndex)]
        return try trimmed.split(separator: ",").map { try parseValue(from: String($0.trimmingCharacters(in: .whitespaces))) }
    }

    private static func parseBool(from string: String) throws -> Bool? {
        switch string.lowercased() {
        case "true":  return true
        case "false": return false
        default: return nil
        }
    }

    private static func parseNumber(from string: String) throws -> NSNumber? {
        return NumberFormatter.iniFormatter.number(from: string)
    }
}

fileprivate extension String {
    func replacing<P: StringProtocol, T: StringProtocol, R: RangeExpression>(pattern: P, with replacement: T,
                                                                             options: NSRegularExpression.Options = [],
                                                                             matchingOptions: NSRegularExpression.MatchingOptions = [],
                                                                             searchRange: R) throws -> String where R.Bound == Index {
        let regularExpression = try NSRegularExpression(pattern: String(pattern), options: options)
        return regularExpression.stringByReplacingMatches(in: self, options: matchingOptions,
                                                          range: NSRange(searchRange, in: self),
                                                          withTemplate: String(replacement))
    }
    
    func replacing<P: StringProtocol, T: StringProtocol>(pattern: P, with replacement: T,
                                                         options: NSRegularExpression.Options = [],
                                                         matchingOptions: NSRegularExpression.MatchingOptions = []) throws -> String {
        return try replacing(pattern: pattern, with: replacement, options: options, matchingOptions: matchingOptions, searchRange: UnboundedRange())
    }
    
    func firstRange<P: StringProtocol, R: RangeExpression>(ofPattern pattern: P,
                                                           options: NSRegularExpression.Options = [],
                                                           matchingOptions: NSRegularExpression.MatchingOptions = [],
                                                           searchRange: R) throws -> Range<Index>? where R.Bound == Index {
        let regularExpression = try NSRegularExpression(pattern: String(pattern), options: options)
        let nsRange = regularExpression.rangeOfFirstMatch(in: self, options: matchingOptions, range: NSRange(searchRange, in: self))
        return Range(nsRange, in: self)
    }
    
    func firstRange<P: StringProtocol>(ofPattern pattern: P,
                                       options: NSRegularExpression.Options = [],
                                       matchingOptions: NSRegularExpression.MatchingOptions = []) throws -> Range<Index>? {
        return try firstRange(ofPattern: pattern, options: options, matchingOptions: matchingOptions, searchRange: UnboundedRange())
    }
    
    func matchGroups<P: StringProtocol, R: RangeExpression>(ofPattern pattern: P,
                                                            options: NSRegularExpression.Options = [],
                                                            matchingOptions: NSRegularExpression.MatchingOptions = [],
                                                            searchRange: R) throws -> [[String]] where R.Bound == Index {
        let regularExpression = try NSRegularExpression(pattern: String(pattern), options: options)
        return regularExpression.matches(in: self, options: matchingOptions, range: NSRange(searchRange, in: self)).map { match in
            (0..<match.numberOfRanges).flatMap { Range<Index>(match.range(at: $0), in: self) }.map { String(self[$0]) }
        }
    }
    
    func matchGroups<P: StringProtocol>(ofPattern pattern: P,
                                        options: NSRegularExpression.Options = [],
                                        matchingOptions: NSRegularExpression.MatchingOptions = []) throws -> [[String]] {
        return try matchGroups(ofPattern: pattern, options: options, matchingOptions: matchingOptions, searchRange: UnboundedRange())
    }

    func matches<P: StringProtocol, R: RangeExpression>(pattern: P,
                                    options: NSRegularExpression.Options = [],
                                    matchingOptions: NSRegularExpression.MatchingOptions = [],
                                    searchRange: R) throws -> Bool where R.Bound == Index {
        let regularExpression = try NSRegularExpression(pattern: String(pattern), options: options)
        return regularExpression.firstMatch(in: self, options: matchingOptions, range: NSRange(searchRange, in: self)) != nil
    }

    func matches<P: StringProtocol>(pattern: P,
                                    options: NSRegularExpression.Options = [],
                                    matchingOptions: NSRegularExpression.MatchingOptions = []) throws -> Bool {
        return try matches(pattern: pattern, options: options, matchingOptions: matchingOptions, searchRange: UnboundedRange())
    }

    func isEnclosed<S: StringProtocol>(in prefix: S, and suffix: S) -> Bool {
        return hasPrefix(String(prefix)) && hasSuffix(String(suffix))
    }

    func isEnclosed<S: StringProtocol>(in string: S) -> Bool {
        return isEnclosed(in: string, and: string)
    }
}

fileprivate struct UnboundedRange<B: Comparable>: RangeExpression {
    typealias Bound = B
    
    init() {}
    
    func relative<C>(to collection: C) -> Range<Bound> where C : _Indexable, Bound == C.Index {
        return collection.startIndex..<collection.endIndex
    }
    
    func contains(_ element: Bound) -> Bool {
        return true
    }
}

fileprivate extension NumberFormatter {
    static let iniFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
