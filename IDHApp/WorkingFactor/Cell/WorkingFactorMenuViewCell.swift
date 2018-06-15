//
//  WorkingFactorMenuViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/3/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class WorkingFactorMenuViewCell: UITableViewCell {


    @IBOutlet weak var offset_cons: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var isHaveChild: Bool = false
    var isClose: Bool = true{
        didSet{
            if self.isClose {
                self.icon.image = #imageLiteral(resourceName: "close")
            }else{
                self.icon.image = #imageLiteral(resourceName: "open")
            }
        }
    }
    
//    var child = []
    
//    var data
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
