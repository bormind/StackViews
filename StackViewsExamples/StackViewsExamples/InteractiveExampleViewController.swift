//
// Created by Boris Schneiderman on 2017-01-28.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews


class InteractiveExampleViewController: UIViewController {

    let optionsViewController = OptionsViewController()
    let stackViewController = InteractiveStackViewController()

    init() {

        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white

        title = "Interactive StackViews"

        optionsViewController.optionsChanged = self.onOptionsChanged

        let _ = stackViews(
                    orientation: .vertical,
                    parentView: self.view,
                    justify: .stretch,
                    insets: UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0),
                    views: [optionsViewController.view, stackViewController.view],
                    heights: [200, nil])

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