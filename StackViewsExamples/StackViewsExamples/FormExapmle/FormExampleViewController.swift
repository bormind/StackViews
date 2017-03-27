//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

//This is recreation of example from Apple Stack View Documentation Using StackViews
// https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/LayoutUsingStackViews.html
class FormExampleViewController: UIViewController {

    let header = FormExampleHeaderViewController()
    let footer = FormExampleFooterViewController()

    let textView = UITextView()

    init() {
        super.init(nibName: nil, bundle: nil)

        self.title = "Form Example"

        textView.text = "Notes:"

        self.view.backgroundColor = UIColor.white
        textView.backgroundColor = UIColor.gray

        //Stack vertically header textView and footer
        //We don't need to set heights because footer and header have heights determined by there content
        //And we want textView to stretch to fill available space
        //We dont need to set width's because we want all views to stretch horizontally to fill all the space
        let rootStack = stackViews(
                orientation: .vertical,
                justify: .fill,
                align: .fill,
                insets: Insets(horizontal: 5), //Set horizontal insets between container and child views
                spacing: 5,
                views: [header.view, textView, footer.view])
            .container

        //Because we want to contraint outer view to ViewController's guides instead of view boundaries
        //We use helper function form StackViews library
        _ = constrainToGuides(rootStack, inViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}