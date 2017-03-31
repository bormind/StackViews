//
// Created by Boris Schneiderman on 2017-01-28.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit

import StackViews


class InteractiveExampleViewController: UIViewController {

    let stackViewController: InteractiveRenderingViewController
    let optionsViewController: OptionsPanelViewController

    init() {

        self.stackViewController = InteractiveRenderingViewController()
        self.optionsViewController = OptionsPanelViewController(viewTitles: stackViewController.viewTitles)

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor.white

        self.title = "Interactive Example"

        optionsViewController.optionsChanged = self.onOptionsChanged

        let _ = stackViews(
                    container: self.view,
                    orientation: .vertical,
                    justify: .fill,
                    align: .fill,
                    insets: Insets(top: 64),
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
