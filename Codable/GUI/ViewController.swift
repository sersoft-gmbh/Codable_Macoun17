//
//  ViewController.swift
//  Codable
//
//  Created by Florian Friedrich on 03.10.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Errors
    final func showErrorAlert(for error: Error, dismissOnCompletion: Bool = true) {
        let alert = UIAlertController(title: "Uh Oh", message: "Something went wrong:\n\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: !dismissOnCompletion ? nil : { [unowned self] _ in
            if let navController = self.navigationController {
                _ = navController.popViewController(animated: true)
            } else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}
