//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

func createView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
}

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

func meetTheParent(_ container: UIView, _ views: [UIView]) {

    views.forEach {
        assert($0.superview == nil || $0.superview! == container, "Superview view mismatch!")

        if $0.superview == nil {
            container.addSubview($0)
        }

        $0.translatesAutoresizingMaskIntoConstraints = false
    }
}
