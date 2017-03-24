//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

//This is recreation of example from Apple Stack View Documentation Using StackViews
// https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html
class DocsExampleViewController: UIViewController {

    let header = DocsExampleHeaderViewController()
    let footer = DocsExampleFooterViewController()

    let textView = UITextView()

    init() {
        super.init(nibName: nil, bundle: nil)

        textView.text = "Notes:"

        self.view.backgroundColor = UIColor.white
        textView.backgroundColor = UIColor.gray

        //Stack header at the top
        let rootStack = stackViews(
                orientation: .vertical,
                justify: .fill,
                align: .fill,
                insets: Insets(horizontal: 5),
                spacing: 5,
                views: [header.view, textView, footer.view])

            .container

        embedView(rootStack, inViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}