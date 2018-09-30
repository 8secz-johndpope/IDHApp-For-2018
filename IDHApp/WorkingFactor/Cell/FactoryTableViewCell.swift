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
    var view = UIView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func setLabels() {
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(datatime)
        if needGroup {
            pieChart.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            self.contentView.addSubview(pieChart)
        }
        for temp in labelArr {
            self.contentView.addSubview(temp)
        }
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.contentView.addSubview(view)
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
        let titleArr = ["在线", "离线"]
        let colorArr = [#colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1), #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 0.7666075537)]
//        let unitSold = [(factoryModel?.online as! NSString).doubleValue , (factoryModel?.offline as! NSString).doubleValue]
        let unitSold = [(factoryModel?.online as! NSString).doubleValue, (factoryModel?.offline as! NSString).doubleValue]
        
        Chart.setPieChart(pieChart, dataPoints: titleArr, values: unitSold, legendColor: colorArr, showPie: true, color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = CGRect.init(x: 0, y: self.contentView.bounds.height-5, width: self.contentView.bounds.width, height: 5)
        
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
