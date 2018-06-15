//
//  AlarmMenuTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/23.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class AlarmMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    var state:Bool = true{
        didSet{
            let imageName = state ? "RadioYes" : "RadioNo"
            let tColor = state ? UIColor.cyan : UIColor.white
            icon.image = UIImage.init(named: imageName)
            title.textColor = tColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.darkGray
        self.contentView.backgroundColor = UIColor.darkGray
        icon.isUserInteractionEnabled = true
        icon.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
