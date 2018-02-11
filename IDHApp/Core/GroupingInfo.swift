//
//  GroupingInfo.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/22.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class GroupingInfo: NSObject {
    @objc var GroupingID = ""
    @objc var GroupingType = ""
    @objc var GroupingName = ""
    
    init(dic: NSDictionary) {
        super.init()
        self.setValuesForKeys(dic as! [String : AnyObject])
    }
    
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    
    
    
    
    
    

}
