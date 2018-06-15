//
//  AdviceTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/6/11.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class AdviceTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var advice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView(_ alamo:AlarmModel) {
        info.numberOfLines = 0
        advice.numberOfLines = 0
        time.numberOfLines = 0
        time.text = alamo.Datatime
        value.text = alamo.CurrentValue
        info.text = alamo.Message
        info.adjustsFontSizeToFitWidth = true
        advice.adjustsFontSizeToFitWidth = true
        time.adjustsFontSizeToFitWidth = true
        advice.text = alamo.Advice
    }
    
    
}
