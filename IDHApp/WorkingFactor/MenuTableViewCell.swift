//
//  MenuTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/2.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
protocol TapDelegate {
//    func getTapCell()
}

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
        titleLabel.frame = CGRect.init(x: 5, y: 0, width: self.contentView.bounds.width - 5, height: self.contentView.bounds.height)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class MenuCell: UITableViewCell {
    var icon = MenuButton()
    var title = UILabel()
    var level:Int = 0   //等级
    let offset:CGFloat = 20//偏移量 每一级偏移20
    var editor = LayoutableView()
    var index:IndexPath?{
        didSet{
            icon.index = index
        }
    }
    
    var isClose:Bool = true{
        didSet{
            let imageName = isClose ? "close" : "open"
            self.icon.setImage(UIImage.init(named: imageName), for: .normal)
        }
    }
    
    var childs:[TreeGroupModel] = []    //子分组
    
    var data:TreeGroupModel!{
        willSet{
            if let child = newValue.List{
                self.childs = child
                if childs.isEmpty{
                    
                    self.icon.isHidden = true
                }else{
                    self.icon.isHidden = false
                }
            }else{
                self.icon.isHidden = true
            }

            
            self.title.text = newValue.Name
            if let type = newValue.Type {
                switch type{
                case "heatfactory":
                    level = 0
                case "group":
                    level = 1
                case "subsystem":
                    level = 2
                default:
                    break
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        editor.frame = CGRect.init(x: CGFloat(level)*offset+10, y: 5, width: 220, height: self.contentView.frame.height-10)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.gray
        
        title.font = UIFont.systemFont(ofSize: 14)
        editor.layout = WeightsLayout.init(horizontal: true)
        editor.layout?.weights = [1,4]
//        if let inde = self.index {
//
//            icon.index = inde
//        }
        
        editor.addSubview(icon)
        editor.addSubview(title)

        
        self.addSubview(editor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class MenuButton: UIButton {
    var index:IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
//    init(_ index:IndexPath) {
//        self.index = index
////        super.init()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
