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
    var insets: UIEdgeInsets
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

class OptionsViewController: UIViewController {

    var options: StackOptions

    let orientationButton = UIButton()
    let justifyButton = UIButton()
    let insetsButton = UIButton()

    var optionsChanged: (()->())?

    init() {

        self.options = StackOptions(orientation: .horizontal, justify: .stretch, insets: UIEdgeInsets.zero)
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor(hex: 0x92E2E7)

        [orientationButton, justifyButton, insetsButton].forEach(formatButton)

        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
        justifyButton.addTarget(self, action: #selector(onJustification), for: .touchUpInside)
        insetsButton.addTarget(self, action: #selector(onInsets), for: .touchUpInside)


        let _ = stackViews(
                orientation: .vertical,
                parentView: self.view,
                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                justify: .start,
                alignment: .fill,
                spacing: 10,
                views: [
                        labeledRow("Orientation:", orientationButton),
                        labeledRow("Justify:", justifyButton),
                        labeledRow("Insets:", insetsButton)
                ],
                heights: [25, 25, 25])

        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onOrientation() {
        let items: [Orientation] = [.horizontal, .vertical]
        let currentIndex = items.index(where: { $0 == self.options.orientation })
        let titles = items.map { ".\($0)" }

        onPickProperty(titles, currentIndex) {
            self.options.orientation = items[$0]
        }

    }

    func onJustification() {
        let items: [Justify] = [.stretch, .start, .end]
        let currentIndex = items.index(where: { $0 == self.options.justify })
        let titles = items.map { ".\($0)" }

        onPickProperty(titles, currentIndex) {
            self.options.justify = items[$0]
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

        let currentIndex = items.index(where: { $0 == self.options.insets })
        let titles = items.map(formatInsets)

        onPickProperty(titles, currentIndex) {
            self.options.insets = items[$0]
        }
    }

    func onPickProperty(_ titles: [String], _ currentIndex: Int?, _ setNewIndex: @escaping (Int) -> ()) {
        pickOne(container: self, titles: titles, selectedIndex: currentIndex) { selectedIndex in
            if let selectedIndex = selectedIndex,
                selectedIndex != currentIndex {
                setNewIndex(selectedIndex)
                self.updateUI()
                self.optionsChanged?()
            }
        }
    }

    private func updateUI() {
        orientationButton.setTitle(".\(self.options.orientation)", for: .normal)
        justifyButton.setTitle(".\(self.options.justify)", for: .normal)
        insetsButton.setTitle(formatInsets(self.options.insets), for: .normal)
    }

}