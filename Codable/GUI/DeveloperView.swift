//
//  DeveloperView.swift
//  Codable
//
//  Created by Florian Friedrich on 29.09.17.
//  Copyright © 2017 ser.soft GmbH. All rights reserved.
//

import UIKit
import CodableKit

final class DeveloperView: UIStackView {

    let idLabel = UILabel(textStyle: .caption1)
    let nameLabel = UILabel(textStyle: .body)
    let developerLabel = UILabel(textStyle: .caption1)
    let companyLabel = UILabel(textStyle: .footnote)

    private func configure(with developer: Developer) {
        idLabel.text = "\(developer.id)"
        nameLabel.text = developer.name
        developerLabel.text = developer.isSpeaker ? "📢" : nil
        companyLabel.text = nil
        /* demo1.json
        companyLabel.text = developer.company ?? "-"
        // */
    }

    init(developer: Developer) {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 5
        distribution = .fill
        alignment = .center
        let firstLineStackView = UIStackView(arrangedSubviews: [idLabel, nameLabel, developerLabel])
        firstLineStackView.spacing = 8
        firstLineStackView.distribution = .equalCentering
        firstLineStackView.alignment = .center
        addArrangedSubview(firstLineStackView)
        addArrangedSubview(companyLabel)
        configure(with: developer)
    }

    required init(coder: NSCoder) { super.init(coder: coder) }
}

fileprivate extension UILabel {
    convenience init(textStyle: UIFontTextStyle) {
        self.init()
        font = .preferredFont(forTextStyle: textStyle)
    }
}
