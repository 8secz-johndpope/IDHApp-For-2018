//
//  FactoryTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/28.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts

class FactoryTableViewCell: UITableViewCell {
    var factoryModel: HeatFactoryModel?{
        didSet{
            setUpViews()
        }
    }
    
    var titleLabel = UILabel()
    var datatime = UILabel()
    var labelArr:[UILabel] = []
    var pieChart = PieChartView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func setLabels() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(datatime)
        if needGroup {
            
            pieChart.backgroundColor = UIColor.white
            self.contentView.addSubview(pieChart)
        }
        for temp in labelArr {
            self.contentView.addSubview(temp)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        labelArr = []
        titleLabel.text = factoryModel?.Name
        datatime.text = factoryModel?.datatime
        if needGroup {
            
            showPieChart()
        }
        if let facModel = factoryModel {
        if facModel.tagArr.count > 0 {
            for index in 0..<facModel.tagArr.count{
                let label = UILabel()
                if index % 2 == 0{
                    label.frame = CGRect.init(x: 10, y: 230 + (index/2) * 15, width: Int(self.contentView.bounds.width/2), height: 20)
                }else{
                    label.frame = CGRect.init(x: Int(self.contentView.bounds.width/2), y: Int(230 + floorf(Float(index / 2)) * 15), width: Int(self.contentView.bounds.width/2), height: 20)
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
    
    func showPieChart() {
        let titleArr = ["在线", "不在线"]
        let colorArr = [UIColor.blue, UIColor.gray]
//        let unitSold = [(factoryModel?.online as! NSString).doubleValue , (factoryModel?.offline as! NSString).doubleValue]
        let unitSold = [Double(2), Double(8)]
        
        Chart.setPieChart(pieChart, dataPoints: titleArr, values: unitSold, legendColor: colorArr, showPie: true)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect.init(x: 10, y: 10, width: self.contentView.bounds.width/2, height: 20)
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel.adjustsFontSizeToFitWidth = true
        datatime.frame = CGRect(x: self.contentView.bounds.width/2, y: 10, width: self.contentView.bounds.width/2, height: 20)
        if needGroup {
            pieChart.frame = CGRect.init(x: 10, y: 30, width: self.contentView.bounds.width-20, height: 200)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
