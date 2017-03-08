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
    public var generatedViews: [UIView]
    public var errors: [String]

    init(container: UIView, constraints: [NSLayoutConstraint] = [], generatedViews: [UIView] = [], errors: [String] = []) {
        self.container = container
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


public func justifyViews( container: UIView? = nil,
                           justify: Justify,
                           orientation: Orientation,
                           insets: UIEdgeInsets = UIEdgeInsets.zero,
                           spacing: CGFloat = 0,
                           views: [UIView]) -> StackingResult {

    let stacker = Stacker(
            view: container ?? createView(),
            orientation: orientation,
            insets: insets)

    views.forEach(meetTheParent(stacker.view))

    let (constraints, generatedViews) = stacker.justifyViews(justify: justify, spacing: spacing, views: views)

    return StackingResult(container: stacker.view, constraints: constraints, generatedViews: generatedViews)
}

public func alignViews(
        container: UIView,
        align: Alignment,
        orientation: Orientation,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        views: [UIView],
        individualAlignments: [Alignment?]? = nil) -> StackingResult {

    let stacker = Stacker(
            view: container ?? createView(),
            orientation: orientation,
            insets: insets)

    views.forEach(meetTheParent(stacker.view))

    let constraints = stacker.alignViews(align: align, views: views, individualAlignments: individualAlignments)

    return StackingResult(container: stacker.view, constraints: constraints)
}

public func stackViews(
        container: UIView? = nil,
        orientation: Orientation,
        justify: Justify,
        align: Alignment,
        insets: UIEdgeInsets = UIEdgeInsets.zero,
        spacing: CGFloat = 0,
        views: [UIView],
        widths: [CGFloat?]? = nil,
        proportionalWidths: [CGFloat?]? = nil,
        heights: [CGFloat?]? = nil,
        proportionalHeights: [CGFloat?]? = nil,
        individualAlignments: [Alignment?]? = nil,
        activateConstrains: Bool = true) -> StackingResult {

    let stacker = Stacker(
            view:  container ?? createView(),
            orientation: orientation,
            insets: insets)

    if views.isEmpty {
        return StackingResult(container: stacker.view)
    }

    views.forEach(meetTheParent(stacker.view))

    var constraints:[NSLayoutConstraint] = []
    var errors: [String] = []
    var generatedViews: [UIView] = []

    if let widths = widths {
        constraints +=  (0..<views.count)
                .filter { widths[$0] != nil }
                .map { views[$0].widthAnchor.constraint(equalToConstant: widths[$0]!) }

    }

    if let heights = heights {
        constraints +=  (0..<views.count)
                .filter { heights[$0] != nil }
                .map { views[$0].heightAnchor.constraint(equalToConstant: heights[$0]!) }
    }

    let result = stacker.justifyViews(
            justify: justify,
            spacing: spacing,
            views: views)

    constraints += result.0
    generatedViews += result.1


    if let proportionalWidths = proportionalWidths {
        let result = flexViews(
                orientation: .horizontal,
                views: views,
                flexValues: proportionalWidths,
                dimensions: widths)

        constraints += result.0
        errors += result.1
    }

    if let proportionalHeights = proportionalHeights {
        let result = flexViews(
                orientation: .vertical,
                views: views,
                flexValues: proportionalHeights,
                dimensions: heights)

        constraints += result.0
        errors += result.1
    }

    constraints += stacker.alignViews(align: align,
                                    views: views,
                                    individualAlignments: individualAlignments)

    if activateConstrains && !constraints.isEmpty {
        NSLayoutConstraint.activate(constraints)
    }

    return StackingResult(container: stacker.view, constraints: constraints, generatedViews: generatedViews)
}


