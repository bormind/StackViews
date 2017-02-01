//
// Created by Boris Schneiderman on 2017-01-31.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

func ==? <T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    if let lhs = lhs, let rhs = rhs {
        return lhs == rhs
    }
    else {
        return lhs == nil && rhs == nil
    }
}

infix operator ==? { associativity left precedence 130 }