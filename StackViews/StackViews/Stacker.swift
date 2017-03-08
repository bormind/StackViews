//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation


internal let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

internal enum SnappingOptions {
    case noSnap
    case snapToStart
    case snapToEnd
    case snapToBoth
}


internal func createView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
}

internal func meetTheParent(_ container: UIView) -> (UIView) -> () {

    return { view in
        assert(view.superview == nil || view.superview! == container, "Superview view mismatch!")

        if view.superview == nil {
            container.addSubview(view)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
    }
}


internal struct Stacker {
    let view: UIView
    let orientation: Orientation
    let insets: UIEdgeInsets
}

extension Stacker {
    func chainViews(
            _ snappingOptions: SnappingOptions,
            _ spacing: CGFloat,
            _ views: [UIView]) -> [NSLayoutConstraint] {

        if views.isEmpty {
            return []
        }

        var constraints:[NSLayoutConstraint] = []

        constraints += (0..<views.count - 1).reduce([]) { acc, i in
            return acc + [views[i + 1].chainTo(orientation, views[i], spacing)]
        }

        switch snappingOptions {
        case .snapToStart:
            constraints.append(views[0].snapToStart(orientation, self.view, insets.start(orientation)))
        case .snapToEnd:
            constraints.append(views[views.count - 1].snapToEnd(orientation, self.view, -insets.end(orientation)))
        case .snapToBoth:
            constraints.append(views[0].snapToStart(orientation, self.view, insets.start(orientation)))
            constraints.append(views[views.count - 1].snapToEnd(orientation, self.view, -insets.end(orientation)))
        case .noSnap:
            break
        }

        return constraints
    }

    func justifyViews( justify: Justify,
                        spacing: CGFloat,
                        views: [UIView]) -> ([NSLayoutConstraint], [UIView]) {

        var constraints: [NSLayoutConstraint] = []
        var generatedViews: [UIView] = []

        switch justify {
        case .start:
            constraints += chainViews(.snapToStart, spacing, views)
        case .fill:
            constraints += chainViews(.snapToBoth, spacing, views)
        case .end:
            constraints += chainViews(.snapToEnd, spacing, views)
        case .center:
            if views.count == 1 {
                constraints.append(views[0].snapToCenter(orientation, self.view))
            }
            else {
                let (allViews, spacers) = addViewsAround(views)
                generatedViews += spacers
                constraints += arrangeSpacerViews(spacers)
                constraints += chainViews(.snapToBoth, spacing, allViews)
            }
        case .spaceBetween:
            if views.count > 1 {
                let (allViews, spacers) = addViewsBetween(views)
                generatedViews += spacers
                constraints += arrangeSpacerViews(spacers)
                constraints += chainViews(.snapToBoth, spacing, allViews)
            }
        }

        return (constraints, generatedViews)
    }

    func alignViews(align: Alignment,
                    views: [UIView],
                    individualAlignments: [Alignment?]? = nil) -> [NSLayoutConstraint] {

        assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

        let constraints = (0..<views.count).reduce([]) { acc, i in
            return acc + self.alignView(views[i], individualAlignments?[i] ?? align)
        }

        return constraints
    }


    func alignView(_ view: UIView, _ alignment: Alignment) -> [NSLayoutConstraint] {

        let flippedOrientation = self.orientation.flip()
        switch alignment {
        case .start:
            return [view.snapToStart(flippedOrientation, self.view, self.insets.start(flippedOrientation))]
        case .center:
            return [view.snapToCenter(flippedOrientation, self.view)]
        case .end:
            return [view.snapToEnd(flippedOrientation, self.view, -self.insets.end(flippedOrientation))]
        case .fill:
            return [
                    view.snapToStart(flippedOrientation, self.view, self.insets.start(flippedOrientation)),
                    view.snapToEnd(flippedOrientation, self.view, -self.insets.end(flippedOrientation))
            ]
        }

    }

    func addViewsAround(_ views: [UIView]) -> ([UIView], [UIView]) {
        let outerViews = [createView(), createView()]
        outerViews.forEach(meetTheParent(self.view))

        let allViews = [outerViews[0]] + views + [outerViews[1]]

        return (allViews, outerViews)
    }

    func alignSpacerViews(_ views: [UIView]) -> [NSLayoutConstraint] {
        return views.map { $0.setDimension(self.orientation.flip(), 10) }
                + views.map { $0.snapToCenter(self.orientation.flip(), self.view) }

    }

    func arrangeSpacerViews(_ views: [UIView]) -> [NSLayoutConstraint] {

        let flexValues = [CGFloat](repeating: 1, count: views.count)
        let constraints =
                flexViews(orientation: self.orientation, views: views, flexValues: flexValues).0
                        + alignSpacerViews(views)

        return constraints
    }

    func addViewsBetween(_ views: [UIView]) -> ([UIView], [UIView]) {
        if views.count < 2 {
            return (views, [])
        }

        let spacerViews = (0..<views.count - 1).map { _ in createView() }
        spacerViews.forEach(meetTheParent(self.view))

        let allViews = (0..<spacerViews.count).reduce([views[0]]) { acc, i in
            return acc + [spacerViews[i], views[i + 1]]
        }

        return (allViews, spacerViews)
    }

}