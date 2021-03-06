//
//  CollectionViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/29.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var exchangerModel:exchangerModel?{
        didSet{
            setUpDatasForGroup()
        }
    }
    
    var exchangerModel1:HeatExchangeModel?{
        didSet{
            setUpDatas()
        }
    }
    
    var titleLabel = UILabel()
    var datatimeLabel = UILabel()
    var itemOne = UILabel()
    var itemTwo = UILabel()
    var itemThree = UILabel()
    var itemFour = UILabel()
    
    var textArr: [String]?
    
    var detailView = LayoutableView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(datatimeLabel)
        self.addSubview(detailView)
        setUpViews()
        setUpDetails()
        self.backgroundColor = #colorLiteral(red: 0.862745098, green: 0.8745098039, blue: 0.8901960784, alpha: 1)
    }
    
    func setUpDetails() {
        detailView.layout = WeightsLayout(horizontal: false)
        detailView.layout?.weights = [1,1,1,1]
        itemOne.textColor = UIColor.gray
        var font:CGFloat = 0
        
        if UIScreen.main.bounds.height < 569 {
            font = 10
        }else{
            font = 12
        }
        itemOne.font = UIFont.systemFont(ofSize: font)
        itemTwo.font = UIFont.systemFont(ofSize: font)
        itemThree.font = UIFont.systemFont(ofSize: font)
        itemFour.font = UIFont.systemFont(ofSize: font)
        detailView.addSubview(itemOne)
        detailView.addSubview(itemTwo)
        detailView.addSubview(itemThree)
        detailView.addSubview(itemFour)
    }
    
    func setUpViews() {
        titleLabel.textAlignment = .left
        datatimeLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 12)
//        datatimeLabel.textColor = #colorLiteral(red: 0.1711417295, green: 0.6183155089, blue: 0.6635651525, alpha: 1)
        datatimeLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    func setUpDatasForGroup() {
        clearTextContent()
        titleLabel.text = exchangerModel?.Name
        if let flag = exchangerModel?.State {
            if flag == "在线"{
                titleLabel.textColor = #colorLiteral(red: 0.1711417295, green: 0.6183155089, blue: 0.6635651525, alpha: 1)
                datatimeLabel.textColor = #colorLiteral(red: 0.1711417295, green: 0.6183155089, blue: 0.6635651525, alpha: 1)
            }else{
                titleLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
                datatimeLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
            }
        }else{
            titleLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
            datatimeLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
        }
        if let date = exchangerModel?.DataTime {
        datatimeLabel.text = date.components(separatedBy: " ").last
        }
        if let model = exchangerModel?.ItemList {
            for i in 0..<model.count{
                
                let attributeValue = [NSAttributedStringKey.foregroundColor: UIColor.gray]
                let valueAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
                let textVValue = NSMutableAttributedString.init(string: model[i].TagValue, attributes: valueAttribute)
                let textName = NSMutableAttributedString.init(string: model[i].TagName, attributes: attributeValue)
                let textUnit = NSMutableAttributedString.init(string: model[i].TagUnit, attributes: attributeValue)
                textName.append(textVValue)
                textName.append(textUnit)
                switch i{
                case 0:
                    itemOne.attributedText = textName
                case 1:
                    itemTwo.attributedText = textName
                case 2:
                    itemThree.attributedText = textName
                case 3:
                    itemFour.attributedText = textName
                default:
                    print("other details")
                }
            }
        }
    }
    
    func setUpDatas() {
        clearTextContent()
        titleLabel.text = exchangerModel1?.Name
        if let flag = exchangerModel1?.flag {
            if flag == "0"{
                titleLabel.textColor = #colorLiteral(red: 0.1711417295, green: 0.6183155089, blue: 0.6635651525, alpha: 1)
                datatimeLabel.textColor = #colorLiteral(red: 0.1711417295, green: 0.6183155089, blue: 0.6635651525, alpha: 1)
            }else{
                titleLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
                datatimeLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
            }
        }else{
            titleLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
            datatimeLabel.textColor = #colorLiteral(red: 0.2431372549, green: 0.2431372549, blue: 0.2431372549, alpha: 1)
        }
        if let date = exchangerModel1?.datatime {
            datatimeLabel.text = date.components(separatedBy: " ").last
        }
        if let model = exchangerModel1?.tagArr {
            for i in 0..<model.count{
                
                let attributeValue = [NSAttributedStringKey.foregroundColor: UIColor.gray]
                let valueAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
                let textVValue = NSMutableAttributedString.init(string: model[i]["TagValue"]!, attributes: valueAttribute)
                let textName = NSMutableAttributedString.init(string: model[i]["TagName"]!, attributes: attributeValue)
                let textUnit = NSMutableAttributedString.init(string: model[i]["TagUnit"]!, attributes: attributeValue)
                textName.append(textVValue)
                textName.append(textUnit)
                switch i{
                case 0:
                    itemOne.attributedText = textName
                case 1:
                    itemTwo.attributedText = textName
                case 2:
                    itemThree.attributedText = textName
                case 3:
                    itemFour.attributedText = textName
                default:
                    print("other details")
                }
            }
        }
    }
    
    func clearTextContent() {
        itemOne.text = ""
        itemTwo.text = ""
        itemThree.text = ""
        itemFour.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect.init(x: 5, y: 5, width: self.frame.width-5, height: 20)
        datatimeLabel.frame = CGRect.init(x: 5, y: 25, width: self.frame.width-5, height: 20)
        detailView.frame = CGRect.init(x: 5, y: 45, width: self.frame.width - 5, height: 80)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
