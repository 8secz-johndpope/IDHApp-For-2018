//
//  GlobalTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/25.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class GlobalTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
        var titleLabel = UILabel()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            titleLabel.textAlignment = .left
            self.backgroundColor = UIColor.gray
            titleLabel.font = UIFont.systemFont(ofSize: 20)
            addSubview(titleLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            titleLabel.frame = CGRect.init(x: 5, y: 0, width: self.contentView.bounds.width - 5, height: self.contentView.bounds.height)
        }

}
