//
//  StackViews.swift
//  StackViews
//
//  Created by Boris Schneiderman on 2017-01-16.
//  Copyright © 2017 bormind. All rights reserved.
//

import Foundation


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

fileprivate func constraint<AnchorType>(_ lhs: NSLayoutAnchor<AnchorType>, to: NSLayoutAnchor<AnchorType>, _ const: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(equalTo: to, constant: const)
}


fileprivate func constraint(_ anch: NSLayoutDimension, toValue: CGFloat) -> NSLayoutConstraint {
    return anch.constraint(equalToConstant: toValue)
}

fileprivate let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"


public func setLeadingConstraint(_ orientation: Orientation, _ view: UIView, _ superview: UIView, _ insets: UIEdgeInsets) -> NSLayoutConstraint {
    switch orientation {
    case .horizontal:
        return constraint(view.leftAnchor, to: superview.leftAnchor, insets.left)
    case .vertical:
        return constraint(view.topAnchor, to: superview.topAnchor, insets.top)
    }
}

public func setTrailingConstraint(_ orientation: Orientation, _ view: UIView, _ superview: UIView, _ insets: UIEdgeInsets) -> NSLayoutConstraint {
    switch orientation {
    case .horizontal:
        return constraint(view.rightAnchor, to: superview.rightAnchor, -insets.right)
    case .vertical:
        return constraint(view.bottomAnchor, to: superview.bottomAnchor, -insets.bottom)
    }
}


//Returns tuple of new array of all the views and spacer views only
fileprivate func addViewsBetween(_ views: [UIView], _ inParent: UIView, _ orientation: Orientation) -> ([UIView], [UIView], [NSLayoutConstraint]) {
    if views.count < 2 {
        return (views, [], [])
    }

    let spacerViews = (0..<views.count - 1).map { _ in UIView() }
    spacerViews.forEach {
        inParent.addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let constraints = constraintSpacer(spacerViews, inParent, orientation)

    let allViews = (0..<spacerViews.count).reduce([views[0]]) { acc, i in
        return acc + [spacerViews[i], views[i + 1]]
    }

    return (allViews, spacerViews, constraints)
}

fileprivate func addViewsAround(_ views: [UIView], _ inParent: UIView, _ orientation: Orientation) -> ([UIView], [UIView], [NSLayoutConstraint]) {
    let outerViews = [UIView(), UIView()]
    outerViews.forEach {
        inParent.addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let constraints = constraintSpacer(outerViews, inParent, orientation)

    let allViews = [outerViews[0]] + views + [outerViews[1]]

    return (allViews, outerViews, constraints)
}

fileprivate func setAlignment(_ orientation: Orientation, _ view: UIView, _ superview: UIView, _ alignment: Alignment, _ insets: UIEdgeInsets) -> [NSLayoutConstraint] {
    switch (orientation, alignment) {
    case (.vertical, .start):
        return [constraint(view.leftAnchor, to: superview.leftAnchor, insets.left)]
    case (.vertical, .center):
        return [constraint(view.centerXAnchor, to: superview.centerXAnchor, 0)]
    case (.vertical, .end):
        return [constraint(view.rightAnchor, to: superview.rightAnchor, -insets.right)]
    case (.vertical, .fill):
        return [
            constraint(view.leftAnchor, to: superview.leftAnchor, insets.left),
            constraint(view.rightAnchor, to: superview.rightAnchor, -insets.right)
        ]
    case (.horizontal, .start):
        return [constraint(view.topAnchor, to: superview.topAnchor, insets.top)]
    case (.horizontal, .center):
        return [constraint(view.centerYAnchor , to: superview.centerYAnchor, 0)]
    case (.horizontal, .end):
        return [constraint(view.bottomAnchor, to: superview.bottomAnchor, -insets.bottom)]
    case (.horizontal, .fill):
        return [
                constraint(view.topAnchor, to: superview.topAnchor, insets.top),
                constraint(view.bottomAnchor, to: superview.bottomAnchor, -insets.bottom)
        ]
    }
}

fileprivate func alignmentToUse(_ orientation: Orientation, _ viewAlignment: Alignment?, _ defaultAlignment: Alignment?, _ crossDimension: CGFloat?) -> Alignment {
    if let viewAlignment = viewAlignment {
        return viewAlignment
    }

    if let defaultAlignment = defaultAlignment {
        return defaultAlignment
    }

    if let _ = crossDimension {
        return .center
    }

    //Usually controls like Labels and buttons have intrinsic height let center them vertically
    // For vertical staking lets stretch controls horizontally
    return orientation == .horizontal ? Alignment.center : Alignment.fill
}

fileprivate func setSpace(_ orientation: Orientation, _ v1: UIView, _ v2: UIView, _ value: CGFloat) -> NSLayoutConstraint {
    switch orientation {
    case .horizontal: return constraint(v2.leftAnchor, to: v1.rightAnchor, value)
    case .vertical: return constraint(v2.topAnchor, to: v1.bottomAnchor, value)
    }
}

fileprivate func hasIntrinsicWidth(_ view: UIView) -> Bool {
    return view.intrinsicContentSize.width != UIViewNoIntrinsicMetric
}

fileprivate func hasIntrinsicHeight(_ view: UIView) -> Bool {
    return view.intrinsicContentSize.height != UIViewNoIntrinsicMetric
}

fileprivate func getViewsWithUnsetDimensions(_ orientation: Orientation, _ views: [UIView], _ dimensions: [CGFloat?]?) -> [UIView] {
    assert(dimensions == nil || views.count == dimensions!.count)

    let hasIntrinsicDimension: (UIView) -> Bool
    switch orientation {
    case .horizontal: hasIntrinsicDimension =  hasIntrinsicWidth
    case .vertical: hasIntrinsicDimension = hasIntrinsicHeight
    }

    return (0..<views.count)
                .filter {
                    return dimensions?[$0] == nil && !hasIntrinsicDimension(views[$0])
                }
                .map { views[$0] }
}

fileprivate func constraintToCenter(_ orientation: Orientation) -> (UIView, UIView) -> NSLayoutConstraint {
    return { view, parentView in
        switch orientation {
        case .horizontal:
            return constraint(view.centerXAnchor, to: parentView.centerXAnchor, 0)
        case .vertical:
            return constraint(view.centerYAnchor, to: parentView.centerYAnchor, 0)
        }
    }
}

fileprivate func setSameDimensions(_ orientation: Orientation) -> ([UIView], UILayoutPriority?) -> [NSLayoutConstraint] {
    return { views, priority in
        switch orientation {
        case .horizontal:
            return setSameWidth(views: views, priority: priority)
        case .vertical:
            return setSameHeight(views: views, priority: priority)
        }
    }
}

fileprivate func constraintSpacer(_ spacers: [UIView], _ inParent: UIView, _ orientation: Orientation) -> [NSLayoutConstraint] {

    let setCenter = constraintToCenter(orientation.flip())
    let setCrossDimension: (UIView, CGFloat) -> NSLayoutConstraint

    switch orientation {
    case .horizontal:
        setCrossDimension = { view, val in view.heightAnchor.constraint(equalToConstant: val) }
    case .vertical:
        setCrossDimension = { view, val in view.widthAnchor.constraint(equalToConstant: val) }
    }

    return setSameDimensions(orientation)(spacers, nil)
            + spacers.map { setCrossDimension($0, 10) }
            + spacers.map { setCenter($0, inParent) }
}

//if both alignment and individualAlignments are provided than alignment will be used as a default if individualAlignments[i] == nil
public func alignViews(
        _ align: Alignment,
        orientation: Orientation,
        parentView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        views: [UIView],
        individualAlignments: [Alignment?]? = nil) -> StackingResult {

    assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

    let constraints = (0..<views.count).reduce([]) { acc, i in
        return acc + setAlignment(orientation, views[i], parentView, individualAlignments?[i] ?? align, insets)
    }

    return StackingResult(constraints: constraints)
}


public func chainViews(
        orientation: Orientation,
        views: [UIView],
        spacing: CGFloat = 0) -> [NSLayoutConstraint] {

    if views.count < 2 {
        return []
    }

    return (0..<views.count - 1).reduce([]) { acc, i in
        return acc + [setSpace(orientation, views[i], views[i + 1], spacing)]
    }
}

public func setWidths(views: [UIView], widths: [CGFloat?], priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {

    assert(widths.count == views.count, propertyCountMismatchMessage)

    let constraints =  widths
                            .enumerated()
                            .filter { $0.1 != nil }
                            .map { views[$0.0].widthAnchor.constraint(equalToConstant: $0.1!) }

    if let priority = priority {
        constraints.forEach { $0.priority = priority }
    }

    return constraints
}

public func setHeights(views: [UIView], heights: [CGFloat?], priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {

    assert(heights.count == views.count, propertyCountMismatchMessage)

    let constraints =   heights
                            .enumerated()
                            .filter { $0.1 != nil }
                            .map { views[$0.0].heightAnchor.constraint(equalToConstant: $0.1!) }

    if let priority = priority {
        constraints.forEach { $0.priority = priority }
    }

    return constraints
}

public func setSameWidth(views:[UIView], priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
    if views.count < 2 {
        return []
    }

    let constraints = (1..<views.count).map {
        return views[$0].widthAnchor.constraint(equalTo: views[0].widthAnchor)
    }

    if let priority = priority {
        constraints.forEach { $0.priority = priority }
    }

    return constraints
}

public func setSameHeight(views:[UIView], priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
    if views.count < 2 {
        return []
    }

    let constraints = (1..<views.count).map {
        return views[$0].heightAnchor.constraint(equalTo: views[0].heightAnchor)
    }

    if let priority = priority {
        constraints.forEach { $0.priority = priority }
    }

    return constraints
}



public func stackViews(
        orientation: Orientation,
        justify: Justify,
        align: Alignment,
        parentView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        spacing: CGFloat? = nil,
        views: [UIView],
        widths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        individualAlignments: [Alignment?]? = nil,
        activateConstrains: Bool = true) -> StackingResult {

    var result = StackingResult()

    if views.count == 0 {
        return result
    }

    views.forEach {
        if $0.superview == nil {
            parentView.addSubview($0)
        }

        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    if let widths = widths {
        result.constraints += setWidths(views: views, widths: widths)
    }

    if let heights = heights {
        result.constraints += setHeights(views: views, heights: heights)
    }

    let alongDimensions: [CGFloat?]?
    let crossDimensions: [CGFloat?]?

    switch orientation {
    case .horizontal:
        alongDimensions = widths
        crossDimensions = heights

    case .vertical:
        alongDimensions = heights
        crossDimensions = widths
    }

    switch justify {
    case .start:
        result.constraints.append(setLeadingConstraint(orientation, views[0], parentView, insets))
        result.constraints += chainViews(orientation: orientation, views: views, spacing: spacing ?? 0)
    case .fill:
        result.constraints.append(setLeadingConstraint(orientation, views[0], parentView, insets))
        result.constraints.append(setTrailingConstraint(orientation, views[views.count - 1], parentView, insets))
        result.constraints += chainViews(orientation: orientation, views: views, spacing: spacing ?? 0)
        let viewsWithUnsetDimensions = getViewsWithUnsetDimensions(orientation, views, alongDimensions)
        result.constraints += setSameDimensions(orientation)(viewsWithUnsetDimensions, nil)
    case .end:
        result.constraints.append(setTrailingConstraint(orientation, views[views.count - 1], parentView, insets))
        result.constraints += chainViews(orientation: orientation, views: views, spacing: spacing ?? 0)
    case .center:
        if views.count == 1 {
            result.constraints.append(constraintToCenter(orientation)(views[0], parentView))
        }
        else {
            let (allViews, spacers, constraints) = addViewsAround(views, parentView, orientation)
            result.generatedViews += spacers
            result.constraints += constraints
            result.constraints.append(setLeadingConstraint(orientation, allViews[0], parentView, insets))
            result.constraints.append(setTrailingConstraint(orientation, allViews[allViews.count - 1], parentView, insets))
            result.constraints += chainViews(orientation: orientation, views: allViews, spacing: spacing ?? 0)
        }
    case .spaceBetween:
        if views.count > 1 {
            let (allViews, spacers, constraints) = addViewsBetween(views, parentView, orientation)
            result.generatedViews += spacers
            result.constraints += constraints
            result.constraints.append(setLeadingConstraint(orientation, allViews[0], parentView, insets))
            result.constraints.append(setTrailingConstraint(orientation, allViews[allViews.count - 1], parentView, insets))
            result.constraints += chainViews(orientation: orientation, views: allViews, spacing: 0)
        }
    }

    result += alignViews(
            align,
            orientation: orientation,
            parentView: parentView,
            insets: insets,
            views: views,
            individualAlignments: individualAlignments)

    if activateConstrains && !result.constraints.isEmpty {
        NSLayoutConstraint.activate(result.constraints)
    }

    return result
}
