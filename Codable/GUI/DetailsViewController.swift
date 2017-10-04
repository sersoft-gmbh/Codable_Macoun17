//
//  DetailsViewController.swift
//  Codable
//
//  Created by Florian Friedrich on 29.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit
import CodableKit

final class DetailsViewController: ViewController {
    @IBOutlet weak var showDiffButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var participantsScrollView: UIScrollView!
    @IBOutlet weak var participantsStackView: UIStackView!

    var jsonFile: JSONFile? {
        didSet { if isViewLoaded { parseJSON() } }
    }

    private var conference: Conference? {
        didSet { if isViewLoaded { updateContents() } }
    }

    private let jsonDecoder: JSONDecoder = {
        let coder = JSONDecoder()
        /* demo1.json
        coder.dateDecodingStrategy = .iso8601
        // */
        return coder
    }()

    private let jsonEncoder: JSONEncoder = {
        let coder = JSONEncoder()
        coder.outputFormatting = [.sortedKeys, .prettyPrinted]
        /* demo1.json
        coder.dateEncodingStrategy = .iso8601
        // */
        return coder
    }()

    private var currentDiff: Diff?
}

fileprivate extension Conference {
    private static let dateIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var dateRangeString: String {
        return ""
        /* demo1.json & demo2.json
        return type(of: self).dateIntervalFormatter.string(from: dateFrom, to: dateTo)
        // */
        /* demo3.json
        return type(of: self).dateIntervalFormatter.string(from: dateRange)
        // */
    }
}

// MARK: - Utilities
extension DetailsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        participantsScrollView.contentInset.top = 10
        showDiffButton.isEnabled = false
        nameLabel.text = nil
        durationLabel.text = nil
        participantsStackView.arrangedSubviews.forEach(participantsStackView.removeArrangedSubview)
        parseJSON()
    }

    private func parseJSON() {
        guard let json = jsonFile else { return }
        do {
            conference = try jsonDecoder.decode(Conference.self, from: Data(contentsOf: json.file))
        } catch {
            showErrorAlert(for: error)
        }
    }

    private func updateContents() {
        showDiffButton.isEnabled = conference != nil && jsonFile != nil
        nameLabel.text = conference?.name
        durationLabel.text = conference?.dateRangeString
        participantsStackView.arrangedSubviews.forEach(participantsStackView.removeArrangedSubview)
        conference?.participants.sorted(by: \.name).map(DeveloperView.init).forEach(participantsStackView.addArrangedSubview)
    }

    // MARK: Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "ShowDiff":
            guard let json = jsonFile, let conf = conference else { return false }
            do {
                let baseString = try String(contentsOf: json.file)
                let headString = try String(data: jsonEncoder.encode(conf), encoding: .utf8)
                currentDiff = headString.map { Diff(base: baseString, head: $0) }
            } catch {
                showErrorAlert(for: error)
            }
            return currentDiff != nil
        default:
            return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        defer { currentDiff = nil }
        if segue.identifier == "ShowDiff" {
            (segue.destination as? DiffViewController)?.diff = currentDiff
        }
    }
}

fileprivate extension Sequence {
    func sorted<T: Comparable>(by property: KeyPath<Element, T>, operator: (T, T) -> Bool = { $0 < $1 }) -> [Element] {
        return sorted(by: { `operator`($0[keyPath: property], $1[keyPath: property]) })
    }
}

fileprivate extension DateIntervalFormatter {
    func string(from range: Range<Date>) -> String {
        return string(from: range.lowerBound, to: range.upperBound)
    }
}
