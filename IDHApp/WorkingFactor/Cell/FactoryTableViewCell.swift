//
//  FactoryTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/28.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class FactoryTableViewCell: UITableViewCell {
    var factoryModel: HeatFactoryModel?{
        didSet{
            setUpViews()
        }
    }
    
    var titleLabel = UILabel()
    var datatime = UILabel()
    var labelArr:[UILabel] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func setLabels() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(datatime)
        for temp in labelArr {
            self.contentView.addSubview(temp)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        labelArr = []
        titleLabel.frame = CGRect.init(x: 10, y: 10, width: self.contentView.bounds.width/2, height: 20)
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = factoryModel?.Name
        titleLabel.adjustsFontSizeToFitWidth = true
        datatime.frame = CGRect(x: self.contentView.bounds.width/2, y: 10, width: self.contentView.bounds.width/2, height: 20)
        datatime.text = factoryModel?.datatime
        if let facModel = factoryModel {
        if facModel.tagArr.count > 0 {
            for index in 0..<facModel.tagArr.count{
                let label = UILabel()
                if index % 2 == 0{
                    label.frame = CGRect.init(x: 10, y: 40 + (index/2) * 15, width: Int(self.contentView.bounds.width/2), height: 20)
                }else{
                    label.frame = CGRect.init(x: Int(self.contentView.bounds.width/2), y: Int(40 + floorf(Float(index / 2)) * 15), width: Int(self.contentView.bounds.width/2), height: 20)
                }
                label.font = UIFont.systemFont(ofSize: 12)
                label.adjustsFontSizeToFitWidth = true
                
                let model = facModel.tagArr[index]
                
                label.text = "\(model["TagName"]!):\(model["TagValue"]!) \(model["TagUnit"]!)"
                labelArr.append(label)
            }
        }
            
        }
        setLabels()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
