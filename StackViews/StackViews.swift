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

fileprivate func setAlignment(_ orientation: Orientation, _ view: UIView, _ superview: UIView, _ alignment: Alignment, _ insets: UIEdgeInsets) -> [NSLayoutConstraint] {
    switch (orientation, alignment) {
    case (.horizontal, .start(let val)):
        return [constraint(view.topAnchor, to: superview.topAnchor, val + insets.top)]
    case (.horizontal, .center(let val)):
        return [constraint(view.centerYAnchor , to: superview.centerYAnchor, val)]
    case (.horizontal, .end(let val)):
        return [constraint(view.bottomAnchor, to: superview.bottomAnchor, -(val + insets.bottom))]
    case (.horizontal, .stretch):
        return [
            constraint(view.topAnchor, to: superview.topAnchor, insets.top),
            constraint(view.bottomAnchor, to: superview.bottomAnchor, -insets.bottom)
        ]
    case (.vertical, .start(let val)):
        return [constraint(view.leftAnchor, to: superview.leftAnchor, val + insets.left)]
    case (.vertical, .center(let val)):
        return [constraint(view.centerXAnchor, to: superview.centerXAnchor, val)]
    case (.vertical, .end(let val)):
        return [constraint(view.rightAnchor, to: superview.rightAnchor, -(val + insets.right))]
    case (.vertical, .stretch):
        return [
            constraint(view.leftAnchor, to: superview.leftAnchor, insets.left),
            constraint(view.rightAnchor, to: superview.rightAnchor, -insets.right)
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

public func alignViews(
               orientation: Orientation,
               inView: UIView,
               insets: UIEdgeInsets = UIEdgeInsets.zero,
               alignment: Alignment? = nil,
               children: [UIView],
               dimensions: [CGFloat?]? = nil,
               alignments: [Alignment?]? = nil) -> [NSLayoutConstraint] {

    return children.enumerated().flatMap { (i, view) -> [NSLayoutConstraint] in
        let alignment = alignmentToUse(orientation, alignments?[i], alignment, dimensions?[i])
        return setAlignment(orientation, view, inView, alignment, insets)
    }
}

public func spaceViews(
        orientation: Orientation,
        views: [UIView],
        spaces:[CGFloat?]) -> [NSLayoutConstraint] {

    if views.count < 2 {
        return []
    }

    assert(views.count == spaces.count - 1, "Spaces count mismatch. If space should not be set nil should be provided as a value")

    return spaces.enumerated()
            .filter { $0.1 != nil }
            .map { setSpace(orientation, views[$0.0], views[$0.0 + 1], $0.1!)}

}

//This is very naive implementation - we just set spacing to the same value and set very low priority to the constrains
fileprivate func distributeViews(orientation: Orientation, views: [UIView]) -> [NSLayoutConstraint] {
    let spaces = [CGFloat](repeating: 10, count: views.count - 1)
    let constraints = spaceViews(orientation: orientation, views: views, spaces: spaces)

    for c in constraints {
        c.priority = 10
    }

    return constraints
}

public func justifyViews(
        orientation: Orientation,
        inView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        spacing: CGFloat? = nil,
        justify: Justify? = nil,
        children: [UIView],
        dimensions: [CGFloat?]? = nil,
        spaces: [CGFloat?]?) -> [NSLayoutConstraint] {

    if justify != nil && justify! == .distribute {
        assert(spacing == nil
                && spaces == nil
                && dimensions != nil
                && !dimensions!.contains(where: {$0 == nil }), "Only views with set dimensions can be distributed")
    }

    let toJustify: Justify
    if let justify = justify {
        toJustify = justify
    }
    else {
        if spacing == nil
           && spaces == nil
           && dimensions != nil
           && !dimensions!.contains(where: {$0 == nil }) { //Dimensions set for all children
            toJustify = .distribute
        }
        else {
            toJustify = .stretch
        }
    }


    var constrains: [NSLayoutConstraint] = []

    if toJustify != .end {
        constrains.append(setLeadingConstraint(orientation, children[0], inView, insets))
    }

    if toJustify != .start {
        constrains.append(setTrailingConstraint(orientation, children[children.count - 1], inView, insets))
    }

    if toJustify == .distribute {
        constrains += distributeViews(orientation: orientation, views: children)
    }
    else {
        zzzzz
    }

    for i in 0..<children.count {

        if let width = widths[i] {
            constrains.append(constraint(children[i].widthAnchor, toValue: width))
        }

        if let height = heights[i] {
            constrains.append(constraint(children[i].heightAnchor, toValue: height))
        }

        if i > 0 {
            setSpace(orientation, children[i - 1], children[i], spaceToUse)
        }
    }
}

public func stackViews(
        orientation: Orientation,
        inView: UIView,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        alignment: Alignment? = nil,
        spacing: CGFloat? = nil,
        justify: Justify? = nil,
        children: [UIView],
        widths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        alignments: [Alignment?]? = nil) {
    
    if children.count == 0 {
        return
    }



    assert(widths == nil || widths!.count == children.count, propertyCountMismatchMessage)
    assert(heights == nil || heights!.count == children.count, propertyCountMismatchMessage)
    assert(alignments == nil || alignments!.count == children.count, propertyCountMismatchMessage)

    children.forEach {
        if $0.superview == nil {
            inView.addSubview($0)
        }
    }

    let (alongAxisDimensions, crossAxisDimensions) = getAxisDimensions(orientation, widths, heights, children.count)



}
