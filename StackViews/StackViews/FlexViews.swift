//
// Created by Boris Schneiderman on 2017-03-07.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation

fileprivate func findKeyIndexForDimensions(_ indexes: [Int], _ dimensions: [CGFloat?]) -> Int {

    let indexesForSetDimensions = indexes.filter { dimensions[$0] != nil }

    guard indexesForSetDimensions.count > 0 else {
        return 0
    }

    if indexesForSetDimensions.count > 1 {
        print("StackViews: View Indexes \(indexesForSetDimensions) have explicit size and proportional values set at the same time\nOnly one view in the proportional view chain can have both values present at the same time.")
    }

    return indexesForSetDimensions[0]
}

func flexViews(orientation: Orientation)
        -> ([UIView], [CGFloat?], [CGFloat?]?, UILayoutPriority?)
        -> [NSLayoutConstraint] {

    return { (views, flexValues, dimensions, priority) in

        assert(views.count == flexValues.count)
        assert(dimensions == nil || views.count == dimensions!.count)

        let flexIndexes = (0 ..< flexValues.count).filter {
            flexValues[$0] != nil
        }

        if flexIndexes.count < 2 {
            return []
        }

        let keyIndex: Int
        if let dimensions = dimensions {
            keyIndex = findKeyIndexForDimensions(flexIndexes, dimensions)
        } else {
            keyIndex = 0
        }

        let keyFlexVal = flexValues[keyIndex]!

        let setRelativeDimension = constraintRelativeDimension(orientation, views[keyIndex])

        return flexIndexes
                .filter {  $0 != keyIndex  }
                .map { setRelativeDimension(views[$0], flexValues[$0]! / keyFlexVal) }
    }
}
