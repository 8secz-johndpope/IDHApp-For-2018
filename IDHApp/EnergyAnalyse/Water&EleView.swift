//
//  Water&EleView.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/7.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

enum unitEnum:String {
    case heat = "(GJ)"
    case water = "(T)"
    case ele = "(kwh)"
    case gas = "(m³)"
    case heatUnit = "(GJ/万㎡.天)"
    case waterUnit = "(T/万㎡.天)"
    case eleUnit = "(kwh/万㎡.天)"
    case gasUnit = "(m³/万㎡.天)"
    case tem = "(℃)"
    case press = "(MPa)"
    case flux = "(m3/h)"
    case valve = "%"
}

class Water_EleView: UIView {

    @IBOutlet weak var consumeLabel: UILabel!
    @IBOutlet weak var totalConsume: UILabel!
    
    @IBOutlet weak var consumeData: UILabel!
    @IBOutlet weak var unitData: UILabel!
    @IBOutlet weak var totalData: UILabel!
    @IBOutlet weak var ratioData: UILabel!
    
    @IBOutlet weak var consumeUnit: UILabel!
    @IBOutlet weak var unitUnit: UILabel!
    @IBOutlet weak var totalUnit: UILabel!
    
    @IBOutlet weak var factoryButton: UIButton!
    @IBOutlet weak var exchangerButton: UIButton!
    @IBOutlet weak var facData: UILabel!
    @IBOutlet weak var facUnit: UILabel!
    @IBOutlet weak var excData: UILabel!
    @IBOutlet weak var excUnit: UILabel!
    
    @IBOutlet weak var maxOBJ: UIButton!
    @IBOutlet weak var minOBJ: UIButton!
    @IBOutlet weak var maxData: UILabel!
    @IBOutlet weak var minData: UILabel!
    @IBOutlet weak var maxUnit: UILabel!
    @IBOutlet weak var minUnit: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet var MyView: UIView!
    
    @IBOutlet weak var legendOne: UILabel!
    @IBOutlet weak var legendTwo: UILabel!
    
    var myType:ConsumeType = .water
    
    var myData:waterModel?
    
    var clousre:HeatClosure?
    
    
    @IBAction func toFactory(_ sender: UIButton) {
        if let call = clousre {
            call(myType,nil,true)
        }
    }
    
    @IBAction func toExchanger(_ sender: UIButton) {
        if let call = clousre {
            call(myType,nil,false)
        }
    }
    
    @IBAction func toMaxExc(_ sender: UIButton) {
        if let call = clousre {
            if let max = myData?.max{
                call(myType,max,false)
            }
        }
    }
    
    @IBAction func toMinExc(_ sender: UIButton) {
        if let call = clousre {
            if let min = myData?.min{
                call(myType,min,false)
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
        let nib = UINib(nibName: "Water&EleView", bundle: bundle)
        self.MyView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.MyView.frame = bounds
        self.addSubview(MyView)
    }
    func clearAll() {
        let arr = [consumeData,unitData, totalData, ratioData, maxData, minData,facData, facUnit, excData, excUnit]
        let arr1 = [maxOBJ,minOBJ]
        for temp in arr {
            temp?.text = "--"
        }
        for temp in arr1 {
            temp?.setTitle("--", for: .normal)
        }
    }
    
    func setUpData(_ data:JSON, type:ConsumeType) {
        self.myData = waterModel.init(data, type: type)
    
        if let myData = self.myData {
        if let water = myData.heat {
            if let consume = water.consume {
                consumeData.text = String.init(format: "%.2f", (consume as NSString).doubleValue)
            }
            if let un = water.unitConsume{
                unitData.text = String.init(format: "%.2f", (un as NSString).doubleValue)
            }
            if let tot = water.totalConsume{
                totalData.text = String.init(format: "%.2f", (tot as NSString).doubleValue)
            }
            if let rat = water.ratioConsume{
                ratioData.text = String.init(format: "%.0f", (rat as NSString).doubleValue) + "%"
            }
        }
            
            if let max = myData.max, !(max.Name?.isEmpty)! {
                maxOBJ.setTitle(max.Name, for: .normal)
                maxData.text = String.init(format: "%.2f", (max.Consume! as NSString).doubleValue)
            }
            
            if let min = myData.min, !(min.Name?.isEmpty)! {
                minOBJ.setTitle(min.Name, for: .normal)
                minData.text = String.init(format: "%.2f", (min.Consume! as NSString).doubleValue)
            }
            
            if let facC = myData.facConsume, !facC.isEmpty {
                facData.text = String.init(format: "%.2f", (facC as NSString).doubleValue) + (type == .water ? unitEnum.water.rawValue : unitEnum.ele.rawValue)
            }
            if let facU = myData.facRatio, !facU.isEmpty {
                facUnit.text = String.init(format: "%.0f", (facU as NSString).doubleValue) + "%"
            }
            if let excC = myData.eConsume, !excC.isEmpty{
                excData.text = String.init(format: "%.2f", (excC as NSString).doubleValue) + (type == .water ? unitEnum.water.rawValue : unitEnum.ele.rawValue)
            }
            if let excU = myData.eRatio, !excU.isEmpty{
                excUnit.text = String.init(format: "%.0f", (excU as NSString).doubleValue) + "%"
            }
        }
    }
    
    func setUpViews(_ type:ConsumeType) {
        clearAll()
        var text1 = ""
        var text2 = ""
        myType = type
        switch type {
        case .water:
            text1 = "所有热源厂总水耗" + unitEnum.water.rawValue
            text2 = "所有热力站总水耗" + unitEnum.water.rawValue
            consumeLabel.text = "水耗"
            totalConsume.text = "累计水耗"
            consumeUnit.text = unitEnum.water.rawValue
            unitUnit.text = unitEnum.waterUnit.rawValue
            totalUnit.text = unitEnum.water.rawValue
            factoryButton.setTitle("热源厂水耗", for: .normal)
            exchangerButton.setTitle("热力站水耗", for: .normal)
            maxUnit.text = unitEnum.waterUnit.rawValue
            minUnit.text = unitEnum.waterUnit.rawValue
//            maxOBJ
        default:
            text1 = "所有热源厂总电耗" + unitEnum.ele.rawValue
            text2 = "所有热力站总电耗" + unitEnum.ele.rawValue
            consumeLabel.text = "电耗"
            totalConsume.text = "累计电耗"
            consumeUnit.text = unitEnum.ele.rawValue
            unitUnit.text = unitEnum.eleUnit.rawValue
            totalUnit.text = unitEnum.ele.rawValue
            factoryButton.setTitle("热源厂电耗", for: .normal)
            exchangerButton.setTitle("热力站电耗", for: .normal)
            maxUnit.text = unitEnum.eleUnit.rawValue
            minUnit.text = unitEnum.eleUnit.rawValue
        }
        legendOne.text = text1
        legendTwo.text = text2
    }
    

}
