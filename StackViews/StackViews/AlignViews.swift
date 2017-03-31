//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

fileprivate func locationsForAlignment(_ alignment: Alignment) -> [Location] {
    switch alignment {
    case .start: return [.start]
    case .center: return [.center]
    case .end: return [.end]
    case .fill: return [.start, .end]
    }
}


func alignViews(_ orientation: Orientation, _ container: UIView, _ insets: Insets)
                -> (Alignment?, [UIView], [Alignment?]?)
                -> [NSLayoutConstraint] {

    let constraintToAnchor = constraintToAnchors(container, insets, anchorConstraintPriority)

    return { (alignment, views, individualAlignments) in

        assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

        let snapOrientation = orientation.flip()
        let getAnchor = anchorForLocation(snapOrientation)

        let viewAlignment = { individualAlignments?[$0] ?? alignment }

        let pairViewsAndAnchors = { (view: UIView, alignment:Alignment) -> [(UIView, Anchor)] in
            return locationsForAlignment(alignment)
                    .map(getAnchor)
                    .map { (view, anchor: $0) }
        }


        return (0..<views.count)
                    .filter { viewAlignment($0) != nil }
                    .map { (views[$0], viewAlignment($0)!) }
                    .flatMap(pairViewsAndAnchors)
                    .map(constraintToAnchor)

    }
}


