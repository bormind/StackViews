//
// Created by Boris Schneiderman on 2017-01-28.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews


class MenuTableCell: UITableViewCell {

    let label = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

//        label.backgroundColor = UIColor.orange
//        label.textColor = UIColor.black

        self.contentView.stackViews(
                orientation: .horizontal,
                justify: .fill,
                align: .center,
                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                views: [label])
    }

    func setMenuItem(text: String) {
        label.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}