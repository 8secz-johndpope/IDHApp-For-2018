//
//  AlarmModel.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/23.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import SwiftyJSON

class AlarmModel{
    var CurrentValue:String?
    var Datatime:String?
    var DiffSeconds:String?
    var Message:String?
    var Advice:String?
    
    
    init(data:JSON) {
        self.CurrentValue = data["CurrentValue"].stringValue
        self.Datatime = data["Datatime"].stringValue
        self.DiffSeconds = data["DiffSeconds"].stringValue
        self.Message = data["Message"].stringValue
        self.Advice = data["Advice"].stringValue
    }

}
