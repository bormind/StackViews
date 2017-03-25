//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

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
        let getAnchor = anchorForLocation(orientation.flip())

        let snapToContainer = constraintSnap(container)

        let constraints = views.map { setViewDimension($0, 10) }
                        + views.map {
                             snapToContainer(ViewSnappingOption(view: $0, anchor: getAnchor(.center), constant: 0))
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
            -> [ViewSnappingOption] {

    guard !views.isEmpty else {
        return []
    }

    let getAnchor = anchorForLocation(orientation)
    let getInset = insetForAnchor(insets)

    let getViewForLocation = { (location: Location)->UIView in
        switch location {
        case .start: return views[0]
        case .center: return views[0]
        case .end: return views[views.count - 1]
        }
    }

    return locationsToJustify(justify,  views.count)
        .map { (getViewForLocation($0), getAnchor($0)) }
        .map { ViewSnappingOption(view: $0.0, anchor: $0.1, constant: getInset($0.1)) }
}

fileprivate func chainViews(_ orientation: Orientation, _ views: [UIView], _ spacing: CGFloat) -> [NSLayoutConstraint] {
    let chain = constraintChain(orientation)

    return (0..<views.count - 1).map { chain(views[$0 + 1], views[$0], spacing) }
}

fileprivate func snapToContainer(_ orientation: Orientation, _ container: UIView, _ justify: Justify, _ insets: Insets)
                    -> ([UIView])
                    -> [NSLayoutConstraint] {

    let doSnapToContainer = constraintSnap(container)

    return { views in
        return snappingOptionsForJustifiedViews(orientation, justify, insets, views)
                .map(doSnapToContainer)
    }
}

func justifyViews(_ orientation: Orientation, _ container: UIView, _ insets: Insets)
        -> (Justify, [UIView], CGFloat)
        -> ([NSLayoutConstraint], [UIView]) {

    return { (justify, views, spacing) in

        guard !views.isEmpty else {
            return ([], [])
        }

        let (allViews, spacerViews) = createSpacerViewsIfNeeded(justify, views)
        meetTheParent(container, allViews)

        let doArrangeSpacerViews = arrangeSpacerViews(orientation, container)
        let doSnapToContainer = snapToContainer(orientation, container, justify, insets)

        let constraints = doArrangeSpacerViews(spacerViews)
                            + doSnapToContainer(allViews)
                            + chainViews(orientation, allViews, spacing)

        return (constraints, spacerViews)
    }
}