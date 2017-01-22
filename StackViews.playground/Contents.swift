//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

import StackViews

//Constants
let containerViewFrame = CGRect(x: 0, y : 0, width: 400, height: 700)


let containerView = ContainerView(frame: containerViewFrame)


PlaygroundPage.current.needsIndefiniteExecution = true

PlaygroundPage.current.liveView = containerView

func renderSample(_ title: String, viewGenerator: ()->UIView) {
    containerView.renderSample(sampleView: viewGenerator(), title: title)

}

renderSample("Sample One") {
    let stackView = UIView()
    
    stackView.backgroundColor = UIColor(hex: 0xD5F5E3)
    
    let children = ["View1", "View2", "View3"].map { createLabel(text: $0) }

    let constrains = stackViews(
        orientation: .horizontal,
        parentView:   stackView,
        insets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3),
        spacing: 20,
        views: children)
    
    NSLayoutConstraint.activate(constrains)
    
    return stackView
}







