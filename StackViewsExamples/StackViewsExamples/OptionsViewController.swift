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
    let pairs = zip(
            ["top:", "left:", "bottom:", "right:"],
            [Int(insets.top), Int(insets.left), Int(insets.bottom), Int(insets.right)] )

    let nonZero = pairs.filter { $0.1 != 0 }

    if nonZero.isEmpty {
        return "UIEdgeInsets.zero"
    }
    else {
        return nonZero.map { "\($0.0)\($0.1)" }.joined(separator: " ")
    }

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
        return "Use Default"
    }
}

class OptionsViewController: UIViewController {

    var options: StackOptions

    let orientationButton = UIButton()
    let justifyButton = UIButton()
    let insetsButton = UIButton()
    let alignmentButton = UIButton()
    let spacingButton = UIButton()

    var optionsChanged: (()->())?

    init() {

        self.options = StackOptions(orientation: .horizontal, justify: nil, alignment: nil, insets: UIEdgeInsets.zero, spacing: 0)
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor(hex: 0x92E2E7)

        [orientationButton, justifyButton, insetsButton, alignmentButton, spacingButton].forEach(formatButton)

        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
        justifyButton.addTarget(self, action: #selector(onJustification), for: .touchUpInside)
        insetsButton.addTarget(self, action: #selector(onInsets), for: .touchUpInside)
        alignmentButton.addTarget(self, action: #selector(onAlignment), for: .touchUpInside)
        spacingButton.addTarget(self, action: #selector(onSpacing), for: .touchUpInside)


        let _ = stackViews(
                orientation: .vertical,
                parentView: self.view,
                justify: .start,
                alignment: .fill,
                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                spacing: 10,
                views: [
                        labeledRow("Orientation:", orientationButton),
                        labeledRow("Justify:", justifyButton),
                        labeledRow("Alignment", alignmentButton),
                        labeledRow("Insets:", insetsButton),
                        labeledRow("Spacing:", spacingButton)
                ],
                heights: [25, 25, 25, 25, 25])

        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onOrientation() {
        let items: [Orientation] = [.horizontal, .vertical]
        let currentIndex = items.index(where: { $0 == self.options.orientation }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty("Orientation:", [titles], [currentIndex]) {
            self.options.orientation = items[$0[0]]
        }

    }

    func onJustification() {
        let items: [Justify?] = [nil, .stretch, .start, .end]
        let currentIndex = items.index(where: { $0 == self.options.justify }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty("Justify:", [titles], [currentIndex]) {
            self.options.justify = items[$0[0]]
        }
    }

    func onInsets() {
        let items = [
                UIEdgeInsets.zero,
                UIEdgeInsets.create(top: 20),
                UIEdgeInsets.create(left: 20),
                UIEdgeInsets.create(bottom: 20),
                UIEdgeInsets.create(right: 20),
                UIEdgeInsets(horizontal: 20, vertical: 20)
        ]

        let currentIndex = items.index(where: { $0 == self.options.insets }) ?? 0
        let titles = items.map(formatInsets)

        onPickProperty("Insets:", [titles], [currentIndex]) {
            self.options.insets = items[$0[0]]
        }
    }

    func onAlignment() {
        let items: [Alignment?] = [
            nil,
            Alignment.start,
            Alignment.center,
            Alignment.end
        ]

        let currentIndex = items.index(where: { $0 ==? self.options.alignment }) ?? 0
        let titles = items.map(formatEnumValue)

        onPickProperty("Alignment:", [titles], [currentIndex]) {
            self.options.alignment = items[$0[0]]
        }
    }

    func onSpacing() {
        let items: [CGFloat] = [0, 20]
        let currentIndex = items.index(where: { $0 == self.options.spacing }) ?? 0
        let titles = items.map { "\(Int($0))" }

        onPickProperty("Spacing:", [titles], [currentIndex]) {
            self.options.spacing = items[$0[0]]
        }
    }

    func onPickProperty(_ title: String, _ items: [[String]], _ indexes:[Int], _ setNewSelection: @escaping ([Int]) -> ()) {
        startPicker(container: self, title: title, items: items, selectedIndexes: indexes) { success, indexes in
            if success {
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
    }

}