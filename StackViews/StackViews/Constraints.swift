//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

typealias GeneralLayoutAnchor = NSLayoutAnchor<AnyObject>


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

func constraintChain(_ orientation: Orientation)
                -> (UIView, UIView, CGFloat)
                -> NSLayoutConstraint {

    return { (view, toView, space) in
        switch orientation {
        case .horizontal: return view.leftAnchor.constraint(equalTo: toView.rightAnchor, constant: space)
        case .vertical: return view.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: space)
        }
    }

}

func constraintSnap(_ toView: UIView)
                -> (ViewSnappingOption)
                -> NSLayoutConstraint {

    return { snapOption in

        switch snapOption.anchor {
        case .top: return snapOption.view.topAnchor.constraint(equalTo: toView.topAnchor, constant: snapOption.constant)
        case .left: return snapOption.view.leftAnchor.constraint(equalTo: toView.leftAnchor, constant: snapOption.constant)
        case .bottom: return snapOption.view.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: snapOption.constant)
        case .right: return snapOption.view.rightAnchor.constraint(equalTo: toView.rightAnchor, constant: snapOption.constant)
        case .centerX: return snapOption.view.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: snapOption.constant)
        case .centerY: return snapOption.view.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: snapOption.constant)
        }
    }
}

func constraintFirstBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.firstBaselineAnchor.constraint(equalTo: toView.firstBaselineAnchor)
}

func constraintLastBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.lastBaselineAnchor.constraint(equalTo: toView.lastBaselineAnchor)
}
