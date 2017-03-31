//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

fileprivate func formatTextField(_ textField: UITextField) {
    textField.borderStyle = .roundedRect
}

class FormExampleHeaderViewController: UIViewController {

    let image = UIImageView(image: UIImage(named: "PersonProfile"))
    let firstName = UITextField()
    let middleName = UITextField()
    let lastName = UITextField()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.steelBlue

        //Set border for better visibility
        [firstName, middleName, lastName].forEach(formatTextField)

        //Stack Fields vertically
        let fieldsStackView = stackViews(
                orientation: .vertical, // vertical stack of 3 rows
                justify: .fill, // because heights of all 3 rows set explicitly (no nil height row) this will make
                                // fieldsStackView height determined by the sum of rows heights and spaces between them

                align: .fill,  // fill all available space across stack axis (horizontally)
                spacing: 10, //vertical spacing between rows
                views: [
                        applyLabel("First Name", ofWidth: 110, toField: firstName),
                        applyLabel("Middle Name", ofWidth: 110, toField: middleName),
                        applyLabel("Last Name", ofWidth: 110, toField: lastName)
                ],
                heights: [25, 25, 25]) // height of each row
            .container

        //set image view to be a square
        image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 1).isActive = true

        //Stack imageView and fieldsStackView horizontally
        //We do not set any explicit widths or heights because height of the header
        //is determined by the height of the fieldsStackView and vertical insets.
        //Height of the image is determined by the height header. Width of the image is determined by image being square
        //And width of the fieldsStackView view we want to be stretchable to fill all the available horizontal space
        _ = stackViews(
                container: self.view, // use ViewController's view as a stack container
                orientation: .horizontal, //stack image and fieldsStackView horizontally
                justify: .fill, // fill all available space along stack axis (horizontally
                align: .fill, // fill all available space across stack axis (vertically)
                insets: Insets(horizontal: 5, vertical: 5), // set space between container view boundaries and
                                                            // and it's children
                spacing: 10, // space between image and fieldsStackView
                views: [image, fieldsStackView])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    //Groups fieldView with label as one row
    private func applyLabel(_ label: String, ofWidth: CGFloat, toField: UITextField) -> UIView {
        let labelCtrl = UILabel()
        labelCtrl.text = label
        toField.placeholder = label

        return stackViews(
                    orientation: .horizontal, //Horizontal row
                    justify: .fill, // fill all the available space in the parent view horizontally
                    align: .fill, // fill all the available space in the parent view vertically
                    spacing: 3, // space between label and fieldView
                    views: [labelCtrl, toField],
                    widths: [ofWidth, nil]) // label is a fixed size, fieldView will stretch fo fill the reso oa available space
                .container //return generated paren view (row)

    }

}
