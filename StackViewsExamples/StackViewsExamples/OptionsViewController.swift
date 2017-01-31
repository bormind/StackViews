//
// Created by Boris Schneiderman on 2017-01-30.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews


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
            widths: [170, nil])

    return row
}


class OptionsViewController: UIViewController {

    var options: StackOptions

    let orientationButton = UIButton()
    let justifyButton = UIButton()

    var optionsChanged: (()->())?

    init() {

        self.options = StackOptions(orientation: .horizontal, justify: .stretch)
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor(hex: 0x92E2E7)

        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
        orientationButton.setTitleColor(UIColor.black, for: .normal)

        justifyButton.addTarget(self, action: #selector(onJustification), for: .touchUpInside)
        justifyButton.setTitleColor(UIColor.black, for: .normal)

        let _ = stackViews(
                orientation: .vertical,
                parentView: self.view,
                insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                justify: .start,
                alignment: .fill,
                spacing: 10,
                views: [
                        labeledRow("Orientation:", orientationButton),
                        labeledRow("Justify:", justifyButton)
                ],
                heights: [25, 25])

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
    }

}