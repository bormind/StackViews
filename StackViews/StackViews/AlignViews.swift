//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

fileprivate func snapOptionsForAlignment(_ alignment: Alignment) -> [SnapOption] {
    switch alignment {
    case .start: return [.start]
    case .center: return [.center]
    case .end: return [.end]
    case .fill: return [.start, .end]
    }
}


func alignViews(_ orientation: Orientation, _ container: UIView, _ insets: Insets)
                -> (Alignment, [UIView], [Alignment?]?)
                -> [NSLayoutConstraint] {

    return { (alignment, views, individualAlignments) in

        assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

        meetTheParent(container, views)

        let snapOrientation = orientation.flip()
        let snapToContainer = constraintSnap(snapOrientation, container)

        let snapInset = insetForSnap(snapOrientation, insets)

        let viewAlignment = { individualAlignments?[$0] ?? alignment }

        let snappingOptionsForIndex = { index in
            snapOptionsForAlignment(viewAlignment(index))
                .map { (views[index], $0, snapInset($0)) } // (View, SnapOption, CGFloat)
        }

        return (0..<views.count)
                    .flatMap(snappingOptionsForIndex)
                    .map(snapToContainer)

    }
}


