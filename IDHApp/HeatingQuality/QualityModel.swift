//
//  QualityModel.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/24.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

class QualityModel {
    var ID:String?
    var Name: String?
    var Ratio: String?
    
    init(data:JSON) {
        self.ID = data["ID"].stringValue
        self.Name = data["Name"].stringValue
        self.Ratio = data["Ratio"].stringValue
    }
    
}

class QualityTemperatureModel {
    var ID:String?
    var Name: String?
    var Temperature: String?
    
    init(data:JSON) {
        self.ID = data["ID"].stringValue
        self.Name = data["Name"].stringValue
        self.Temperature = data["Temperature"].stringValue
    }
}
