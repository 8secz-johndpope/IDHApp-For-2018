//
//  resultTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class resultTableViewCell: UITableViewCell {
    var data:HFModel?{
        didSet{
            setData()
        }
    }
//    var collection:resultCollectionView?
    
    func setData() {
//        collection?.model = data
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        collection = resultCollectionView()
//        self.contentView.addSubview(collection!)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
