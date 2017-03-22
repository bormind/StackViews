//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation


internal let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"


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

internal enum SnapOption {
    case start
    case end
    case center

}



internal struct Stacker {
    let view: UIView
    let orientation: Orientation
    let insets: Insets
}

extension Stacker {

    func snapToParent(_ orientation: Orientation, _ view: UIView, _ snapOption: SnapOption) -> [NSLayoutConstraint] {
        return snapToParent(orientation, [view], [snapOption])
    }

    func snapToParent(_ orientation: Orientation, _ views: [UIView], _ snapOptions: [SnapOption]) -> [NSLayoutConstraint] {

        func snapOptionConstant(_ snapOption: SnapOption) -> CGFloat {
            switch (orientation, snapOption) {
            case (.vertical, .start): return insets.top
            case (.horizontal, .start): return insets.left
            case (.vertical, .end): return -insets.bottom
            case (.horizontal, .end): return -insets.right
            case (.horizontal, .center): return 0
            case (.vertical, .center): return 0
            }
        }

        return views.flatMap { view in
            snapOptions.map { view.snapTo(orientation, self.view, $0, snapOptionConstant($0)) }

        }
    }

    func chainViews(_ views: [UIView], _ spacing: CGFloat) -> [NSLayoutConstraint] {
        return (0..<views.count - 1).reduce([]) { acc, i in
            return acc + [views[i + 1].chainTo(orientation, views[i], spacing)]
        }
    }

    func justifyViews( justify: Justify,
                        spacing: CGFloat,
                        views: [UIView]) -> ([NSLayoutConstraint], [UIView]) {

        guard !views.isEmpty else {
            return ([], [])
        }

        var constraints: [NSLayoutConstraint] = []
        var generatedViews: [UIView] = []

        switch justify {
        case .start:
            constraints += snapToParent(self.orientation, views.first!, .start)
            constraints += chainViews(views, spacing)
        case .fill:
            constraints += snapToParent(self.orientation, views.first!, .start)
            constraints += chainViews(views, spacing)
            constraints += snapToParent(self.orientation, views.last!, .end)
        case .end:
            constraints += chainViews(views, spacing)
            constraints += snapToParent(self.orientation, views.last!, .end)
        case .center:
            if views.count == 1 {
                constraints += snapToParent(self.orientation, views.first!, .center)
            }
            else {
                let (allViews, spacers) = addViewsAround(views)
                generatedViews += spacers
                constraints += arrangeSpacerViews(spacers)
                constraints += snapToParent(self.orientation, allViews.first!, .start)
                constraints += chainViews(allViews, spacing)
                constraints += snapToParent(self.orientation, allViews.last!, .end)
            }
        case .spaceBetween:
            constraints += snapToParent(self.orientation, views.first!, .start)
            constraints += snapToParent(self.orientation, views.last!, .end)

            if views.count > 1 {
                let (allViews, spacers) = addViewsBetween(views)
                generatedViews += spacers
                constraints += arrangeSpacerViews(spacers)
                constraints += chainViews(allViews, 0)
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

        switch alignment {
        case .start:
            return snapToParent(self.orientation.flip(), view, .start)
        case .center:
            return snapToParent(self.orientation.flip(), view, .center)
        case .end:
            return snapToParent(self.orientation.flip(), view, .end)
        case .fill:
            return snapToParent(self.orientation.flip(), [view], [.start, .end])
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
                + views.map { $0.snapTo(self.orientation.flip(), self.view, .center, 0) }

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