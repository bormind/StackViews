//
//  StackViews.swift
//  StackViews
//
//  Created by Boris Schneiderman on 2017-01-16.
//  Copyright © 2017 bormind. All rights reserved.
//

import Foundation


fileprivate extension UIEdgeInsets {
    var leading: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
            ? self.left
            : self.right
    }

    var trailing: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
                ? self.right
                : self.left
    }

    func start(_ orientation: Orientation) -> CGFloat {
        switch orientation {
        case .horizontal:
            return self.leading
        case .vertical:
            return self.top
        }
    }

    func end(_ orientation: Orientation) -> CGFloat {
        switch orientation {
        case .horizontal:
            return self.trailing
        case .vertical:
            return self.bottom
        }
    }
}

public enum Orientation {
    case horizontal
    case vertical

    func flip() -> Orientation {
        switch self {
        case .horizontal: return .vertical
        case.vertical: return .horizontal
        }
    }
}

public enum Alignment {
    case fill
    case start
    case center
    case end
}

public enum Justify {
    case fill
    case start
    case end
    case spaceBetween
    case center
}

public struct StackingResult {
    public var constraints: [NSLayoutConstraint]
    public var generatedViews: [UIView]
    public var errors: [String]

    init(constraints: [NSLayoutConstraint] = [], generatedViews: [UIView] = [], errors: [String] = []) {
        self.constraints = constraints
        self.generatedViews = generatedViews
        self.errors = errors
    }
}

public extension StackingResult {
    public mutating func clearConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        generatedViews.forEach{ $0.removeFromSuperview() }
        constraints = []
        generatedViews = []
        errors = []
    }
}

infix operator  += { associativity left precedence 140 }
func +=( lhs: inout StackingResult, rhs: StackingResult) {
    lhs.constraints += rhs.constraints
    lhs.generatedViews += rhs.generatedViews
    lhs.errors += rhs.errors
}


fileprivate extension UIView {

    func chainTo(_ orientation: Orientation, _ view: UIView, _ constant: CGFloat) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
        case .vertical: return self.topAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
        }
    }

    func snapToStart(_ orientation: Orientation, _ view: UIView, _ constant: CGFloat) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant)
        case .vertical: return self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant)
        }
    }

    func snapToEnd(_ orientation: Orientation, _ view: UIView, _ constant: CGFloat) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
        case .vertical: return self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
        }
    }

    func snapToCenter(_ orientation: Orientation, _ view: UIView) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        case .vertical: return self.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        }
    }

    func setDimension(_ orientation: Orientation, _ constant: CGFloat) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.widthAnchor.constraint(equalToConstant: constant)
        case .vertical: return self.heightAnchor.constraint(equalToConstant: constant)
        }
    }

    func sameDimension(_ orientation: Orientation, _ view: UIView, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        switch orientation {
        case .horizontal: return self.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
        case .vertical: return self.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier)
        }
    }
}


fileprivate let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

fileprivate enum SnappingOptions {
    case noSnap
    case snapToStart
    case snapToEnd
    case snapToBoth
}



//private helper functions
extension UIView {
    fileprivate func meetTheParent(_ view: UIView) {
        assert(view.superview == nil || view.superview! == self, "Superview view mismatch!")

        if view.superview == nil {
            self.addSubview(view)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func alignSpacerViews(_ orientation: Orientation, _ views: [UIView]) -> [NSLayoutConstraint] {
        return views.map { $0.setDimension(orientation.flip(), 10) }
             + views.map { $0.snapToCenter(orientation.flip(), self) }

    }

    fileprivate func arrangeSpacerViews(_ orientation: Orientation, _ views: [UIView]) -> [NSLayoutConstraint] {

        let flexValues = [CGFloat](repeating: 1, count: views.count)
        return
            flexViews(orientation: orientation, views: views, flexValues: flexValues)
            + alignSpacerViews(orientation, views)

    }

    fileprivate func chainViews(
            _ snappingOptions: SnappingOptions,
            _ orientation: Orientation,
            _ insets: UIEdgeInsets,
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
            constraints.append(views[0].snapToStart(orientation, self, insets.start(orientation)))
        case .snapToEnd:
            constraints.append(views[views.count - 1].snapToEnd(orientation, self, -insets.end(orientation)))
        case .snapToBoth:
            constraints.append(views[0].snapToStart(orientation, self, insets.start(orientation)))
            constraints.append(views[views.count - 1].snapToEnd(orientation, self, -insets.end(orientation)))
        case .noSnap:
            break
        }

        return constraints
    }


    fileprivate func alignView(_ orientation: Orientation,
                                _ alignment: Alignment,
                                _ view: UIView,
                                _ insets: UIEdgeInsets) -> [NSLayoutConstraint] {

        let flippedOrientation = orientation.flip()
        switch alignment {
        case .start:
            return [view.snapToStart(flippedOrientation, self, insets.start(flippedOrientation))]
        case .center:
            return [view.snapToCenter(flippedOrientation, self)]
        case .end:
            return [view.snapToEnd(flippedOrientation, self, -insets.end(flippedOrientation))]
        case .fill:
            return [
                    view.snapToStart(flippedOrientation, self, insets.start(flippedOrientation)),
                    view.snapToEnd(flippedOrientation, self, -insets.end(flippedOrientation))
            ]
        }
    }



    fileprivate func addViewsAround(_ views: [UIView], _ orientation: Orientation) -> ([UIView], [UIView]) {
        let outerViews = [UIView(), UIView()]
        outerViews.forEach(meetTheParent)


        let allViews = [outerViews[0]] + views + [outerViews[1]]

        return (allViews, outerViews)
    }

    fileprivate func addViewsBetween(_ views: [UIView], _ orientation: Orientation) -> ([UIView], [UIView]) {
        if views.count < 2 {
            return (views, [])
        }

        let spacerViews = (0..<views.count - 1).map { _ in UIView() }
        spacerViews.forEach(meetTheParent)

        let allViews = (0..<spacerViews.count).reduce([views[0]]) { acc, i in
            return acc + [spacerViews[i], views[i + 1]]
        }

        return (allViews, spacerViews)
    }

}

//public functions
public func flexViews(orientation: Orientation, views:[UIView], flexValues:[CGFloat], keyIndex: Int = 0, priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
    assert(views.count == flexValues.count)
    if views.count < 2 {
        return []
    }

    let keyFlexVal = flexValues[keyIndex]

    return (0..<views.count)
            .filter { $0 != keyIndex }
            .map {
                return views[$0].sameDimension(orientation, views[keyIndex], multiplier: flexValues[$0] / keyFlexVal)
            }
}


public extension UIView {

    public func justifyViews(_ justify: Justify,
                             orientation: Orientation,
                             insets: UIEdgeInsets = UIEdgeInsets.zero,
                             spacing: CGFloat = 0,
                             views: [UIView]) -> StackingResult {

        views.forEach(self.meetTheParent)

        var constraints: [NSLayoutConstraint] = []
        var generatedViews: [UIView] = []

        switch justify {
        case .start:
            constraints += chainViews(.snapToStart, orientation, insets, spacing, views)
        case .fill:
            constraints += chainViews(.snapToBoth, orientation, insets, spacing, views)
        case .end:
            constraints += chainViews(.snapToEnd, orientation, insets, spacing, views)
        case .center:
            if views.count == 1 {
                constraints.append(views[0].snapToCenter(orientation, self))
            }
            else {
                let (allViews, spacers) = addViewsAround(views, orientation)
                generatedViews += spacers
                constraints += arrangeSpacerViews(orientation, spacers)
                constraints += chainViews(.snapToBoth, orientation, insets, spacing, allViews)
            }
        case .spaceBetween:
            if views.count > 1 {
                let (allViews, spacers) = addViewsBetween(views, orientation)
                generatedViews += spacers
                constraints += arrangeSpacerViews(orientation, spacers)
                constraints += chainViews(.snapToBoth, orientation, insets, spacing, allViews)
            }
        }

        return StackingResult(constraints: constraints, generatedViews: generatedViews)
    }

    public func alignViews(
            _ align: Alignment,
            orientation: Orientation,
            insets: UIEdgeInsets = UIEdgeInsets.zero,
            views: [UIView],
            individualAlignments: [Alignment?]? = nil) -> StackingResult {

        assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

        views.forEach(self.meetTheParent)

        let constraints = (0..<views.count).reduce([]) { acc, i in
            return acc + alignView(orientation, individualAlignments?[i] ?? align, views[i], insets)
        }

        return StackingResult(constraints: constraints)
    }


    public func stackViews(
            orientation: Orientation,
            justify: Justify,
            align: Alignment,
            insets: UIEdgeInsets = UIEdgeInsets.zero,
            spacing: CGFloat = 0,
            views: [UIView],
            widths: [CGFloat?]? = nil,
            heights: [CGFloat?]? = nil,
            flex:[CGFloat?]? = nil,
            individualAlignments: [Alignment?]? = nil,
            activateConstrains: Bool = true) -> StackingResult {

        var result = StackingResult()

        if views.count == 0 {
            return result
        }

        views.forEach(self.meetTheParent)

        if let widths = widths {
            result.constraints +=  (0..<views.count)
                    .filter { widths[$0] != nil }
                    .map { views[$0].widthAnchor.constraint(equalToConstant: widths[$0]!) }

        }

        if let heights = heights {
            result.constraints +=  (0..<views.count)
                    .filter { heights[$0] != nil }
                    .map { views[$0].heightAnchor.constraint(equalToConstant: heights[$0]!) }
        }

        result += justifyViews(
                justify, orientation:
                orientation,
                insets: insets,
                spacing: spacing,
                views: views)

        result += alignViews(
                align,
                orientation: orientation,
                insets: insets,
                views: views,
                individualAlignments: individualAlignments)

        if activateConstrains && !result.constraints.isEmpty {
            NSLayoutConstraint.activate(result.constraints)
        }

        return result
    }

}

