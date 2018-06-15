//
//  FactoryModels.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/14.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

class FactoryModels: NSObject {

}

//运行趋势
struct TrendHeatModel {
    var avgRetTem:String?
    var avgOutTem:String?
    var maxOutTem:String?
    var outdoorTem:String?
    var chartData:[heatChart]?
    
    init(_ data:JSON) {
        self.avgRetTem = data["AVGRetTemp"].stringValue
        self.avgOutTem = data["AvgOutTemp"].stringValue
        self.maxOutTem = data["MaxOutTemp"].stringValue
        self.outdoorTem = data["OutdoorTemp"].stringValue
        for temp in data["Chart"].arrayValue {
            let chart = heatChart.init(temp)
            chartData?.append(chart)
        }
    }
}

struct heatChart {
    var date:String?
    var outTem:Double?
    var retTem:Double?
    var dataTime:String?
    
    init(_ data:JSON) {
        self.date = data["DateTime"].stringValue
        self.dataTime = data["DataTime"].stringValue
        self.outTem = data["OutTemperature"].doubleValue
        self.retTem = data["RetTemperature"].doubleValue
    }
    
}

struct TrendPressureModel {
    var maxOutP:String?
    var minOutP:String?
    var chartData:[PressureChart]?
    
    init(_ data:JSON) {
        self.maxOutP = data["MaxOutPress"].stringValue
        self.minOutP = data["MinOutPress"].stringValue
        for temp in data["Chart"].arrayValue {
            let chart = PressureChart.init(temp)
            chartData?.append(chart)
        }
    }
}

struct PressureChart {
    var date:String?
    var outPre:Double?
    var retPre:Double?
    var dataTime:String?    //dataTime is for exchanger trend model especially
    init(_ data:JSON) {
        self.date = data["DateTime"].stringValue
        self.outPre = data["OutPressure"].doubleValue
        self.retPre = data["RetPressure"].doubleValue
        self.dataTime = data["DataTime"].stringValue
    }
    
}


struct TrendFluxModel {
    var maxInsF:String?
    var minInsF:String?
    var chartData:[FluxChart]?
    
    init(_ data:JSON) {
        self.maxInsF = data["MaxInstantflow"].stringValue
        self.minInsF = data["MinInstantflow"].stringValue
        for temp in data["Chart"].arrayValue {
            let chart = FluxChart.init(temp)
            chartData?.append(chart)
        }
    }
    
}

struct FluxChart {
    var date:String?
    var insFlux:Double?
    var dataTime:String?
    init(_ data:JSON) {
        self.date = data["DateTime"].stringValue
        self.insFlux = data["Instantflow"].doubleValue
                self.dataTime = data["DataTime"].stringValue
    }
}

struct TrendValveGivenModel {
    var maxValve:String?
    var minValve:String?
    var chartData:[ValveChart]?
    init(_ data:JSON) {
        self.maxValve = data["MaxValveGiven"].stringValue
        self.minValve = data["MinValveGiven"].stringValue
        for temp in data["Chart"].arrayValue {
            let model = ValveChart.init(temp)
            chartData?.append(model)
        }
    }
}

struct ValveChart {
    var time:String?
    var valve:Double?
    init(_ data:JSON) {
        self.time = data["DataTime"].stringValue
        self.valve = data["ValveGiven"].double
    }
    
    
}

struct EneryConsumeModel {
    var consume:String?
    var unitConsume:String?
    var totalConsume:String?
    var outdoorTem:String?
    
    init(_ data:JSON) {
        self.consume = data["YestodayConsume"].stringValue
        self.unitConsume = data["UnitConsume"].stringValue
        self.totalConsume = data["CumulativeConsume"].stringValue
        self.outdoorTem = data["OutdoorTemperature"].stringValue
    }
}

struct ExchangerEnergyModel {
    var consume:String?
    var unitConsume:String?
    var totalConsume:String?
    var outdoorTem:String?
    
    init(_ data:JSON) {
        self.consume = data["DayConsume"].stringValue
        self.unitConsume = data["UnitConsume"].stringValue
        self.totalConsume = data["CumulativeConsume"].stringValue
        self.outdoorTem = data["OutdoorTemperature"].stringValue
    }
}


struct EneryChartModel {
    var titles:[String]?
    var dayValues:[Double]?
    var unitValues:[Double]?
    
    init(_ data:JSON) {
        self.titles = data["DayConsume"].arrayValue.map({ (temp) -> String in
            
            let arr = temp["DateTime"].stringValue.components(separatedBy: " ").first!.components(separatedBy: "/")
//            str.components(separatedBy: "/")
//            let a = arr1.components(separatedBy: " ").first?.components(separatedBy: "/")
            
            let string = arr[1] + "/" + arr[2]
            
            return string
            
        })
        
        self.dayValues = data["DayConsume"].arrayValue.map({ (temp) -> Double in
            temp["Value"].doubleValue
        })
        self.unitValues = data["UnitConsume"].arrayValue.map({ (temp) -> Double in
            temp["Value"].doubleValue
        })
    }
}


struct QualityForFactory {
    var roomsData:[RoomModel] = []
    var totalCount:String?
    
    init(data:JSON) {
        self.totalCount = data["TotalCount"].stringValue
        let datas = data["ArrayData"].arrayValue
        for i in 0..<datas.count {
            roomsData.append(RoomModel.init(data: datas[i]))
        }
    }
}

struct RoomModel {
    var Count:String?
    var Percent:String?
    var Scope:String?
    
    init(data:JSON) {
        self.Count = data["Count"].stringValue
        self.Percent = data["Percent"].stringValue
        self.Scope = data["Scope"].stringValue
    }
}

struct SurveyModel {
    var Address:String?
    var HeatArea:String?
    var HexCount:String?
    var Latitude:String?
    var Leader:String?
    var Longitude:String?
    var Name:String?
    var PlannedHeatLoad:String?
    var Telephone:String?
    var HexType:String?
    var ParentName:String?
    
    init(_ data:JSON) {
        self.Address = data["Address"].stringValue
        self.HeatArea = data["HeatArea"].stringValue
        self.HexCount = data["HexCount"].stringValue
        self.Latitude = data["Latitude"].stringValue
        self.Longitude = data["Longitude"].stringValue
        self.Leader = data["Leader"].stringValue
        self.Name = data["Name"].stringValue
        self.PlannedHeatLoad = data["PlannedHeatLoad"].stringValue
        self.Telephone = data["Telephone"].stringValue
        self.HexType = data["HexType"].stringValue
        self.ParentName = data["ParentName"].stringValue
    }
}
