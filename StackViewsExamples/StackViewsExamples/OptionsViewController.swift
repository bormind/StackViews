//
// Created by Boris Schneiderman on 2017-01-30.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

struct StackOptions {
    var orientation: Orientation
    var justify: Justify?
    var alignment: Alignment?
    var insets: UIEdgeInsets
    var spacing: CGFloat
    var widths: [CGFloat?]
    var heights: [CGFloat?]
    var individualAlignments: [Alignment?]
}


fileprivate func labeledRow(_ label: String, _ ctrl: UIView) -> UIView {
    let row = UIView()

    let labelCtrl = UILabel()
    labelCtrl.text = label
    labelCtrl.backgroundColor = UIColor.orange

    let _ = stackViews(
            orientation: .horizontal,
            parentView: row,
            justify: .stretch,
            views: [labelCtrl, ctrl],
            widths: [100, nil])

    return row
}

fileprivate func formatInsets(_ insets: UIEdgeInsets) -> String {
    return zip(
            ["t:", "l:", "b:", "r:"],
            [Int(insets.top), Int(insets.left), Int(insets.bottom), Int(insets.right)] )
            .map { "\($0.0)\($0.1)" }.joined(separator: " ")
}

fileprivate func formatButton(_ button: UIButton) {
    button.setTitleColor(UIColor.black, for: .normal)
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

fileprivate let supportedAlignments: [Alignment?] = [
        nil,
        Alignment.fill,
        Alignment.start,
        Alignment.center,
        Alignment.end
]

class OptionsViewController: UIViewController {

    var options: StackOptions

    let orientationButton = UIButton()
    let justifyButton = UIButton()
    let insetsButton = UIButton()
    let alignmentButton = UIButton()
    let spacingButton = UIButton()
    let widths = UIButton()
    let heights = UIButton()
    let individualAlignments = UIButton()

    var optionsChanged: (()->())?

    init() {

        self.options = StackOptions(
                orientation: .horizontal,
                justify: nil,
                alignment: nil,
                insets: UIEdgeInsets.zero,
                spacing: 0,
                widths: [nil, nil, nil],
                heights: [nil, nil, nil],
                individualAlignments: [nil, nil, nil])

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor(hex: 0x92E2E7)

        let controlsWithLabels = [("Orientation:", orientationButton),
                                  ("Justify:", justifyButton),
                                  ("Alignment", alignmentButton),
                                  ("Insets:", insetsButton),
                                  ("Spacing:", spacingButton),
                                  ("Widths:", widths),
                                  ("Heights:", heights),
                                  ("Individual Alignments:", individualAlignments)]

        controlsWithLabels.forEach { formatButton($0.1) }

        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
        justifyButton.addTarget(self, action: #selector(onJustification), for: .touchUpInside)
        insetsButton.addTarget(self, action: #selector(onInsets), for: .touchUpInside)
        alignmentButton.addTarget(self, action: #selector(onAlignment), for: .touchUpInside)
        spacingButton.addTarget(self, action: #selector(onSpacing), for: .touchUpInside)
        widths.addTarget(self, action: #selector(onWidths), for: .touchUpInside)
        heights.addTarget(self, action: #selector(onHeights), for: .touchUpInside)
        individualAlignments.addTarget(self, action: #selector(onIndividualAlignments), for: .touchUpInside)

        let _ = stackViews(
                orientation: .vertical,
                parentView: self.view,
                justify: .start,
                alignment: .fill,
                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                spacing: 5,
                views: controlsWithLabels.map(labeledRow),
                heights: [CGFloat?](repeating: 20, count: controlsWithLabels.count))

        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onOrientation() {
        let items: [Orientation] = [.horizontal, .vertical]
        let currentIndex = items.index(where: { $0 == self.options.orientation }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty("Orientation", [titles], [currentIndex]) {
            self.options.orientation = items[$0[0]]
        }

    }

    func onJustification() {
        let items: [Justify?] = [nil, .stretch, .start, .end]
        let currentIndex = items.index(where: { $0 == self.options.justify }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty("Justify", [titles], [currentIndex]) {
            self.options.justify = items[$0[0]]
        }
    }

    func onInsets() {
        let componentItems:[CGFloat] = [0, 20]
        let items = [[CGFloat]](repeating: componentItems, count:4)
        let stringItems = [[String]](repeating: componentItems.map {"\($0)"}, count:4)

        let currentValues = [self.options.insets.top, self.options.insets.left, self.options.insets.bottom, self.options.insets.right]
        let currentIndexes = getMultiComponentIndexes(components: items, values: currentValues)

        onPickProperty("Insets", stringItems, currentIndexes, ["top", "left", "bottom", "right"]) {
            self.options.insets = UIEdgeInsets(top: items[0][$0[0]], left: items[1][$0[1]], bottom: items[2][$0[2]], right: items[3][$0[3]])
        }
    }

    func onAlignment() {

        let currentIndex = supportedAlignments.index(where: { $0 ==? self.options.alignment }) ?? 0
        let titles = supportedAlignments.map(formatEnumValue)

        onPickProperty("Alignment", [titles], [currentIndex]) {
            self.options.alignment = supportedAlignments[$0[0]]
        }
    }

    func onSpacing() {
        let items: [CGFloat] = [0, 20]
        let currentIndex = items.index(where: { $0 == self.options.spacing }) ?? 0
        let titles = items.map { "\(Int($0))" }

        onPickProperty("Spacing", [titles], [currentIndex]) {
            self.options.spacing = items[$0[0]]
        }
    }

    func onWidths() {
        let items: [[CGFloat?]] = [[nil, 100, 200], [nil, 100, 200], [nil, 100, 200]]
        let titles = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.widths)

        onPickProperty("Widths", titles, currentIndexes) {
            self.options.widths = $0.enumerated().map { comp, ix in items[comp][ix] }
        }

    }

    func onHeights() {
        let items: [[CGFloat?]] = [[nil, 25, 100], [nil, 25, 100], [nil, 25, 100]]
        let titles = items.map(formatNumericValues)
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.heights)

        onPickProperty("Heights", titles, currentIndexes) {
            self.options.heights = $0.enumerated().map { comp, ix in items[comp][ix] }
        }
    }

    func onIndividualAlignments() {
        let items: [[Alignment?]] = [supportedAlignments, supportedAlignments, supportedAlignments]
        let titles = items.map { $0.map(formatEnumValue) }
        let currentIndexes = getMultiComponentIndexes(components: items, values: self.options.individualAlignments)

        onPickProperty("Individual Alignments", titles, currentIndexes) {
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
        alignmentButton.setTitle(formatEnumValue(self.options.alignment), for: .normal)
        insetsButton.setTitle(formatInsets(self.options.insets), for: .normal)
        spacingButton.setTitle("\(Int(self.options.spacing))", for: .normal)
        widths.setTitle(formatNumericArray(self.options.widths), for: .normal)
        heights.setTitle(formatNumericArray(self.options.heights), for: .normal)

        let alignments = self.options.individualAlignments.map(formatEnumValue)
        individualAlignments.setTitle("[\(alignments.joined(separator: ", "))]", for: .normal)

    }

}