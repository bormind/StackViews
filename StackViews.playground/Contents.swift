//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

import StackViews

//Constants
let containerViewFrame = CGRect(x: 0, y : 0, width: 400, height: 700)


let containerView = ContainerView(frame: containerViewFrame)
containerView.backgroundColor = UIColor.orange


//PlaygroundPage.current.needsIndefiniteExecution = true

PlaygroundPage.current.liveView = containerView

func renderSample(_ title: String,
                  y: CGFloat? = nil,
                  containerWidth: CGFloat? = nil,
                  containerHeight: CGFloat? = nil,
                  viewGenerator: ()->UIView) {
    
    containerView.renderSample(sampleView: viewGenerator(),
                               title: title,
                               y: y,
                               width: containerWidth,
                               height: containerHeight)
}

public func createChildView(text: String) -> UIView {
    
    let view = UIView()
    let label = UILabel()
    
    label.text = text
    
    view.addSubview(label)
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    
//    label.setContentHuggingPriority(500, for: UILayoutConstraintAxis.horizontal)
//    
//        label.setContentHuggingPriority(500, for: UILayoutConstraintAxis.vertical)
    
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    view.backgroundColor = UIColor(hex: 0x66DF9C)
    view.layer.borderWidth = 1
    
    
    return view
}

renderSample("Horizontal with default Justify and Align:") {
    let stackView = UIView()
    
    stackView.backgroundColor = UIColor(hex: 0xD5F5E3)
    
    let children = ["View1", "View2", "View3"].map { createChildView(text: $0) }

    let constrains = stackViews(
        orientation: .horizontal,
        parentView:   stackView,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
//        spacing: 20,
        views: children,
        widths: [70, 70, 70],
        heights: [40, 40, 40])
    
    NSLayoutConstraint.activate(constrains)
    
    return stackView
}

renderSample("Vertical with default Justify and Align:", containerWidth: 300, containerHeight: 200) {
    let stackView = UIView()
    
    stackView.backgroundColor = UIColor(hex: 0xD5F5E3)
    
    let children = ["View1", "View2", "View3"].map { createChildView(text: $0) }
    
    let constrains = stackViews(
        orientation: .vertical,
        parentView:   stackView,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        //        spacing: 20,
        views: children,
        widths: [70, 70, 70],
        heights: [40, 40, 40])
    
    NSLayoutConstraint.activate(constrains)
    
    return stackView
}

renderSample("Horizontal stretch, spacing and individual alignments:") {
    
    let stackView = UIView()
    
    stackView.backgroundColor = UIColor(hex: 0xD5F5E3)
    
    let children = ["View1", "View2", "View3"].map { createChildView(text: $0) }
    
    let constrains = stackViews(
        orientation: .horizontal,
        parentView:   stackView,
        insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        justify: .stretch,
        alignment: .centerOffset(0),
        spacing: 20,
        views: children,
        widths: [70, nil, 70],
        heights: [40, 40, 40],
        individualAlignments:[.fill, nil, .end])
    
    
    NSLayoutConstraint.activate(constrains)
    
    return stackView
}







