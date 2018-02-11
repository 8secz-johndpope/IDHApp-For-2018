//
//  WeightsLayout.swift
//  Impasto
//
//  Created by Ecsoya on 17/03/2017.
//  Copyright © 2017 Soyatec. All rights reserved.
//

import UIKit

class WeightsLayout {

    var hMargin: CGFloat = 0

    var vMargin: CGFloat = 1

    var spacing: CGFloat = 0

    var weights: [Int] = []

    var horizontal = true

    var layoutDatas = [UIView: WeightsLayoutData]()

    // Layout subviews if the frame has been changed by this Layout.
    var delegate: WeightsLayoutDelegate?

    init() {
    }

    init(horizontal: Bool) {
        self.horizontal = horizontal
    }

    init(weights: [Int]) {
        self.weights = weights
    }

    func layout(_ view: UIView) {
        layout(view, size: view.bounds.size)
    }

    func layout(_ view: UIView, size: CGSize) {
        layout(view.subviews, width: size.width, height: size.height)
    }

    func layout(_ views: [UIView], width: CGFloat, height: CGFloat) {
        if weights.isEmpty {
            weights = Array.init(repeating: 1, count: views.count)
        }
        if horizontal {
            let contentWidth = width - hMargin * 2 - spacing * CGFloat(views.count - 1)
            var widths = [CGFloat]()
            let totalWeight = getTotalWeight(weights)
            for i in 0 ..< weights.count {
                widths.append(CGFloat((contentWidth / CGFloat(totalWeight)) * CGFloat(weights[i])))
            }

            var x: CGFloat = hMargin, y: CGFloat = vMargin, w: CGFloat, h: CGFloat = height - vMargin * 2
            let count = min(views.count, widths.count)
            for i in 0 ..< count {
                w = widths[i]
                let cellBounds = CGRect(x: x, y: y, width: w, height: h)
                layout(views[i], inCell: cellBounds, horizontal: true)
                delegate?.layoutSubviews(views[i])
                x += w + spacing
                y = vMargin
            }
        } else {
            let contentHeight = height - vMargin * 2 - spacing * CGFloat(views.count - 1)
            var heights = [CGFloat]()
            let totalWeight = getTotalWeight(weights)
            for i in 0 ..< weights.count {
                heights.append(CGFloat((contentHeight / CGFloat(totalWeight)) * CGFloat(weights[i])))
            }

            var x: CGFloat = hMargin, y: CGFloat = vMargin, h: CGFloat, w: CGFloat = width - hMargin * 2
            let count = min(views.count, heights.count)
            for i in 0 ..< count {
                h = heights[i]
                layout(views[i], inCell: CGRect(x: x, y: y, width: w, height: h), horizontal: false)
                delegate?.layoutSubviews(views[i])
                y += h + spacing
                x = hMargin
            }

        }
    }

    private func layout(_ view: UIView, inCell bounds: CGRect, horizontal: Bool) {
        var width = CGFloat(0)
        var height = CGFloat(0)
        var alignment = WeightsLayoutAlignment.fill

        if let layoutData = layoutDatas[view] {
            width = layoutData.width
            height = layoutData.height
            alignment = layoutData.alignment
        } else {
            let size = view.intrinsicContentSize
            if view.frame.size.width > 0 {
                width = view.frame.size.width
            } else {
                width = size.width
            }
            if view.frame.size.height > 0 {
                height = view.frame.size.height
            } else {
                height = size.height
            }
        }

        if width <= 0 || width > bounds.height{
            width = bounds.width
        }
        if height <= 0 || height > bounds.height{
            height = bounds.height
        }

        if horizontal {
            let y = bounds.minY + (bounds.height - height) / 2
            switch alignment {
            case .left:
                view.frame = CGRect(x: bounds.minX, y: y, width: width, height: height)
            case .right:
                view.frame = CGRect(x: bounds.minX + (bounds.width - width), y: y, width: width, height: height)
            case .center:
                view.frame = CGRect(x: bounds.minX + (bounds.width - width) / 2, y: y, width: width, height: height)
            default:
                view.frame = CGRect(x: bounds.minX, y: y, width: bounds.width, height: height)
            }
        } else {
            let x = bounds.minX + (bounds.width - width) / 2
            switch alignment {
            case .top:
                view.frame = CGRect(x: x, y: bounds.minY, width: width, height: height)
            case .bottom:
                view.frame = CGRect(x: x, y: bounds.minY + (bounds.height - height), width: width, height: height)
            case .center:
                view.frame = CGRect(x: x, y: bounds.minY + (bounds.height - height) / 2, width: width, height: height)
            default:
                view.frame = CGRect(x: x, y: bounds.minY, width: width, height: bounds.height)
            }
        }
    }

    private func getTotalWeight(_ weights: [Int]) -> Int {
        var sum = 0
        for value in weights {
            sum += value
        }
        return sum
    }
    
}

protocol WeightsLayoutDelegate {
    func layoutSubviews(_ parent: UIView)
}
