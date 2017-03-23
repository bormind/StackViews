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

class DocsExampleHeaderViewController: UIViewController {

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
                orientation: .vertical,
                justify: .spaceBetween,
                align: .fill,
                views: [
                        applyLabel("First Name", ofWidth: 110, toField: firstName),
                        applyLabel("Middle Name", ofWidth: 110, toField: middleName),
                        applyLabel("Last Name", ofWidth: 110, toField: lastName)
                ],
                heights: [25, 25, 25])
            .container

        //Stack image and fields horizontally
        _ = stackViews(
                container: self.view,
                orientation: .horizontal,
                justify: .fill,
                align: .fill,
                insets: Insets(horizontal: 5, vertical: 5),
                spacing: 10,
                views: [image, fieldsStackView],
                widths: [100, nil])

        //set image view to be square
        image.widthAnchor.constraint(equalTo: image.heightAnchor, multiplier: 1).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private func nameRowsSection() -> UIView {
//        let section = UIView()
//
//
//    }

    private func applyLabel(_ label: String, ofWidth: CGFloat, toField: UITextField) -> UIView {
        let labelCtrl = UILabel()
        labelCtrl.text = label
        toField.placeholder = label

        return stackViews(
                    orientation: .horizontal,
                    justify: .fill,
                    align: .fill,
                    spacing: 3,
                    views: [labelCtrl, toField],
                    widths: [ofWidth, nil])
                .container

    }

}
