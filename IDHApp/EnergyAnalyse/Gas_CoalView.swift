//
//  Gas_CoalView.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/8.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

class Gas_CoalView: UIView {
    @IBOutlet weak var consumeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var consumeData: UILabel!
    @IBOutlet weak var unitData: UILabel!
    @IBOutlet weak var totalData: UILabel!
    @IBOutlet weak var ratioData: UILabel!
    
    @IBOutlet weak var consumeUnit: UILabel!
    @IBOutlet weak var unitUnit: UILabel!
    @IBOutlet weak var totalUnit: UILabel!
    
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var minButton: UIButton!
    @IBOutlet weak var maxData: UILabel!
    @IBOutlet weak var minData: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var minUnit: UILabel!
    
    @IBOutlet var MyView: UIView!
    
    @IBOutlet weak var legendOne: UILabel!
    
    var data:gasModel?
    var call:HeatClosure?
    var myType:ConsumeType = .gas
    
    
    @IBAction func toMax(_ sender: UIButton) {
        if let clousre = call {
            if let max = data?.max{
                clousre(myType, max,false)
            }
        }
    }
    @IBAction func toMin(_ sender: UIButton) {
        if let clousre = call {
            if let min = data?.min{
                clousre(myType, min,false)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initfromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initfromNib()
    }
    
    func initfromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Gas_CoalView", bundle: bundle)
        self.MyView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.MyView.frame = bounds
        self.addSubview(MyView)
    }
    
    func setUpViews(_ type:ConsumeType) {
        clearAll()
        myType = type
        switch type {
        case .gas:
            legendOne.text = "日气耗" + unitEnum.gas.rawValue
            consumeLabel.text = "气耗"
            totalLabel.text = "累计气耗"
            consumeUnit.text = unitEnum.gas.rawValue
            unitUnit.text = unitEnum.gasUnit.rawValue
            totalUnit.text = unitEnum.gas.rawValue
            minUnit.text = unitEnum.gasUnit.rawValue
            unit.text = unitEnum.gasUnit.rawValue
            maxLabel.text = "最大气耗"
            minLabel.text = "最小气耗"
        default:
            legendOne.text = "日煤耗" + unitEnum.water.rawValue
            consumeLabel.text = "煤耗"
            totalLabel.text = "累计煤耗"
            consumeUnit.text = unitEnum.water.rawValue
            unitUnit.text = unitEnum.waterUnit.rawValue
            totalUnit.text = unitEnum.water.rawValue
            minUnit.text = unitEnum.waterUnit.rawValue
            unit.text = unitEnum.waterUnit.rawValue
            maxLabel.text = "最大煤耗"
            minLabel.text = "最小煤耗"
        }
    }
    
    func clearAll() {
        let arr = [consumeData,unitData, totalData, ratioData, maxData, minData]
        let arr1 = [maxButton,minButton]
        for temp in arr {
            temp?.text = "--"
        }
        for temp in arr1 {
            temp?.setTitle("--", for: .normal)
        }
    }

    
    func setData(_ type:ConsumeType, data:JSON) {
        self.data = gasModel.init(data)
        if let mydata = self.data {
            if let heat = mydata.heat{
                if let data = heat.consume, !data.isEmpty{
                    
                    consumeData.text = String.init(format: "%.2f", (data as NSString).doubleValue)
                }
                if let data = heat.unitConsume, !data.isEmpty{
                    
                    unitData.text = String.init(format: "%.2f", (data as NSString).doubleValue)
                }
                if let data = heat.totalConsume, !data.isEmpty{
                    
                    totalData.text = String.init(format: "%.2f", (data as NSString).doubleValue)
                }
                if let data = heat.ratioConsume, !data.isEmpty{
                    
                    ratioData.text = String.init(format: "%.0f", (data as NSString).doubleValue) + "%"
                }
                
//                unitData.text = heat.unitConsume
//                totalData.text = heat.totalConsume
//                ratioData.text = heat.ratioConsume
            }
            if let max = mydata.max, !(max.Consume?.isEmpty)!{
                maxButton.setTitle(max.Name, for: .normal)
                maxData.text = String.init(format: "%.0f", (max.Consume! as NSString).doubleValue)
            }
            if let min = mydata.min, !(min.Consume?.isEmpty)!{
                minButton.setTitle(min.Name, for: .normal)
                minData.text = String.init(format: "%.0f", (min.Consume! as NSString).doubleValue)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
