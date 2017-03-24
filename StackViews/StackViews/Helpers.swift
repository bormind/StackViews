//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

func insetForSnap(_ orientation: Orientation, _ insets: Insets)
            -> (SnapOption)
            -> CGFloat {

    return { snapOption in
        switch (orientation, snapOption) {
        case (.vertical, .start): return insets.top
        case (.horizontal, .start): return insets.left
        case (.vertical, .end): return -insets.bottom
        case (.horizontal, .end): return -insets.right
        case (.horizontal, .center): return 0
        case (.vertical, .center): return 0
        }
    }
}