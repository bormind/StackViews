//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

enum Location {
    case start, center, end
}

enum Anchor {
    case top, left, bottom, right, centerX, centerY
}

struct ViewSnappingOption {
    let view: UIView
    let anchor: Anchor
    let constant: CGFloat
}

func anchorForLocation(_ orientation: Orientation)
                -> (Location)
                -> Anchor {

    return { location in
        switch (orientation, location) {
        case (.vertical, .start): return .top
        case (.horizontal, .start): return .left
        case (.vertical, .center): return .centerY
        case (.horizontal, .center): return .centerX
        case (.vertical, .end): return .bottom
        case (.horizontal, .end): return .right
        }
    }
}

func insetForAnchor(_ insets: Insets)
                -> (Anchor)
        -> CGFloat {

    return { edge in
        switch edge {
        case .top: return insets.top
        case .left: return insets.left
        case .bottom: return -insets.bottom
        case .right: return -insets.right
        case .centerX: return 0
        case .centerY: return 0
        }
    }
}

func createView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
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
