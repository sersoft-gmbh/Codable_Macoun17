//
//  DiffViewController.swift
//  Codable
//
//  Created by Florian Friedrich on 04.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit

final class DiffViewController: ViewController {
    @IBOutlet weak var diffTextView: UITextView!

    var diff: Diff? {
        didSet { if isViewLoaded { updateContents() } }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateContents()
    }

    private func updateContents() {
        diffTextView.attributedText = diff?.changes.reduce(into: NSMutableAttributedString()) {
            $0.append(NSAttributedString(string: $1.1.description(for: $1.0) + "\n", attributes: $1.1.attributes))
        }
    }
}

fileprivate extension Diff.Change {
    var attributes: [NSAttributedStringKey: Any] {
        switch self {
        case .unchanged:
            return [
                .font: UIFont(name: "Courier New", size: 14)!,
                .foregroundColor: UIColor.black,
                .backgroundColor: UIColor.clear
            ]
        case .added:
            return [
                .font: UIFont(name: "Courier New", size: 14)!,
                .foregroundColor: UIColor(named: "AddedLine")!,
                .backgroundColor: UIColor(named: "AddedLineBG")!
            ]
        case .removed:
            return [
                .font: UIFont(name: "Courier New", size: 14)!,
                .foregroundColor: UIColor(named: "RemovedLine")!,
                .backgroundColor: UIColor(named: "RemovedLineBG")!
            ]
        }
    }
}
