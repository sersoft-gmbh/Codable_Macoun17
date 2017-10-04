//
//  ListViewController.swift
//  Codable
//
//  Created by Florian Friedrich on 16.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit
import CodableKit

final class ListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowDetails", let indexPath = tableView?.indexPathForSelectedRow {
            (segue.destination as? DetailsViewController)?.jsonFile = JSONFile.allFiles[indexPath.row]
        }
    }

    // MARK: - UITableView
    @objc(numberOfSectionsInTableView:)
    dynamic func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc dynamic func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JSONFile.allFiles.count
    }

    @objc(tableView:cellForRowAtIndexPath:)
    dynamic func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JSONCell", for: indexPath)
        cell.textLabel?.text = JSONFile.allFiles[indexPath.row].name
        return cell
    }

    @objc dynamic func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else { return nil }
        return "Demo JSON Files"
    }

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let ip = tableView?.indexPathForSelectedRow {
            tableView?.deselectRow(at: ip, animated: animated)
        }
    }

    // MARK: - Unwinding Segue
    @IBAction func unwindToJSONList(segue: UIStoryboardSegue) {}
}
