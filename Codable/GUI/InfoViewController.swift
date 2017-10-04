//
//  InfoViewController.swift
//  Codable
//
//  Created by Florian Friedrich on 02.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit
import CodableKit
import ParsINI

final class InfoViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private var info: Info? {
        didSet { tableView?.reloadData() }
    }

    private func parseInfo(from source: InfoSource) {
        do {
            let data = try Data(contentsOf: source.file)
            let decoder = source.makeDecoder()
            info = try decoder.decode(Info.self, from: data)
        } catch {
            showErrorAlert(for: error)
        }
    }

    // MARK: - UITableView
    @objc(numberOfSectionsInTableView:)
    dynamic func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    @objc dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3 // General info
        case 1: return info?.developers.count ?? 0 // Developers
        case 2: return 2 // Conference
        case 3: return 3 // Company
        case 4: return 2 // Demos
        default: return 0
        }
    }

    @objc(tableView:cellForRowAtIndexPath:)
    dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 1 ? "DeveloperCell" : "InfoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Title"
            cell.detailTextLabel?.text = info?.title ?? "N/A"
        case (0, 1):
            cell.textLabel?.text = "Copyright"
            cell.detailTextLabel?.text = info?.copyright ?? "N/A"
        case (0, 2):
            cell.textLabel?.text = "Year"
            cell.detailTextLabel?.text = info.map { "\($0.year)" } ?? "N/A"

        case (1, let row):
            cell.textLabel?.text = info?.developers[row]

        case (2, 0):
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = info?.conference.name ?? "N/A"
        case (2, 1):
            cell.textLabel?.text = "Is Anniversary"
            cell.detailTextLabel?.text = info.map { $0.conference.isAnniversary ? "🎉" : "😐" } ?? "N/A"

        case (3, 0):
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = info?.company.name ?? "N/A"
        case (3, 1):
            cell.textLabel?.text = "Founding Year"
            cell.detailTextLabel?.text = info.map { "\($0.company.foundingYear)" } ?? "N/A"
        case (3, 2):
            cell.textLabel?.text = "No. Employees"
            cell.detailTextLabel?.text = info.map { "\($0.company.employeeCount)" } ?? "N/A"

        case (4, 0):
            cell.textLabel?.text = "No. Demos"
            cell.detailTextLabel?.text = info?.demos.map { "\($0.demoCount)" } ?? "N/A"
        case (4, 1):
            cell.textLabel?.text = "Best Demo"
            cell.detailTextLabel?.text = info?.demos.map { "\($0.bestDemo)" } ?? "N/A"

        default:
            break
        }
        return cell
    }

    @objc dynamic func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Developers"
        case 2: return "Conference"
        case 3: return "Company"
        case 4: return "Demos"
        default: return nil
        }
    }
}

extension InfoViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        parseInfo(from: .json)
    }

    @IBAction func refresh(sender: Any?) {
        let picker = UIAlertController(title: "Source", message: "Select a source to parse the info from.", preferredStyle: .actionSheet)
        picker.addAction(UIAlertAction(title: "JSON", style: .default, handler: { [unowned self] _ in
            self.parseInfo(from: .json)
        }))
        picker.addAction(UIAlertAction(title: "INI", style: .default, handler: { [unowned self] _ in
            self.parseInfo(from: .ini)
        }))
        present(picker, animated: true, completion: nil)
    }
}

fileprivate extension InfoViewController {
    enum InfoSource {
        case json, ini

        var file: URL {
            switch self {
            case .json: return Bundle.main.url(forResource: "info", withExtension: "json")!
            case .ini: return Bundle.main.url(forResource: "info", withExtension: "ini")!
            }
        }

        func makeDecoder() -> InfoDecoder {
            switch self {
            case .json: return JSONDecoder()
            case .ini: return IniDecoder()
            }
        }
    }
}

fileprivate protocol InfoDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: InfoDecoder {}
extension IniDecoder: InfoDecoder {}
