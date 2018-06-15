//
//  HeatViewDeatils.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/7.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias HeatClosure = (_ type:ConsumeType, _ model:stationModel?, _ fac:Bool?) -> Void

class HeatViewDeatils: UIView {
    var closure:HeatClosure?
    
    
    @IBOutlet var MyView: UIView!
    
    @IBAction func toFactory(_ sender: UIButton) {
        if let call = closure {
            
            call(.heat, nil, true)
        }
    }
    
    @IBOutlet weak var consume: UILabel!
    @IBOutlet weak var ratioConsume: UILabel!
    @IBOutlet weak var totalConsume: UILabel!
    @IBOutlet weak var unitConsume: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var maxFactory: UIButton!
    
    @IBAction func toExchangers(_ sender: UIButton) {
        if let call = closure {
            call(.heat, nil,false)
        }
    }
    @IBOutlet weak var maxConsumeNum: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initfromNib()
    }
    @IBOutlet weak var eConsume: UILabel!
    @IBOutlet weak var minExchanger: UIButton!
    
    @IBOutlet weak var minExchangerNum: UILabel!
    @IBOutlet weak var maxExchangerNum: UILabel!
    @IBOutlet weak var maxExchanger: UIButton!
    @IBOutlet weak var eRatioConsume: UILabel!
    @IBOutlet weak var eTotalConsume: UILabel!
    @IBOutlet weak var eUnitConsume: UILabel!
    
    var data:HeatAnaModel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initfromNib()

    }
    
    @IBAction func toMaxFactory(_ sender: UIButton) {
        if let call = closure {
            if let data = data, let fac = data.maxF, !(fac.ID?.isEmpty)!{
                call(.heat, fac,false)
            }
        }
    }
    
    @IBAction func toMaxExchanger(_ sender: UIButton) {
        if let call = closure {
            if let data = data, let maxE = data.maxE, !(maxE.ID?.isEmpty)!{
                
                call(.heat, maxE,false)
            }
        }
    }
    
    @IBAction func toMinExchanger(_ sender: UIButton) {
        if let call = closure {
            if let data = data, let minE = data.minE, !(minE.ID?.isEmpty)!{
                
                call(.heat, minE,false)
            }
        }
    }
    
    func initfromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DetailView", bundle: bundle)
        self.MyView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.MyView.frame = bounds
        totalConsume.adjustsFontSizeToFitWidth = true
        eTotalConsume.adjustsFontSizeToFitWidth = true
        self.addSubview(MyView)
    }
    
    func setUpView(_ data:JSON) {
        totalConsume.adjustsFontSizeToFitWidth = true
        eTotalConsume.adjustsFontSizeToFitWidth = true
        self.data = HeatAnaModel.init(data)
        if let data = self.data {
            if let fh = data.fHeat{
            consume.text = String.init(format: "%.2f", (fh.consume! as NSString).doubleValue)
            ratioConsume.text = String.init(format: "%.0f", (fh.ratioConsume! as NSString).doubleValue) + "%"
            unitConsume.text = String.init(format: "%.2f", (fh.ratioConsume! as NSString).doubleValue)
            totalConsume.text = String.init(format: "%.2f", (fh.totalConsume! as NSString).doubleValue)
            }
            if let eh = data.eHeat{
                eConsume.text = String.init(format: "%.2f", (eh.consume! as NSString).doubleValue)
                eRatioConsume.text = String.init(format: "%.0f", (eh.ratioConsume! as NSString).doubleValue) + "%"
                eUnitConsume.text = String.init(format: "%.2f", (eh.ratioConsume! as NSString).doubleValue)
                eTotalConsume.text = String.init(format: "%.2f", (eh.totalConsume! as NSString).doubleValue)
//            eConsume.text = data.eHeat?.consume
//            eRatioConsume.text = data.eHeat?.ratioConsume
//            eUnitConsume.text = data.eHeat?.unitConsume
//            eTotalConsume.text = data.eHeat?.totalConsume
            }
            
            if let max = data.maxF {
                if let name = max.Name, !name.isEmpty{
                maxFactory.isEnabled = true
//                maxFactory.tag = (max.ID as! NSString).integerValue
                maxConsumeNum.text = max.Consume
                maxFactory.setTitle(name, for: .normal)
                }
            }else{
                maxFactory.isEnabled = false
            }
            if let max = data.maxE {
                if let name = max.Name, !name.isEmpty{
                maxExchanger.isEnabled = true
//                    maxExchanger.tag = 100 + (max.ID! as NSString).integerValue
                    maxExchangerNum.text = max.Consume
                maxExchanger.setTitle(name, for: .normal)
                }
            }else{
                maxExchanger.isEnabled = false
            }
            if let max = data.minE {
                if let name = max.Name, !name.isEmpty{
                minExchanger.isEnabled = true
//                minExchanger.tag = 100 + (max.ID as! NSString).integerValue
                minExchangerNum.text = max.Consume
                minExchanger.setTitle(name, for: .normal)
                }else{
                    minExchanger.isEnabled = false
                }
            }
        }
    }
}
