//
//  AnalyseModel.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

class AnalyseModel {
    var consume:String?
    var unitConsume:String?
    var totalConsume:String?
    var ratioConsume:String?
    
    init(_ data:JSON) {
        self.consume = data["YestodayConsume"].stringValue
        self.unitConsume = data["UnitConsume"].stringValue
        self.totalConsume = data["CumulativeConsume"].stringValue
        self.ratioConsume = data["RelativeRatio"].stringValue
    }
}


class HeatAnalyseModel {
    var consume:String?
    var unitConsume:String?
    var totalConsume:String?
    var ratioConsume:String?
    
    init(_ data:JSON) {
        self.consume = data["YestodayConsume"].stringValue
        self.unitConsume = data["UnitConsume"].stringValue
        self.totalConsume = data["CumulativeConsume"].stringValue
        self.ratioConsume = data["UnitRelativeratio"].stringValue
    }
}

struct stationModel {
    var ID:String?
    var Name:String?
    var Consume:String?
    
    init(_ data:JSON) {
        self.ID = data["ID"].stringValue
        self.Name = data["Name"].stringValue
        self.Consume = data["Consume"].stringValue
    }
}

struct waterModel {
    var max:stationModel?
    var min: stationModel?
    var heat:HeatAnalyseModel?
    var facConsume:String?
    var facRatio:String?
    var eConsume:String?
    var eRatio:String?
    
    init(_ data:JSON,type:ConsumeType) {
        max = stationModel.init(data["MaxValue"])
        min = stationModel.init(data["MinValue"])
        heat = HeatAnalyseModel.init(data)
        
        facConsume = data["HeatFactory\(type.rawValue)Cosume"]["YestodayConsume"].stringValue
        facRatio = data["HeatFactory\(type.rawValue)Cosume"]["Relativeratio"].stringValue
        eConsume = data["HeatExchanger\(type.rawValue)Cosume"]["YestodayConsume"].stringValue
        eRatio = data["HeatExchanger\(type.rawValue)Cosume"]["Relativeratio"].stringValue
    }
}

struct eleModel {
    var max:stationModel
    var min: stationModel
    var heat:HeatAnalyseModel
    var facConsume:String?
    var facRatio:String?
    var eConsume:String?
    var eRatio:String?
    
    init(_ data:JSON) {
        max = stationModel.init(data["MaxValue"])
        min = stationModel.init(data["MinValue"])
        heat = HeatAnalyseModel.init(data)
        facConsume = data["HeatFactoryElectricityCosume"]["YestodayConsume"].stringValue
        facRatio = data["HeatFactoryElectricityCosume"]["Relativeratio"].stringValue
        eConsume = data["HeatExchangerElectricityCosume"]["YestodayConsume"].stringValue
        eRatio = data["HeatExchangerElectricityCosume"]["Relativeratio"].stringValue
    }
}

struct gasModel {
    var heat:HeatAnalyseModel?
    var max:stationModel?
    var min:stationModel?
    
    init(_ data:JSON) {
        max = stationModel.init(data["MinValue"])
        min = stationModel.init(data["MaxValue"])
        heat = HeatAnalyseModel.init(data)
    }
}

struct HeatAnaModel {
    var fHeat:HeatAnalyseModel?
    var eHeat:HeatAnalyseModel?
    var maxF:stationModel?
    var maxE:stationModel?
    var minE:stationModel?
    
    init(_ data:JSON) {
        if let fac = data["HeatFactory"].dictionary {
            maxF = stationModel.init(fac["MaxValue"]!)
        }
        
        if let exc = data["HeatExchanger"].dictionary {
            maxE = stationModel.init(exc["MaxValue"]!)
            minE = stationModel.init(exc["MinValue"]!)
        }
        
        fHeat = HeatAnalyseModel.init(data["HeatFactory"])
        eHeat = HeatAnalyseModel.init(data["HeatExchanger"])
    }
    
}

