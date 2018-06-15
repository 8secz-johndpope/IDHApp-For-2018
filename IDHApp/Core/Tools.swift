//
//  Tools.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/2.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

class Tools {
    //设置日期控件最大值为当前日期及默认显示昨天
    class func setDataPickerDate(_ myDatePicker:UIDatePicker,checkedDate:String){
        let currentDate = Date().addingTimeInterval(8*60*60)
        myDatePicker.maximumDate = currentDate
        
        //设置日期控件选中日期
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.date(from: checkedDate)
        myDatePicker.setDate(selectedDate!, animated: true)
    }
    
    //获取选中的日期字符串
    class func getSelectedDateString(_ myDatePicker:UIDatePicker) -> String{
        let selectedDate = myDatePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: selectedDate)
    }
    

    
    //截取月份与日 或 时与分 或 时与分与秒
    class func getStrFromDateString(_ date:String,returnType:String = "day") -> String{
        var result = ""
        
        if !date.isEmpty{
            //默认
            var start = date.index(date.startIndex, offsetBy: 5)
            var end = date.rangeOfCharacter(from: CharacterSet.whitespaces)!.lowerBound
            
            if returnType == "minute"{
                start = date.index(after: date.rangeOfCharacter(from: CharacterSet.whitespaces)!.lowerBound)
                end = date.index(date.endIndex, offsetBy: -3)
            }
            else if returnType == "second"{
                start = date.index(after: date.rangeOfCharacter(from: CharacterSet.whitespaces)!.lowerBound)
                end = date.endIndex
            }
            
//            let range = (start ..< end)
            result = String(date[start..<end])
        }
        
        return result
    }
    
    
    class func getHeatModel(_ id:String, isFactor:Bool = false) -> heatModel? {
        let realm = try! Realm()
        print("idh_id = '\(id)' AND type = '换热站'")
//        let model = realm.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
        if isFactor{
            
            let model = realm.objects(heatModel.self).filter("idh_id = '\(id)'").filter("type = '热源厂'").first
            return model
        }else{
            
            let model = realm.objects(heatModel.self).filter("idh_id = '\(id)'").filter("type = '换热站'").first
            return model
        }
//        print(model!)
        
    }
    
    class func getarrs(_ id:String) -> [HeatExchangeModel] {
        for excs in heatExchangeArr {
            
            for temp in excs.heatExchangerList{
                if id == temp.ID{
                    return excs.heatExchangerList
                }
            }
            
            
        }
        
//        for excs in heatExchangeArr {
//            for temp in excs.heatExchangerList{
//                if id == temp.ID{
//                    return excs.heatExchangerList
//                }
//            }
//        }
        
        return []
    }
    
    
    class func getIndex(_ id:String, isFactor:Bool = false) -> Int {
        
        if !isFactor{
            let arr = getarrs(id)
            for index in 0..<arr.count {
                if id == arr[index].ID{
                    return index
                }
            }
        }else{
            let arr = getFacArr(id: id)
            for index in 0..<arr.count {
                if id == arr[index].ID{
                    return index
                }
        }
        }
        return 0
    }
    
    class func getFacArr(id:String) -> [HeatFactoryModel]{
        var arr:[HeatFactoryModel] = []
        
        for temp in heatExchangeArr {
            arr.append(temp.heatFactory)
        }
        return arr
    }
    
    class func setMonitors(_ id:String, isFactor:Bool = false) {
//        let moni = myVC as! ExchangerMixMonitorViewController

        model = getHeatModel(id, isFactor: isFactor)
        if isFactor{
            facModels = getFacArr(id: id)
        }else{
            models = getarrs(id)
        }
//        models = getarrs(id)
        current = getIndex(id, isFactor: isFactor)
    }
    
    
//    class func getHeatModels(_ id:String, isFactor:Bool = false) -> heatModel? {
//        let realm = try! Realm()
//        return realm.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
//    }

}
