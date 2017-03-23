//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

class DocsExampleHeaderViewController: UIViewController {

    let icon = UIImageView(image: UIImage(named: "PersonProfile"))
    let firstName = UITextField()
    let middleName = UITextField()
    let lastName = UITextField()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.white

        //set image view to be square
        icon.widthAnchor.constraint(equalTo: icon.heightAnchor, multiplier: 1).isActive = true

        //Set border for better visibility
        [firstName, middleName, lastName].forEach { $0.borderStyle = .roundedRect }

        //Stack Fields vertically
        let fieldsView = stackViews(
                orientation: .vertical,
                justify: .spaceBetween,
                align: .fill,
                views: [
                        applyLabel("First Name", ofWidth: 120, toField: firstName),
                        applyLabel("Middle Name", ofWidth: 120, toField: middleName),
                        applyLabel("Last Name", ofWidth: 120, toField: lastName)
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
                views: [icon, fieldsView],
                //make icon width of 100
                widths: [100, nil])


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
