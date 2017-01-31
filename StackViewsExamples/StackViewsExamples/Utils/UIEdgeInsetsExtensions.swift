//
// Created by Boris Schneiderman on 2017-01-30.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

extension UIEdgeInsets {

    init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func create(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

