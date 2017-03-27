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

class FormExampleFooterViewController: UIViewController {

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

        //Stack buttons horizontally
        _ = stackViews(
                container: self.view, //pass in UIViewController's view as a container
                orientation: .horizontal,
                justify: .center, //Buttons will be arranged in the center along the stacking axis
                align: .fill, //Because we set align to .fill and explicitly specify height of the buttons
                              //The full height of the footer will be determined by sum of button height and vertical insets
                              //If we wanted the height of the footer to be determined by it's parent
                              //we we would set the align parameter to .center instead og .fill
                insets: Insets(vertical: 10), //Vertical insets from the edges of the container to children views
                spacing: 5, //horizontal spacing between buttons
                views: [saveButton, cancelButton, clearButton],
                widths: [100, 100, 100], //For stackViews being able to justify controls in the middle of the container
                                         //We have to provide button's width explicitly
                heights: [25, 25, 25]    //Set heights of the buttons
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func formatButton(_ button: UIButton) {
        button.setTitleColor(UIColor.blue, for: .normal)
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor.lightGray.cgColor
    }
}
