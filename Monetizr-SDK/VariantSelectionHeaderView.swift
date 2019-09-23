//
//  VariantSelectionHeaderView.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 22/09/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

class VariantSelectionHeaderView: UITableViewHeaderFooterView {
    let title = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .lightGray
        title.font = .systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        self.contentView.backgroundColor = UIColor(hex: 0x121212)

        contentView.addSubview(title)

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
