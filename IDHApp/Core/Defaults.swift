//
//  Defaults.swift
//  ErCiWang
//
//  Created by feidy on 2017/8/21.
//  Copyright © 2017年 Feidy. All rights reserved.
//

import Foundation
class Defaults{
    static let instance = Defaults()
    
    func getForKey(key:String)->[String: Any]?{
        return UserDefaults.standard.dictionary(forKey: key)
//        object(forKey: key) as? [String : String]
    }
    
    func setValue(forKey:String,forValue value:Any){
        return UserDefaults.standard.set(value, forKey: forKey)
    }
    
    func removeValue(key:String){
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
