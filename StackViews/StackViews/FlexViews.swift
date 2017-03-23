//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

internal func flexViews(orientation: Orientation,
                        views:[UIView],
                        flexValues:[CGFloat?],
                        dimensions: [CGFloat?]? = nil,
                        priority: UILayoutPriority? = nil) -> ([NSLayoutConstraint], [String]) {

    assert(views.count == flexValues.count)
    assert(dimensions == nil || views.count == dimensions!.count)

    let flexIndexes = (0..<flexValues.count).filter { flexValues[$0] != nil }

    if flexIndexes.count < 2 {
        return ([], [])
    }

    let keyIndex: Int
    var errors: [String] = []
    if let dimensions = dimensions {
        let indexesForSetDimensions = flexIndexes.filter { dimensions[$0] != nil }

        if indexesForSetDimensions.count > 0 {
            keyIndex = indexesForSetDimensions[0]
            if indexesForSetDimensions.count > 1 {
                errors.append("View Indexes \(indexesForSetDimensions) have explicit size and proportional values set at the same time\nOnly one view in the proportional view chain can have both values present at the same time.")
            }
        }
        else {
            keyIndex = 0
        }
    }
    else {
        keyIndex = 0
    }

    let keyFlexVal = flexValues[keyIndex]!

    let constraints =  flexIndexes
            .filter { $0 != keyIndex }
            .map {
                return views[$0].sameDimension(orientation, views[keyIndex], multiplier: flexValues[$0]! / keyFlexVal)
            }

    return (constraints, errors)
}
