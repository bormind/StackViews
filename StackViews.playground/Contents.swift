//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

import StackViews

//Constants
let containerViewFrame = CGRect(x: 0, y : 0, width: 400, height: 700)


let containerView = ContainerView(frame: containerViewFrame)


//PlaygroundPage.current.needsIndefiniteExecution = true

PlaygroundPage.current.liveView = containerView


func createSample1(color: Int) -> UIView {
    let stackView = UIView()
    
    stackView.backgroundColor = UIColor(hex: color)
    
//    let children = ["View1", "View2", "View3"].map { createLabel(text: $0) }
//    
//    stackViews(
//        orientation: .horizontal,
//        inView: stackView,
//        children: children)
    
    return stackView
}

containerView.renderSample(sampleView: createSample1(color: 0xD5F5E3), title: "Sample 1:")



containerView.renderSample(sampleView: createSample1(color: 0xAA00DD), title: "Sample 2:")



