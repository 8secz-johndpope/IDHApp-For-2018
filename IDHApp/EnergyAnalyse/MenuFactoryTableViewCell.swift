//
//  MenuFactoryTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/25.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class MenuFactoryTableViewCell: UITableViewCell {
    var data:GroupingInfo!{
        didSet{
            FactoryTitle.text = data.GroupingName
        }
    }
    

    @IBOutlet weak var FactoryTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
