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
    public let container: UIView
    public var constraints: [NSLayoutConstraint]
    public var spacerViews: [UIView]
}

public struct Insets {
    public let top: CGFloat
    public let left: CGFloat
    public let bottom: CGFloat
    public let right: CGFloat

    public static var zero: Insets {
        return Insets()
    }

    public init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    public init(horizontal: CGFloat) {
        self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
    }

    public init(vertical: CGFloat) {
       self.init(top: vertical, left: 0, bottom: vertical, right: 0)
    }

    public var leading: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
                ? self.left
                : self.right
    }

    public var trailing: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
                ? self.right
                : self.left
    }
}

public func resetStackViews(stackingResult: StackingResult) {
    NSLayoutConstraint.deactivate(stackingResult.constraints)
    stackingResult.spacerViews.forEach{ $0.removeFromSuperview() }
}

//Helper function do deal with controllers guides
public func constrainToGuides(_ view: UIView,
                              inViewController: UIViewController,
                              insets: Insets = Insets.zero,
                              activate: Bool = true) -> [NSLayoutConstraint] {

    inViewController.view.addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    //Constraint container to edges
    let constraints = [
        view.topAnchor.constraint(equalTo: inViewController.topLayoutGuide.bottomAnchor, constant: insets.top),
        view.leftAnchor.constraint(equalTo: inViewController.view.leftAnchor, constant: insets.left),
        view.bottomAnchor.constraint(equalTo: inViewController.bottomLayoutGuide.topAnchor, constant: -insets.bottom),
        view.rightAnchor.constraint(equalTo: inViewController.view.rightAnchor, constant: -insets.right)
    ]

    if activate {
        NSLayoutConstraint.activate(constraints)
    }

    return constraints
}

public func insetView(_ view: UIView,
                      container: UIView,
                      insets: Insets,
                      priority: Float? = nil,
                      activate: Bool = true) -> [NSLayoutConstraint] {

    meetTheParent(container, [view])
    let constraintInset = constraintToEdges(container, insets, priority)


    let anchors:[EdgeAnchor] = [.top, .left, .bottom, .right]

    let constraints = anchors
            .map { (view, anchor: $0) }
            .map(constraintInset)

    if activate {
        NSLayoutConstraint.activate(constraints)
    }

    return constraints
}


/**
    Generates all necessary constraints that arrange provided views in the single stack horizontally or vertically

    - Parameters:
            - container: Container view that acts as a stack panel.
            If view is not provided a new view will be created and returned as a part of the StackingResult structure
            - orientation: defines the stacking axes as horizontal or vertical.
            - justify: describes the stacking option along the stacking axis.
            - align: describes the stacking option across the stacking axes for all views.
            Can be overwritten for specific views by the individualAlignments parameter.
            - insets: specify insets applied to the edges of the container view.
            (Gap between the container view edges and it's children) Default = 0
            - spacing: spacing between neighboring views along the stacking axis. Default = 0
            - views: array of view that should be arranged (stacked) inside the container view
            - withs: array of width values corresponding to each view in views array. nil value indicates that width constraint will not be set
            If width array is provided it's leght chold be equal to the views array length
            - proportionalWidths: can be used to specify relative width value for views. If bot absolute width value and relative value provided 
            than the firs view with both values specified will be used as a 'key' view and all other proportionalWidths will be set in relation to this view. 
            For example if we have width: [nil, 50, nil]

    - Returns: StackingResult structure containing container view, array of generated constraints, array of generated spacer views.
*/
public func stackViews(
        container: UIView? = nil,
        orientation: Orientation,
        justify: Justify,
        align: Alignment,
        insets: Insets = Insets.zero,
        spacing: CGFloat = 0,
        views: [UIView],
        widths: [CGFloat?]? = nil,
        proportionalWidths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        proportionalHeights: [CGFloat?]? = nil,
        individualAlignments: [Alignment?]? = nil,
        activateConstrains: Bool = true) -> StackingResult {

    let container = container ?? createView()

    guard !views.isEmpty else {
        return StackingResult(container: container, constraints: [], spacerViews: [])
    }

    meetTheParent(container, views)

    var constraints:[NSLayoutConstraint] = []

    let setDimensions = { (orientation: Orientation, dimensions: [CGFloat?]) -> [NSLayoutConstraint] in
        let setDimension = constraintDimension(orientation)
        return (0..<views.count)
                .filter { dimensions[$0] != nil }
                .map { setDimension(views[$0], dimensions[$0]!) }
    }

    let doAlign = alignViews(orientation, container, insets)
    let doJustify = justifyViews(orientation, container, insets)

    if let widths = widths {
        constraints +=  setDimensions(.horizontal, widths)
    }

    if let heights = heights {
        constraints +=  setDimensions(.vertical, heights)
    }

    if let proportionalWidths = proportionalWidths {
        constraints += flexViews(.horizontal)(views, proportionalWidths, widths)
    }

    if let proportionalHeights = proportionalHeights {
        constraints += flexViews(.vertical)(views, proportionalHeights, heights)
    }

    constraints += doAlign(align, views, individualAlignments)

    let (justifyConstraints, spacers) = doJustify(justify, views, spacing)
    constraints += justifyConstraints

    if activateConstrains && !constraints.isEmpty {
        NSLayoutConstraint.activate(constraints)
    }

    return StackingResult(container: container, constraints: constraints, spacerViews: spacers)
}



