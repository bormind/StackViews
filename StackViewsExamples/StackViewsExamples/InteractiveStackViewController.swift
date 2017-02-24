//
// Created by Boris Schneiderman on 2017-01-30.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews

fileprivate func createChildView(title: String) -> UIView {

    let view = UIView()
    let label = UILabel()

    label.text = title

    view.addSubview(label)
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    label.translatesAutoresizingMaskIntoConstraints = false

    view.backgroundColor = UIColor(hex: 0x66DF9C)
    view.layer.borderWidth = 1

    return view

}

fileprivate func stackWithOptions(parentView: UIView, children:[UIView], options: StackOptions) -> StackingResult {

    return stackViews(
            orientation: options.orientation,
            justify: options.justify,
            align: options.alignment,
            parentView: parentView,
            insets: options.insets,
            spacing: options.spacing,
            views: children,
            widths: options.widths,
            heights: options.heights,
            individualAlignments: options.individualAlignments)

}

class InteractiveStackViewController: UIViewController {

    let children:[UIView]

    var constraints: [NSLayoutConstraint] = []

    init() {
        self.children = ["View1", "View2", "View3"].map { createChildView(title: $0) }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(options: StackOptions) {

        NSLayoutConstraint.deactivate(self.constraints)

        self.constraints = stackWithOptions(parentView: self.view, children: self.children, options: options)
                                .constraints
    }
}