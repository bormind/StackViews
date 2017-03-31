//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

typealias GeneralLayoutAnchor = NSLayoutAnchor<AnyObject>

//We do this to make insets and centering priority weaker that sizing priority
let anchorConstraintPriority: Float = 900
let spacingConstraintPriority: Float = 900

enum EdgeAnchor {
    case top, left, bottom, right
}

enum CenterAnchor {
    case centerX, centerY
}

enum Anchor {
    case edgeAnchor(EdgeAnchor)
    case centerAnchor(CenterAnchor)

    init(_ edgeAnchor: EdgeAnchor) {
        self = .edgeAnchor(edgeAnchor)
    }

    init(_ centerAnchor: CenterAnchor) {
        self = .centerAnchor(centerAnchor)
    }
}

fileprivate func insetsForAnchor(_ insets: Insets)
                -> (EdgeAnchor)
                -> CGFloat {

    return { edge in
        switch edge {
        case .top: return insets.top
        case .left: return insets.left
        case .bottom: return -insets.bottom
        case .right: return -insets.right
        }
    }
}


func constraintDimension(_ orientation: Orientation)
                -> (UIView, CGFloat)
                -> NSLayoutConstraint {

    return { (view, constant) in
        switch orientation {
        case .horizontal: return view.widthAnchor.constraint(equalToConstant: constant)
        case .vertical: return view.heightAnchor.constraint(equalToConstant: constant)
        }
    }
}

func constraintRelativeDimension(_ orientation: Orientation, _ toView: UIView)
                -> (UIView, CGFloat)
                -> NSLayoutConstraint {

    return { (view, multiplier) in
        switch orientation {
        case .horizontal: return view.widthAnchor.constraint(equalTo: toView.widthAnchor, multiplier: multiplier)
        case .vertical: return view.heightAnchor.constraint(equalTo: toView.heightAnchor, multiplier: multiplier)
        }
    }
}

func constraintChain(_ orientation: Orientation, _ priority: Float?)
                -> (UIView, UIView, CGFloat)
                -> NSLayoutConstraint {

    return { (view, toView, space) in

        let constraint: NSLayoutConstraint
        switch orientation {
        case .horizontal: constraint = view.leftAnchor.constraint(equalTo: toView.rightAnchor, constant: space)
        case .vertical: constraint = view.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: space)
        }

        priority.map { constraint.priority = $0 }

        return constraint
    }

}

func constraintToEdges(_ container: UIView, _ insets: Insets, _ priority: Float?)
                -> (UIView, EdgeAnchor)
                -> NSLayoutConstraint {

    let insetForAnchor = insetsForAnchor(insets)

    return { view, anchor in

        let constant = insetForAnchor(anchor)

        let constraint: NSLayoutConstraint

        switch anchor {
        case .top: constraint = view.topAnchor.constraint(equalTo: container.topAnchor, constant: constant)
        case .left: constraint = view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: constant)
        case .bottom: constraint = view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: constant)
        case .right: constraint = view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: constant)
        }

        priority.map { constraint.priority = $0 }

        return constraint
    }
}

func constraintToCenters(_ container: UIView, _ priority: Float?)
            -> (UIView, CenterAnchor, CGFloat)
            -> NSLayoutConstraint {

    return { view, anchor, constant in

        let constraint: NSLayoutConstraint
        switch anchor {
        case .centerX: constraint = view.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: constant)
        case .centerY: constraint = view.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: constant)
        }

        priority.map { constraint.priority = $0 }

        return constraint
    }
}

func constraintToAnchors(_ container: UIView, _ insets: Insets, _ priority: Float?)
            -> (UIView, Anchor)
            -> NSLayoutConstraint {

    let constraintInset = constraintToEdges(container, insets, priority)
    let doConstraintCenter = constraintToCenters(container, priority)

    return { view, anchor in
        switch anchor {
        case .edgeAnchor(let edge): return constraintInset(view, edge)
        case .centerAnchor(let center): return doConstraintCenter(view, center, 0)
        }
    }
}

func constraintFirstBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.firstBaselineAnchor.constraint(equalTo: toView.firstBaselineAnchor)
}

func constraintLastBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.lastBaselineAnchor.constraint(equalTo: toView.lastBaselineAnchor)
}
