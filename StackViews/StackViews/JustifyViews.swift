//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

fileprivate func createSpacerViewsIfNeeded(_ justify: Justify, _ views: [UIView])
                -> ([UIView], [UIView]) {
    switch justify {
    case .center where views.count > 1:
        return addViewsAround(views)
    case .spaceBetween where views.count > 1:
        return addViewsBetween(views)
    default:
        return (views, [])
    }
}

fileprivate func addViewsAround(_ views: [UIView]) -> ([UIView], [UIView]) {
    let outerViews = [createView(), createView()]
    let allViews = [outerViews[0]] + views + [outerViews[1]]
    return (allViews, outerViews)
}

fileprivate func addViewsBetween(_ views: [UIView]) -> ([UIView], [UIView]) {
    if views.count < 2 {
        return (views, [])
    }

    let spacerViews = (0..<views.count - 1).map { _ in createView() }

    let allViews = (0..<spacerViews.count).reduce([views[0]]) { acc, i in
        return acc + [spacerViews[i], views[i + 1]]
    }

    return (allViews, spacerViews)
}

fileprivate func arrangeSpacerViews(_ orientation: Orientation, _ container: UIView)
                    -> ([UIView])
                    -> [NSLayoutConstraint] {

    return { views in

        let setViewDimension = constraintDimension(orientation.flip())
        let constraintToContainer = constraintToCenters(container, anchorConstraintPriority)
        let anchor = getCenterAnchor(orientation)

        let constraints = views.map { setViewDimension($0, 10) }
                        + views.map {
                             constraintToContainer($0, anchor, 0)
                        }

        guard views.count > 1 else {
            return constraints
        }

        let setSameRelativeDimension = constraintRelativeDimension(orientation, views[0])

        return constraints + (1..<views.count).map { setSameRelativeDimension(views[$0], 1) }

    }
}

fileprivate func locationsToJustify(_ justify: Justify, _ viewCount: Int) -> [Location] {
    switch justify {
    case .start: return [.start]
    case .end: return [.end]
    case .center:
        if viewCount < 2 {
            return [.center]
        } else {
            return [.start, .end]
        }
    case .fill: return [.start, .end]
    case .spaceBetween: return [.start, .end]
    }
}

fileprivate func snappingOptionsForJustifiedViews(_ orientation: Orientation, _ justify: Justify, _ insets: Insets, _ views: [UIView])
            -> [(UIView, Anchor)] {

    guard !views.isEmpty else {
        return []
    }

    let getAnchor = anchorForLocation(orientation)


    let getViewForLocation = { (location: Location)->UIView in
        switch location {
        case .start: return views[0]
        case .center: return views[0]
        case .end: return views[views.count - 1]
        }
    }

    return locationsToJustify(justify,  views.count)
        .map { (getViewForLocation($0), getAnchor($0)) }
}

fileprivate func chainViews(_ orientation: Orientation, _ views: [UIView], _ spacing: CGFloat) -> [NSLayoutConstraint] {
    let chain = constraintChain(orientation, spacingConstraintPriority)

    return (0..<views.count - 1).map { chain(views[$0 + 1], views[$0], spacing) }
}

fileprivate func snapToContainer(_ orientation: Orientation, _ container: UIView, _ justify: Justify, _ insets: Insets)
                    -> ([UIView])
                    -> [NSLayoutConstraint] {

    let constraintToAnchor = constraintToAnchors(container, insets, anchorConstraintPriority)

    return { views in
        return snappingOptionsForJustifiedViews(orientation, justify, insets, views)
                .map(constraintToAnchor)
    }
}

func justifyViews(_ orientation: Orientation,
                  _ container: UIView,
                  _ insets: Insets,
                  _ spacing: CGFloat,
                  _ views: [UIView])

        -> (Justify)
        -> ([NSLayoutConstraint], [UIView]) {

    return { justify in

        guard !views.isEmpty else {
            return ([], [])
        }

        let (allViews, spacerViews) = createSpacerViewsIfNeeded(justify, views)
        meetTheParent(container, spacerViews)

        let doArrangeSpacerViews = arrangeSpacerViews(orientation, container)
        let doSnapToContainer = snapToContainer(orientation, container, justify, insets)

        let constraints = doArrangeSpacerViews(spacerViews)
                            + doSnapToContainer(allViews)
                            + chainViews(orientation, allViews, spacing)

        return (constraints, spacerViews)
    }
}