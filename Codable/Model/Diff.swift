//
//  Diff.swift
//  Codable
//
//  Created by Florian Friedrich on 04.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

struct Diff {
    enum Change: CustomStringConvertible {
        case unchanged, added, removed

        var description: String {
            switch self {
            case .unchanged: return "Unchanged"
            case .added: return "Added"
            case .removed: return "Removed"
            }
        }

        var changeSign: String {
            switch self {
            case .unchanged: return ""
            case .added: return "+"
            case .removed: return "-"
            }
        }

        func description(for changedElement: String) -> String {
            return "\(changeSign)\(changedElement)"
        }
    }

    let base: String
    let head: String
    let changes: [(String, Change)]

    init(base: String, head: String) {
        self.base = base
        self.head = head
        changes = base.split(separator: "\n").map(String.init).changes(comparedTo: head.split(separator: "\n").map(String.init))
    }
}

fileprivate extension Array where Element == String {
    func changes(comparedTo head: Array<String>) -> [(String, Diff.Change)] {
        var (arr1, arr2) = (self, head)
        var result: [(String, Diff.Change)] = []
        func apply(isAdded: Bool, at idx: Int, unchanged element: String) {
            let change: Diff.Change = isAdded ? .added : .removed
            let lines: ArraySlice<String>
            if isAdded {
                lines = arr2[..<idx]
                arr2.removeSubrange(..<idx)
            } else {
                lines = arr1[..<idx]
                arr1.removeSubrange(..<idx)
            }
            result.append(contentsOf: zip(lines, repeatElement(change, count: lines.count)))
            result.append((element, .unchanged))
        }
        while let a = arr1.first, let b = arr2.first {
            defer {
                arr1.removeFirst()
                arr2.removeFirst()
            }
            if a == b {
                result.append((a, .unchanged))
            } else if a.contains(b) || b.contains(a) {
                result.append(contentsOf: [(a, .removed), (b, .added)])
            } else if let idxA = arr2.dropFirst().index(of: a), let idxB = arr1.dropFirst().index(of: b) {
                let idx = Swift.min(idxA, idxB)
                apply(isAdded: idx == idxA, at: idx, unchanged: idx == idxA ? a : b)
            } else if let idx = arr2.dropFirst().index(of: a) {
                apply(isAdded: true, at: idx, unchanged: a)
            } else if let idx = arr1.dropFirst().index(of: b) {
                apply(isAdded: false, at: idx, unchanged: b)
            } else {
                result.append(contentsOf: [(a, .removed), (b, .added)])
            }
        }
        if !arr1.isEmpty || !arr2.isEmpty {
            result.append(contentsOf: zip(arr1, repeatElement(.removed, count: arr1.count)))
            result.append(contentsOf: zip(arr2, repeatElement(.added, count: arr2.count)))
        }
        return result
    }
}
