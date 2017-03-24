//
// Created by Boris Schneiderman on 2017-03-24.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

func constraintDimension(_ orientation: Orientation)
                -> (CGFloat)
                -> (UIView)
                -> NSLayoutConstraint {

    return { constant in
        return { view in
            switch orientation {
            case .horizontal: return view.widthAnchor.constraint(equalToConstant: constant)
            case .vertical: return view.heightAnchor.constraint(equalToConstant: constant)
            }
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

func constraintChain(_ orientation: Orientation, _ view: UIView, _ constant: CGFloat)
                -> (CGFloat)
                -> (UIView, UIView)
                -> NSLayoutConstraint {

    return { constant in
        return { (view, toView) in
            switch orientation {
            case .horizontal: return view.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: constant)
            case .vertical: return view.topAnchor.constraint(equalTo: toView.bottomAnchor, constant: constant)
            }
        }
    }
}

func constraintSnap(_ orientation: Orientation, _ toView: UIView)
                -> (UIView, SnapOption, CGFloat)
                -> NSLayoutConstraint {

    return { view, snapOption, constant in

        switch (orientation, snapOption) {
        case (.vertical, .start): return view.topAnchor.constraint(equalTo: toView.topAnchor, constant: constant)
        case (.horizontal, .start): return view.leftAnchor.constraint(equalTo: toView.leftAnchor, constant: constant)
        case (.vertical, .end): return view.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: constant)
        case (.horizontal, .end): return view.rightAnchor.constraint(equalTo: toView.rightAnchor, constant: constant)
        case (.horizontal, .center): return view.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: constant)
        case (.vertical, .center): return view.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: constant)
        }
    }
}

func constraintFirstBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.firstBaselineAnchor.constraint(equalTo: toView.firstBaselineAnchor)
}

func constraintLastBaseLine(_ view: UIView, toView: UIView) -> NSLayoutConstraint {
    return view.lastBaselineAnchor.constraint(equalTo: toView.lastBaselineAnchor)
}
