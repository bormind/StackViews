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
        case .vertical: return .horizontal
        }
    }
}

public enum Alignment {
    case start(CGFloat)
    case center(CGFloat)
    case end(CGFloat)
    case stretch
}

public enum Justify {
    case stretch
    case start
    case end
    case distribute
}

fileprivate func constraint<AnchorType>(_ lhs: NSLayoutAnchor<AnchorType>, to: NSLayoutAnchor<AnchorType>, _ const: CGFloat) -> NSLayoutConstraint {
    return lhs.constraint(equalTo: to, constant: const)
}


fileprivate func constraint(_ anch: NSLayoutDimension, toValue: CGFloat) -> NSLayoutConstraint {
    return anch.constraint(equalToConstant: toValue)
}

fileprivate let propertyCountMismatchMessage = "Child view properties should be provided for each view in the array, nil can be used to indicate use of container wide defaults"

fileprivate func getAxisDimensions(_ orientation: Orientation, _ widths: [CGFloat?]?, _ heights: [CGFloat?]?, _ viewCount: Int) -> ([CGFloat?]?, [CGFloat?]?) {
    switch orientation {
    case .horizontal: return (widths, heights)
    case .vertical: return (heights, widths)
    }
}

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

fileprivate func setAlignment(_ alignmentOrientation: Orientation, _ view: UIView, _ superview: UIView, _ alignment: Alignment, _ insets: UIEdgeInsets) -> [NSLayoutConstraint] {
    switch (alignmentOrientation, alignment) {
    case (.horizontal, .start(let val)):
        return [constraint(view.leftAnchor, to: superview.leftAnchor, val + insets.left)]
    case (.horizontal, .center(let val)):
        return [constraint(view.centerXAnchor, to: superview.centerXAnchor, val)]
    case (.horizontal, .end(let val)):
        return [constraint(view.rightAnchor, to: superview.rightAnchor, -(val + insets.right))]
    case (.horizontal, .stretch):
        return [
            constraint(view.leftAnchor, to: superview.leftAnchor, insets.left),
            constraint(view.rightAnchor, to: superview.rightAnchor, -insets.right)
        ]
    case (.vertical, .start(let val)):
        return [constraint(view.topAnchor, to: superview.topAnchor, val + insets.top)]
    case (.vertical, .center(let val)):
        return [constraint(view.centerYAnchor , to: superview.centerYAnchor, val)]
    case (.vertical, .end(let val)):
        return [constraint(view.bottomAnchor, to: superview.bottomAnchor, -(val + insets.bottom))]
    case (.vertical, .stretch):
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
        return .center(0)
    }

    //Usually controls like Labels and buttons have intrinsic height let center them vertically
    // For vertical staking lets stretch controls horizontally
    return orientation == .horizontal ? Alignment.center(0) : Alignment.stretch
}

fileprivate func setSpace(_ orientation: Orientation, _ v1: UIView, _ v2: UIView, _ value: CGFloat) -> NSLayoutConstraint {
    switch orientation {
    case .horizontal: return constraint(v2.leftAnchor, to: v1.rightAnchor, value)
    case .vertical: return constraint(v2.topAnchor, to: v1.bottomAnchor, value)
    }
}

//if both alignment and individualAlignments are provided than alignment will be used as a default if individualAlignments[i] == nil
public func alignViews(
        alignmentOrientation: Orientation,
        parentView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        alignment: Alignment? = nil,
        views: [UIView],
        individualAlignments: [Alignment?]? = nil) -> [NSLayoutConstraint] {

    assert(alignment != nil || individualAlignments != nil, "Default alignment or individual individualAlignments should be provided")
    assert(individualAlignments == nil || individualAlignments!.count == views.count, propertyCountMismatchMessage)

    return (0..<views.count).reduce([]) { acc, i in
        if let align = individualAlignments?[i] ?? alignment {
            return acc + setAlignment(alignmentOrientation, views[i], parentView, align, insets)
        }
        else {
            return acc
        }
    }
}


public func spaceViews(
        orientation: Orientation,
        views: [UIView],
        spacing: CGFloat = 0,
        individualSpacings:[CGFloat?]? = nil) -> [NSLayoutConstraint] {

    if views.count < 2 {
        return []
    }

    assert(individualSpacings == nil || views.count == individualSpacings!.count - 1, "Spaces count mismatch. If space should not be set nil should be provided as a value")

    return (0..<views.count - 1).reduce([]) { acc, i in
        return acc + [setSpace(orientation, views[i], views[i + 1], individualSpacings?[i] ?? spacing)]
    }
}

public func setWidths(views: [UIView], widths: [CGFloat?]) -> [NSLayoutConstraint] {

    assert(widths.count == views.count, propertyCountMismatchMessage)

    return widths
            .enumerated()
            .filter { $0.1 != nil }
            .map { views[$0.0].widthAnchor.constraint(equalToConstant: $0.1!) }
}

public func setHeights(views: [UIView], heights: [CGFloat?]) -> [NSLayoutConstraint] {

    assert(heights.count == views.count, propertyCountMismatchMessage)

    return heights
            .enumerated()
            .filter { $0.1 != nil }
            .map { views[$0.0].heightAnchor.constraint(equalToConstant: $0.1!) }
}

//This is very naive implementation - we just set spacing to the same value and set very low priority to the constrains
fileprivate func distributeViews(orientation: Orientation, views: [UIView]) -> [NSLayoutConstraint] {
    
    let constraints = spaceViews(orientation: orientation, views: views, spacing: 10)

    for c in constraints {
        c.priority = 10
    }

    return constraints
}

public func justifyViews(
        orientation: Orientation,
        parentView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        justify: Justify,
        spacing: CGFloat? = nil,
        views: [UIView],
        individualSpacings: [CGFloat?]?) -> [NSLayoutConstraint] {

    var constrains: [NSLayoutConstraint] = []

    if justify != .end {
        constrains.append(setLeadingConstraint(orientation, views[0], parentView, insets))
    }

    if justify != .start {
        constrains.append(setTrailingConstraint(orientation, views[views.count - 1], parentView, insets))
    }

    if justify == .distribute {
        constrains += distributeViews(orientation: orientation, views: views)
    }
    else {
        constrains += spaceViews(orientation: orientation, views: views, spacing: spacing ?? 0, individualSpacings: individualSpacings)
        
    }

    return constrains
}


public func stackViews(
        orientation: Orientation,
        parentView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        justify: Justify = .start,
        alignment: Alignment? = nil,
        spacing: CGFloat? = nil,
        views: [UIView],
        widths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        individualAlignments: [Alignment?]? = nil,
        individualSpacings: [CGFloat?]? = nil) -> [NSLayoutConstraint] {
    
    if views.count == 0 {
        return []
    }

    views.forEach {
        if $0.superview == nil {
            parentView.addSubview($0)
        }

        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    var constraints:[NSLayoutConstraint] = []

    if let widths = widths {
        constraints += setWidths(views: views, widths: widths)
    }

    if let heights = heights {
        constraints += setHeights(views: views, heights: heights)
    }

    constraints += justifyViews(
                        orientation: orientation,
                        parentView: parentView,
                        insets: insets,
                        justify: justify,
                        spacing: spacing,
                        views: views,
                        individualSpacings: individualSpacings)

    let defaultAlignment: Alignment?
    if alignment == nil && individualAlignments == nil {
        switch orientation {
        case .horizontal: defaultAlignment = .center(0)
        case .vertical: defaultAlignment = widths == nil ? .stretch : .center(0)
        }
    }
    else {
        defaultAlignment = alignment
    }

    constraints += alignViews(
            alignmentOrientation: orientation.flip(),
            parentView: parentView,
            insets: insets,
            alignment: defaultAlignment,
            views: views,
            individualAlignments: individualAlignments)

    return constraints
}
