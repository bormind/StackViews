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

//    view.backgroundColor = UIColor(hex: 0x66DF9C)
//    view.backgroundColor = UIColor.barColor
    view.layer.borderWidth = 1

    return view

}

fileprivate func stackWithOptions(parentView: UIView, children:[UIView], options: StackOptions) -> StackingResult {

    return parentView.stackViews(
            orientation: options.orientation,
            justify: options.justify,
            align: options.align,
            insets: options.insets,
            spacing: options.spacing,
            views: children,
            widths: options.widths,
            heights: options.heights,
            individualAlignments: options.individualAlignments)

}

class InteractiveStackViewController: UIViewController {

    let viewTitles = ["View1", "View2", "View3"]
    let children:[UIView]

    var stackingResult: StackingResult?

    init() {
        self.children = viewTitles.map { createChildView(title: $0) }
        super.init(nibName: nil, bundle: nil)

        self.view.layer.borderWidth = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(options: StackOptions) {

        self.stackingResult?.clearConstraints()
        self.stackingResult = stackWithOptions(parentView: self.view, children: self.children, options: options)
    }
}