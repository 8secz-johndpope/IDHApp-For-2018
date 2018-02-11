//
//  HeatExchangeModel.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/22.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class HeatExchangeModel: NSObject {
    var ID:String = ""
    var Name:String = ""
    var flag:String = ""
    var datatime:String = ""
    var tagArr:[[String: String]] = []
    
    
    init(id:String, name: String, flag: String, datatime:String, tagArr:[[String: String]]) {
        super.init()
        self.ID = id
        self.Name = name
        self.flag = flag
        self.datatime = datatime
        self.tagArr = tagArr
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    

}
