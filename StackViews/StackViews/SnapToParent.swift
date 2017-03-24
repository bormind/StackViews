//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

func snapToParent(_ orientation: Orientation, _ view: UIView, _ snapOption: SnapOption) -> [NSLayoutConstraint] {
    return snapToParent(orientation, [view], [snapOption])
}

func snapToParent(_ orientation: Orientation, _ views: [UIView], _ snapOptions: [SnapOption]) -> [NSLayoutConstraint] {

    func snapOptionConstant(_ snapOption: SnapOption) -> CGFloat {
        switch (orientation, snapOption) {
        case (.vertical, .start): return insets.top
        case (.horizontal, .start): return insets.left
        case (.vertical, .end): return -insets.bottom
        case (.horizontal, .end): return -insets.right
        case (.horizontal, .center): return 0
        case (.vertical, .center): return 0
        }
    }

    return views.flatMap { view in
        snapOptions.map { view.snapTo(orientation, self.view, $0, snapOptionConstant($0)) }
    }
}