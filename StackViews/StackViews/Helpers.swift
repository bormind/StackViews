//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

enum Location {
    case start, center, end
}



func anchorForLocation(_ orientation: Orientation)
                -> (Location)
                -> Anchor {

    return { location in
        switch (orientation, location) {
        case (.vertical, .start): return Anchor(.top)
        case (.horizontal, .start): return Anchor(.left)
        case (.vertical, .center): return Anchor(.centerY)
        case (.horizontal, .center): return Anchor(.centerX)
        case (.vertical, .end): return Anchor(.bottom)
        case (.horizontal, .end): return Anchor(.right)
        }
    }
}

func getCenterAnchor(_ orientation: Orientation) -> CenterAnchor {
    switch orientation.flip() {
    case .horizontal: return .centerX
    case .vertical: return .centerY
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
