//
//  TrendCollectionViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/9/20.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class TrendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var unit: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        title.adjustsFontSizeToFitWidth = true
        number.adjustsFontSizeToFitWidth = true
        unit.adjustsFontSizeToFitWidth = true
//        // Initialization code
    }
    
    func setItemValue(data:ParmesList) {
        
        self.title.text = data.name
        self.number.text = data.value
        self.unit.text = data.unit
    }
    

}
