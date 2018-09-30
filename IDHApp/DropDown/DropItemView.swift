//
//  DropItemView.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/9/12.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class DropItemView: UIView {

    
    @IBOutlet weak var group: UILabel!
    
    @IBOutlet var MyView: UIView!
    var selected = false
    
    var groupModel:GroupIPModel?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initfromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initfromNib()
    }
    
    func initfromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DropItemView", bundle: bundle)
        self.MyView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.MyView.frame = bounds
        self.addSubview(MyView)
    }
    
    //加载xib
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if selected {
            self.group.textColor = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
        }else{
        }
    }

}
