//
//  HeatFactoryModel.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/22.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class HeatFactoryModel: NSObject {
    var ID = ""
    var Name = ""
    var flag = ""
    var datatime: String = ""
    var tagArr:[[String: String]] = []
    
    init(id: String, name:String, flag:String, datatime:String,tagArr:[[String:String]]) {
        
        super.init()
        self.ID = id
        self.Name = name
        self.flag = flag
        self.datatime = datatime
        self.tagArr = tagArr
    }
    
    //第一种 模型中的属性等于字典中的key并且一一对应，那么可以赋值
    //第二种 模型中的属性大于字典中的key即模型中除了与字典一一对应的属性外还有其他属性，那么这个赋值也有用
    //第三种 模型中的属性小于或者字典中存在模型中没有的属性名称，那么就会报错，此时只需重载下面的方法即可
    
    override func setValue(_ value: Any?, forUndefinedKey key:String) {
    }
}
