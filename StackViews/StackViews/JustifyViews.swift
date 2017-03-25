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
        let snapToContainer = constraintSnap(orientation.flip(), container)

        let constraints = views.map { setViewDimension($0, 10) }
                        + views.map { snapToContainer($0, .center, 0) }

        guard views.count > 1 else {
            return constraints
        }

        let setSameRelativeDimension = constraintRelativeDimension(orientation, views[0])

        return constraints + (1..<views.count).map { setSameRelativeDimension(views[$0], 1) }

    }
}

fileprivate func snappingOptionsForJustifiedViews(_ justify: Justify, _ views: [UIView])
            -> [(UIView, SnapOption)] {

    let snapStart: (UIView, SnapOption) = (views[0], .start)
    let snapEnd: (UIView, SnapOption) = (views[views.count - 1], .end)
    let snapCenter: (UIView, SnapOption) = (views[0], .center)

    switch justify {
    case .start: return [snapStart]
    case .end: return [snapEnd]
    case .center:
        if views.count == 1 {
            return [snapCenter]
        } else {
            return [snapStart, snapEnd]
        }
    case .fill, .spaceBetween: return [snapStart, snapEnd]
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

        let snapToContainer = constraintSnap(orientation, container)
        let insetForSnapOption = insetForSnap(orientation, insets)
        let chain = constraintChain(orientation)

        let constraints = arrangeSpacerViews(orientation, container)(spacerViews)
            + snappingOptionsForJustifiedViews(justify, allViews)
                            .map { (view, snappingOption) in (view, snappingOption, insetForSnapOption(snappingOption)) }
                            .map (snapToContainer)
            + (0..<views.count - 1).map { chain(views[$0 + 1], views[$0], spacing) }

        return (constraints, spacerViews)
    }
}