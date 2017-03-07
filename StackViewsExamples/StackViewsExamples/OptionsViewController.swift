//
// Created by Boris Schneiderman on 2017-01-30.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

struct StackOptions {
    var orientation: Orientation
    var justify: Justify
    var align: Alignment
    var insets: UIEdgeInsets
    var spacing: CGFloat
    var widths: [CGFloat?]
    var proportionalWidths: [CGFloat?]
    var heights: [CGFloat?]
    var proportionalHeights: [CGFloat?]
    var individualAlignments: [Alignment?]
}

fileprivate let initialOptions = StackOptions(
        orientation: .vertical,
        justify: .center,
        align: .center,
        insets: UIEdgeInsets.zero,
        spacing: 0,
        widths: [100, 100, 100],
        proportionalWidths: [nil, nil, nil],
        heights: [100, 100, 100],
        proportionalHeights: [nil, nil, nil],
        individualAlignments: [nil, nil, nil])


fileprivate func labeledRow(_ label: String, _ ctrl: UIView) -> UIView {
    let row = UIView()

    let labelCtrl = UILabel()
    labelCtrl.text = label + ":"
    labelCtrl.backgroundColor = UIColor.barColor

    let _ = row.stackViews(
            orientation: .horizontal,
            justify: .fill,
            align: .center,
            views: [labelCtrl, ctrl],
            widths: [200, nil])

    return row
}

fileprivate func formatInsets(_ insets: UIEdgeInsets) -> String {
    return zip(
            ["t:", "l:", "b:", "r:"],
            [Int(insets.top), Int(insets.left), Int(insets.bottom), Int(insets.right)] )
            .map { "\($0.0)\($0.1)" }.joined(separator: " ")
}

fileprivate func formatButton(_ button: UIButton) {
    button.setTitleColor(UIColor.blue, for: .normal)
}

//fileprivate func formatEnumValue <T: CustomStringConvertible> (val: T) -> String {
//    return ".\(val)"
//}

fileprivate func formatEnumValue <T> (_ val: T?) -> String {
    if let val = val {
        return ".\(val)"
    }
    else {
        return "nil"
    }
}

fileprivate func formatNumericValues(_ vals: [CGFloat?]) -> [String] {
    return vals.map {
        if let val = $0 {
            return "\(Int(val))"
        }
        else {
            return "nil"
        }
    }
}

fileprivate func formatNumericArray(_ vals: [CGFloat?]) -> String {
    return "[\(formatNumericValues(vals).joined(separator: ", "))]"
}


fileprivate func getMultiComponentIndexes<T: Equatable>(components:[[T?]], values: [T?]) -> [Int] {
    assert(components.count == values.count, "Component and value count should match")

    return values.enumerated().map { index, value in
        return components[index].index(where: { $0 == value }) ?? 0
    }
}

fileprivate let supportedAlignments: [Alignment] = [
        Alignment.fill,
        Alignment.start,
        Alignment.center,
        Alignment.end
]

fileprivate let widthOptions: [CGFloat?] = [nil, 100, 200]
fileprivate let heightOptions: [CGFloat?] = [nil, 25, 100]
fileprivate let proportionalOptions: [CGFloat?] = [nil, 1, 2, 3, 5]

fileprivate typealias ControlRecord = (String, UIButton, (String)->())

class OptionsViewController: UIViewController {

    var options: StackOptions

    let orientationButton = UIButton()
    let justifyButton = UIButton()
    let insetsButton = UIButton()
    let alignmentButton = UIButton()
    let spacingButton = UIButton()
    let widths = UIButton()
    let proportionalWidths = UIButton()
    let heights = UIButton()
    let proportionalHeights = UIButton()
    let individualAlignments = UIButton()

    fileprivate var controls: [ControlRecord]!

    var optionsChanged: (()->())?

    let viewTitles: [String]

    init(viewTitles: [String]) {
        self.viewTitles = viewTitles
        self.options = initialOptions

        super.init(nibName: nil, bundle: nil)

//        self.view.backgroundColor = UIColor(hex: 0x92E2E7)
        self.view.backgroundColor = UIColor.barColor

        self.controls = [("Orientation", orientationButton, onOrientation),
                      ("Justify", justifyButton, onJustification),
                      ("Align", alignmentButton, onAlignment),
                      ("Insets", insetsButton, onInsets),
                      ("Spacing", spacingButton, onSpacing),
                      ("Widths", widths, onWidths),
                      ("Proportional Widths", proportionalWidths, onProportionalWidths),
                      ("Heights", heights, onHeights),
                      ("Proportional Heights", proportionalHeights, onProportionalHeights),
                      ("Individual Alignments", individualAlignments, onIndividualAlignments)]

        controls.forEach { formatButton($0.1) }
        controls.forEach { $0.1.addTarget(self, action: #selector(onControl), for: .touchUpInside) }
        
        let controlRows = controls.map { labeledRow($0.0, $0.1) }
        
//        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
//        justifyButton.addTarget(self, action: #selector(onJustification), for: .touchUpInside)
//        insetsButton.addTarget(self, action: #selector(onInsets), for: .touchUpInside)
//        alignmentButton.addTarget(self, action: #selector(onAlignment), for: .touchUpInside)
//        spacingButton.addTarget(self, action: #selector(onSpacing), for: .touchUpInside)
//        widths.addTarget(self, action: #selector(onWidths), for: .touchUpInside)
//        proportionalWidths.addTarget(self, action: #selector(onProportionalWidths), for: .touchUpInside)
//        heights.addTarget(self, action: #selector(onHeights), for: .touchUpInside)
//        proportionalHeights.addTarget(self, action: #selector(onProportionalHeights), for: .touchUpInside)
//        individualAlignments.addTarget(self, action: #selector(onIndividualAlignments), for: .touchUpInside)

        let _ = self.view.stackViews(
                orientation: .vertical,
                justify: .start,
                align: .fill,
                insets: UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10),
                spacing: 5,
                views: controlRows,
                heights: [CGFloat?](repeating: 20, count: controlRows.count))

        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onControl(_ sender: UIControl) {
        if let record = controls.first(where: { $0.1 == sender }) {
            record.2(record.0)
        }
    }
    
    func onOrientation(_ title: String) {
        let items: [Orientation] = [.horizontal, .vertical]
        let currentIndex = items.index(where: { $0 == self.options.orientation }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty(title, [titles], [currentIndex]) {
            self.options.orientation = items[$0[0]]
        }
    }

    func onJustification(_ title: String) {
        let items: [Justify] = [.fill, .start, .end, .spaceBetween, .center]
        let currentIndex = items.index(where: { $0 == self.options.justify }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty(title, [titles], [currentIndex]) {
            self.options.justify = items[$0[0]]
        }
    }

    func onInsets(_ title: String) {
        let componentItems:[CGFloat] = [0, 20]
        let items = [[CGFloat]](repeating: componentItems, count:4)
        let stringItems = [[String]](repeating: componentItems.map {"\($0)"}, count:4)

        let currentValues = [self.options.insets.top, self.options.insets.left, self.options.insets.bottom, self.options.insets.right]
        let currentIndexes = getMultiComponentIndexes(components: items, values: currentValues)

        onPickProperty(title, stringItems, currentIndexes, ["top", "left", "bottom", "right"]) {
            self.options.insets = UIEdgeInsets(top: items[0][$0[0]], left: items[1][$0[1]], bottom: items[2][$0[2]], right: items[3][$0[3]])
        }
    }

    func onAlignment(_ title: String) {

        let currentIndex = supportedAlignments.index(where: { $0 ==? self.options.align }) ?? 0
        let titles = supportedAlignments.map(formatEnumValue)

        onPickProperty(title, [titles], [currentIndex]) {
            self.options.align = supportedAlignments[$0[0]]
        }
    }

    func onSpacing(_ title: String) {
        let items: [CGFloat] = [0, 20]
        let currentIndex = items.index(where: { $0 == self.options.spacing }) ?? 0
        let titles = items.map { "\(Int($0))" }

        onPickProperty(title, [titles], [currentIndex]) {
            self.options.spacing = items[$0[0]]
        }
    }

    func onWidths(_ title: String) {
        let items: [[CGFloat?]] = [widthOptions, widthOptions, widthOptions]
        let stringValues = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.widths)

        onPickProperty(title, stringValues, currentIndexes, viewTitles) {
            self.options.widths = $0.enumerated().map { comp, ix in items[comp][ix] }
        }

    }

    func onProportionalWidths(_ title: String) {
        let items: [[CGFloat?]] = [proportionalOptions, proportionalOptions, proportionalOptions]
        let stringValues = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.proportionalWidths)

        onPickProperty(title, stringValues, currentIndexes, viewTitles) {
            self.options.proportionalWidths = $0.enumerated().map { comp, ix in items[comp][ix] }
        }
    }

    func onHeights(_ title: String) {
        let items: [[CGFloat?]] = [heightOptions, heightOptions, heightOptions]
        let titles = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.heights)

        onPickProperty(title, titles, currentIndexes, viewTitles) {
            self.options.heights = $0.enumerated().map { comp, ix in items[comp][ix] }
        }
    }

    func onProportionalHeights(_ title: String) {
        let items: [[CGFloat?]] = [proportionalOptions, proportionalOptions, proportionalOptions]
        let stringValues = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.proportionalHeights)

        onPickProperty(title, stringValues, currentIndexes, viewTitles) {
            self.options.proportionalHeights = $0.enumerated().map { comp, ix in items[comp][ix] }
        }
    }

    func onIndividualAlignments(_ title: String) {
        let individualAlignments: [Alignment?] = [nil] + supportedAlignments
        let items: [[Alignment?]] = [individualAlignments, individualAlignments, individualAlignments]
        let titles = items.map { $0.map(formatEnumValue) }
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.individualAlignments)

        onPickProperty(title, titles, currentIndexes, viewTitles) {
            self.options.individualAlignments = $0.enumerated().map { comp, ix in items[comp][ix] }
        }
    }

    func onPickProperty(_ title: String, _ items: [[String]], _ initialSelection:[Int], _ componentTitles:[String]? = nil, _ setNewSelection: @escaping ([Int]) -> ()) {
        startPicker(container: self, title: title, items: items, selectedIndexes: initialSelection, componentTitles: componentTitles) { indexes in
            if initialSelection != indexes {
                setNewSelection(indexes)
                self.updateUI()
                self.optionsChanged?()
            }
        }
    }

    private func updateUI() {
        orientationButton.setTitle(formatEnumValue(self.options.orientation), for: .normal)
        justifyButton.setTitle(formatEnumValue(self.options.justify), for: .normal)
        alignmentButton.setTitle(formatEnumValue(self.options.align), for: .normal)
        insetsButton.setTitle(formatInsets(self.options.insets), for: .normal)
        spacingButton.setTitle("\(Int(self.options.spacing))", for: .normal)
        widths.setTitle(formatNumericArray(self.options.widths), for: .normal)
        proportionalWidths.setTitle(formatNumericArray(self.options.proportionalWidths), for: .normal)
        heights.setTitle(formatNumericArray(self.options.heights), for: .normal)
        proportionalHeights.setTitle(formatNumericArray(self.options.proportionalHeights), for: .normal)
        
        let alignments = self.options.individualAlignments.map(formatEnumValue)
        individualAlignments.setTitle("[\(alignments.joined(separator: ", "))]", for: .normal)
    }

}
