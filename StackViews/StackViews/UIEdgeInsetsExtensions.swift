//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal extension UIEdgeInsets {
    var leading: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
                ? self.left
                : self.right
    }

    var trailing: CGFloat {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
                ? self.right
                : self.left
    }

    func start(_ orientation: Orientation) -> CGFloat {
        switch orientation {
        case .horizontal:
            return self.leading
        case .vertical:
            return self.top
        }
    }

    func end(_ orientation: Orientation) -> CGFloat {
        switch orientation {
        case .horizontal:
            return self.trailing
        case .vertical:
            return self.bottom
        }
    }
}
