//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

fileprivate func locationsForAlignment(_ alignment: Alignment) -> [Location] {
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
        let getAnchor = anchorForLocation(snapOrientation)
        let getInset = insetForAnchor(insets)
        let snapToParent = constraintSnap(container)

        let viewAlignment = { individualAlignments?[$0] ?? alignment }

        let getSnappingOptions = { (view: UIView, alignment:Alignment) -> [ViewSnappingOption] in
            return locationsForAlignment(alignment)
                    .map(getAnchor)
                    .map { ViewSnappingOption(view: view, anchor: $0, constant: getInset($0)) }
        }

        return (0..<views.count)
                    .map { (views[$0], viewAlignment($0)) }
                    .flatMap(getSnappingOptions)
                    .map(snapToParent)

    }
}


