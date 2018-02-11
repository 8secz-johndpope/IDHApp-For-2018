//
//  CollectionReusableView.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/29.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    
    var factoryTitle = UILabel()
    var model: HeatFactoryModel? {
        didSet{
            setupFactory()
        }
    }
    
    func setupFactory(){
        if let model = model {
            factoryTitle.text = model.Name
            
        }else{
            factoryTitle.text = nil
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        factoryTitle.backgroundColor = #colorLiteral(red: 0.9531560842, green: 0.9531560842, blue: 0.9531560842, alpha: 1)
        factoryTitle.textAlignment = .left
        factoryTitle.textColor = UIColor.gray
        factoryTitle.font = UIFont.systemFont(ofSize: 15)
        addSubview(factoryTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        factoryTitle.frame = CGRect.init(x: 5, y: 10, width: self.bounds.width-10, height: 40)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
