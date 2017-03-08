//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal extension UIView {

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

    func sameFirstBaseLine(_ view: UIView) -> NSLayoutConstraint {
        return self.firstBaselineAnchor.constraint(equalTo: view.firstBaselineAnchor)
    }

    func sameLastBaseLine(_ view: UIView) -> NSLayoutConstraint {
        return self.lastBaselineAnchor.constraint(equalTo: view.lastBaselineAnchor)
    }
}
