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
//    view.backgroundColor = UIColor.barColor
    view.layer.borderWidth = 1

    return view

}

fileprivate func stackWithOptions(
        parentView: UIView,
        children:[UIView],
        options: StackOptions) -> StackingResult {

    return stackViews(
            container: parentView,
            orientation: options.orientation,
            justify: options.justify,
            align: options.align,
            insets: options.insets,
            spacing: options.spacing,
            views: children,
            widths: options.widths,
            proportionalWidths: options.proportionalWidths,
            heights: options.heights,
            proportionalHeights: options.proportionalHeights,
            individualAlignments: options.individualAlignments)

}

class InteractiveRenderingViewController: UIViewController {

    let viewTitles = ["View1", "View2", "View3"]
    let children:[UIView]

    var stackingResult: StackingResult?

    var stackPanelView: UIView!

    init() {
        self.children = viewTitles.map { createChildView(title: $0) }
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor.barColor

        stackPanelView = prepareStackPanel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(options: StackOptions) {

        if let stackingResult = stackingResult {
            resetStackViews(stackingResult: stackingResult)
        }

        self.stackingResult = stackWithOptions(parentView: stackPanelView, children: self.children, options: options)
    }

    private func prepareStackPanel() -> UIView {
        let panel = UIView()
        panel.backgroundColor = UIColor(hex: 0x80dfff)
        panel.layer.borderWidth = 1
        panel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(panel)

        let centerConstraints = [
            panel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]

        let inset: CGFloat = 5

        let edgeConstraints = [
            panel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: inset),
            panel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: inset),
            panel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -inset),
            panel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -inset)
        ]

        edgeConstraints.forEach { $0.priority = 500 }

        NSLayoutConstraint.activate(centerConstraints + edgeConstraints)

        return panel
    }
}
