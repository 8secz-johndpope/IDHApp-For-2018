//
//  WeightsLayoutData.swift
//  Impasto
//
//  Created by Ecsoya on 31/03/2017.
//  Copyright © 2017 Soyatec. All rights reserved.
//

import UIKit

class WeightsLayoutData {

    var width: CGFloat = 0
    var height: CGFloat = 0 

    var alignment: WeightsLayoutAlignment = .fill

    init(width: CGFloat = 0, height: CGFloat = 0, alignment: WeightsLayoutAlignment = .fill) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

enum WeightsLayoutAlignment {
    case fill, left, center, right, top, bottom
}
