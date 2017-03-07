//
// Created by Boris Schneiderman on 2017-01-28.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews


class InteractiveExampleViewController: UIViewController {

    let stackViewController: InteractiveStackViewController
    let optionsViewController: OptionsViewController

    init() {

        self.stackViewController = InteractiveStackViewController()
        self.optionsViewController = OptionsViewController(viewTitles: stackViewController.viewTitles)

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor.white

        title = "Interactive StackViews"

        optionsViewController.optionsChanged = self.onOptionsChanged

        let _ = self.view.stackViews(
                    orientation: .vertical,
                    justify: .fill,
                    align: .fill,
                    insets: UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0),
                    views: [optionsViewController.view, stackViewController.view],
                    heights: [255, nil])

        onOptionsChanged()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createControlPanel() -> UIView {
        let controlsPanel = UIView()



        return controlsPanel
    }

    public func onOptionsChanged() {
        stackViewController.render(options: self.optionsViewController.options)
    }


}
