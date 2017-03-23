//
// Created by Boris Schneiderman on 2017-03-19.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

fileprivate enum Actions {
    case save
    case cancel
    case clear
}

class DocsExampleFooterViewController: UIViewController {

    let saveButton = UIButton()
    let cancelButton = UIButton()
    let clearButton = UIButton()


    init() {
        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = UIColor.white

        saveButton.setTitle("Save", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        clearButton.setTitle("Clear", for: .normal)

        [saveButton, cancelButton, clearButton].forEach(formatButton)

        _ = stackViews(
                container: self.view,
                orientation: .horizontal,
                justify: .center,
                align: .fill,
                insets: Insets(vertical: 10),
                spacing: 5,
                views: [saveButton, cancelButton, clearButton],
                widths: [100, 100, 100],
                heights: [25, 25, 25]
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func formatButton(_ button: UIButton) {
        button.setTitleColor(UIColor.blue, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightGray.cgColor
    }
}
