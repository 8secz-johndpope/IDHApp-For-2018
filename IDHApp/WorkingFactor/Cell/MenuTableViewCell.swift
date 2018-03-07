//
//  MenuTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/22.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
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
        super.layoutSubviews()
        titleLabel.frame = CGRect.init(x: 5, y: 5, width: self.contentView.bounds.width - 5, height: self.contentView.bounds.height-10)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
