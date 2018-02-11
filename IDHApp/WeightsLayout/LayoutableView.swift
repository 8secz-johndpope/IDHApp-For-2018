//
//  LayoutableView.swift
//  Impasto
//
//  Created by Ecsoya on 17/03/2017.
//  Copyright © 2017 Soyatec. All rights reserved.
//

import UIKit

class LayoutableView: UIView {

    var layout: WeightsLayout? = WeightsLayout() {
        didSet {
            layoutDatas.removeAll(keepingCapacity: false)
            doLayout()
        }
    }

    var layoutDatas = [UIView: WeightsLayoutData]()

    init() {
        super.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func doLayout() {
        layout?.layoutDatas = layoutDatas
        layout?.layout(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout?.layoutDatas = layoutDatas
        layout?.layout(self, size: bounds.size)
    }

    func addSubview(_ view: UIView, layoutData: WeightsLayoutData) {
        super.addSubview(view)
        layoutDatas[view] = layoutData
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        layoutDatas[subview] = nil
    }
}
