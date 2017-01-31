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

fileprivate func clearConstraints(views: [UIView]) {
    views.forEach { $0.removeFromSuperview() }
}

fileprivate func stackWithOptions(parentView: UIView, children:[UIView], options: StackOptions) {

    stackViews(
            orientation: options.orientation,
            parentView: parentView,
            insets: options.insets,
            justify: options.justify,
            views: children,
            widths: [50, 50, nil],
            heights: [50, 50, 50])

}

class InteractiveStackViewController: UIViewController {

    let children:[UIView]

    init() {
        self.children = ["View1", "View2", "View3"].map { createChildView(title: $0) }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(options: StackOptions) {

        clearConstraints(views: self.children)

        stackWithOptions(parentView: self.view, children: self.children, options: options)

    }




}