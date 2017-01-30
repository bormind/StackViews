//
// Created by Boris Schneiderman on 2017-01-28.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews

struct StackOptions {
    var orientation: Orientation
    var justify: Justify
}



class InteractiveExampleViewController: UIViewController {

    let orientationButton = UIButton()
    let justifyButton = UIButton()

    var options: StackOptions

    let stackView = UIView()

    init() {

        self.options = StackOptions(orientation: .horizontal, justify: .stretch)

        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white

        title = "Interactive StackViews"

        orientationButton.addTarget(self, action: #selector(onOrientation), for: .touchUpInside)
        orientationButton.backgroundColor = UIColor.orange

        let controlsPanel = createControlPanel()

        controlsPanel.backgroundColor = UIColor.blue
        stackView.backgroundColor = UIColor.green


        let _ = stackViews(
                    orientation: .vertical,
                    parentView: self.view,
                    insets: UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0),
                    justify: .stretch,
                    views: [controlsPanel, stackView],
                    heights: [200, nil])

        updateUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createControlPanel() -> UIView {
        let controlsPanel = UIView()

        let _ = stackViews(
                    orientation: .vertical,
                    parentView: controlsPanel,
                    insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                    justify: .start,
                    alignment: .fill,
                    spacing: 10,
                    views: [
                            labeledRow("Orientation:", orientationButton),
                            labeledRow("Justify:", justifyButton)
                    ],
                    heights: [25, 25])

        return controlsPanel
    }

    private func labeledRow(_ label: String, _ ctrl: UIView) -> UIView {
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

    private func updateUI() {
        orientationButton.setTitle(String(describing: self.options.orientation), for: .normal)
        justifyButton.setTitle(String(describing: self.options.justify), for: .normal)
    }

    func onOrientation() {
        let items: [Orientation] = [.horizontal, .vertical]
        let currentIndex = items.index(where: { $0 == self.options.orientation })
        let titles = items.map { ".\($0)" }
        pickOne(container: self, titles: titles, selectedIndex: currentIndex) { selectedIndex in
            if let selectedIndex = selectedIndex,
               selectedIndex != currentIndex {
                self.options.orientation = items[selectedIndex]
                self.updateUI()
            }
        }
    }
}