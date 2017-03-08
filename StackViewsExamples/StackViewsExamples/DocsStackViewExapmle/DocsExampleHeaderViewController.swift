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


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    private func nameRowsSection() -> UIView {
//        let section = UIView()
//
//
//    }

    private func applyLabel(_ label: String, field: UITextField) -> UIView {
        let labelCtrl = UILabel()
        labelCtrl.text = label
        field.placeholder = label

        return stackViews(
                    orientation: .horizontal,
                    justify: .fill,
                    align: .center,
                    spacing: 3,
                    views: [labelCtrl, field],
                    widths: [70, nil]).container

    }
}