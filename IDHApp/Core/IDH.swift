//
//  IDH.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/19.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift
import KissXML
import Alamofire

var document:DDXMLDocument?
var mappingArr: [MappingModel] = []
var queue = DispatchQueue(label: "loadData", qos: .default, attributes: .concurrent)

class IDH{
    var originalID = 1
     
    class func setupCore(_ user: Any) {
//use for simulator for no camera to get info
        
//         {"idh_ip_port":"http://221.2.85.190:6099","homs_ip_port":"http://221.2.85.190:8000","homs_mapping_ip_port":"http://221.2.85.190:8010","group_id":"1","weather_id":"101110101","city":"西安","version":"1","group_name":"西安市热力"}
//         http://192.168.2.134:6099/Analyze.svc
//        西安高新热力（idh）
//            {"idh_ip_port":"113.140.66.34:6099","homs_ip_port":"","homs_mapping_ip_port":"","idh_monitor_ip_port":"113.140.66.34:8000","group_id":"2","weather_id":"101110101","city":"西安","version":"1","group_name":"西安高新热力"}
        


        
//        homs_mapping_ip_port = "219.145.102.165:8010"
//        homs_ip_port = "222.169.194.218:9000"
//        idh_ip_port = "222.169.194.218:6099"
//        groupid = "1"
//        city = "西安"
//        weatherid = "101110101"
//        currentVersion = "0"
//        idh_monitor_ip_port = ""
//        group_name = "轻轨热力"
        
//        homs_mapping_ip_port = "219.145.102.165:8010"
//        homs_ip_port = "222.170.8.174:8000"
//        idh_ip_port = "222.170.8.174:6099"
//        groupid = ""
//        city = "西安"
//        weatherid = ""
//        currentVersion = "2"
//        idh_monitor_ip_port = ""
//        group_name = "东琰热力"
        
        
//        homs_mapping_ip_port = ""
//        homs_ip_port = ""
//        idh_ip_port = "113.140.66.34:6099"
//        groupid = "2"
//        city = "西安"
//        weatherid = ""
//        currentVersion = "1"
//        idh_monitor_ip_port = "113.140.66.34:8000"
//        group_name = "高新热力"
//        needGroup = false
        
        //            {"idh_ip_port":"221.2.85.190:6099","homs_ip_port":"221.2.85.190:8000","homs_mapping_ip_port":"221.2.85.190:8010","idh_monitor_ip_port":"","group_id":"1","weather_id":"101110101","city":"费县","version":"3","group_name":"费县热力"}
//        homs_mapping_ip_port = "221.2.85.190:8010"
//        homs_ip_port = "221.2.85.190:8000"
//        idh_ip_port = "221.2.85.190:6099"
//        groupid = "1"
//        city = "费县"
//        weatherid = "101110101"
//        currentVersion = "3"
//        idh_monitor_ip_port = ""
//        group_name = "费县热力"
        
        
        //        {"idh_ip_port":"124.114.131.38:6099","homs_ip_port":"124.114.131.38:8000","homs_mapping_ip_port":"124.114.131.38:8010","idh_monitor_ip_port":"","group_id":"1","weather_id":"101110101","city":"西安","version":"3","group_name":"西安市热力"}
        
//        homs_mapping_ip_port = "124.114.131.38:8010"
//        homs_ip_port = "124.114.131.38:8000"
//        idh_ip_port = "124.114.131.38:6099"
//        groupid = "1"
//        city = "西安"
//        weatherid = "101110101"
//        currentVersion = "3"
//        idh_monitor_ip_port = ""
//        group_name = "西安市热力"
        
         let myDic = user as! [String:String]
         print("\(myDic)")
        homs_mapping_ip_port = myDic["homs_mapping_ip_port"]!
         homs_ip_port = myDic["homs_ip_port"]!
         idh_ip_port = myDic["idh_ip_port"]!

         groupid = myDic["group_id"]!
         city = myDic["city"]!
         weatherid = myDic["weather_id"]!
         currentVersion = myDic["version"]!
//        currentVersion = "1"
         idh_monitor_ip_port = myDic["idh_monitor_ip_port"]!
         group_name = myDic["group_name"]!
         needGroup = false
        
    }
    
    class func getVCFromStr(_ str: String) -> UIViewController {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let cls = NSClassFromString(namespace + "." + str) as! UIViewController.Type
        let vc = cls.init()
        return vc
    }
    
    class func getFuncFromStr(_ str: String) -> Selector{
        let sec = NSSelectorFromString(str)
        return sec
    }
    
    //test only
    class func setupCoreByplist() {
//        let path = Bundle.main.path(forResource: "Mine", ofType: "plist")
//        let myDic = NSDictionary.init(contentsOfFile: path!)
//        
//        homs_mapping_ip_port = myDic!["homs_mapping_ip_port"]! as! String
//        homs_port = myDic!["homs_port"]! as! String
//        idh_port = myDic!["idh_port"]! as! String
//        groupid = myDic!["groupid"] as! String
//        city = myDic!["city"] as! String
//        weatherid = myDic!["weatherid"] as! String
//        port = myDic!["port"] as! String
//        currentVersion = myDic!["version"] as! String
        
    }

    class func getMapping(){
        Alamofire.request(MappingURL, method: .get).responseData { reponse in
            if reponse.result.isSuccess{
                let data = reponse.value
                do{
                    let doc = try DDXMLDocument.init(data: data!, options: 0)
                    document = doc
                    let items = try! document?.nodes(forXPath: "//item") as! [DDXMLElement]
                    for item in items{
                        if let name = item.attribute(forName: "Name")?.stringValue, let ID = item.attribute(forName: "ID")?.stringValue, let Type = item.attribute(forName: "Type")?.stringValue{
                            let num = ID
                            let model = MappingModel.init(name, Type, ID: num)
                            mappingArr.append(model)
                        }
                    }
                    IDH.getTreeDataSource("topviews.xml", 1)
                }catch{
                    print("no xml mapping")
                }
            }else{
                print("get map failed")
            }
        }
    }
    
    class func getType(_ str: String, parentName: String) -> MappingModel?{
        for model in mappingArr {
            if model.name.contains("."){
                var arr = model.name.components(separatedBy: ".")
                
                if str == arr.last && parentName == arr[arr.count - 2]{
                    
                    return model
                }
//                if model.name == "\(parentName).\(str)"{
//                }
            }else{
                if model.name == str{
                    return model
                }
            }
        }
        return nil
    }
    
    class func getTreeDataSource(_ path: String, _ parentID: Int) {
        Alamofire.request(MonitorURL, method: .get, parameters: ["action": "get", "path": path]).responseData { reponse in
            if reponse.result.isSuccess{
                if let data = reponse.value{
                    do{
                        let doc = try DDXMLDocument.init(data: data, options: 0)
                        let objects = try! doc.nodes(forXPath: "//objects/object") as! [DDXMLElement]
                        let root = doc.rootElement()
                        
                        for i in 0..<objects.count{
                            if let name = objects[i].attribute(forName: "name")?.stringValue{
                                if name.lowercased().hasPrefix("ob".lowercased()){
                                }else{
                                    let model = heatModel()
                                    let obj = objects[i]
                                    if let location = obj.elements(forName: "location").first{
                                        if let x = location.attribute(forName: "x")?.stringValue{
                                            model.x = percentToFloat(x)
                                        }
                                        if let y = location.attribute(forName: "y")?.stringValue{
                                            model.y = percentToFloat(y)
                                        }
                                        if let width = location.attribute(forName: "width")?.stringValue{
                                            model.width = percentToFloat(width)
                                        }
                                        if let height = location.attribute(forName: "height")?.stringValue{
                                            model.height = percentToFloat(height)
                                        }
                                    }
                                    
                                    model.parent_name = (root?.attribute(forName: "name")?.stringValue)!
                                    if let back = root?.elements(forName: "background").first, let file = back.attribute(forName: "filename")?.stringValue{
                                        model.image_path = file
                                    }
                                    if let width = root?.attribute(forName: "width")?.stringValue, let height = root?.attribute(forName: "height")?.stringValue {
                                        model.parent_width = Float(width)!
                                        model.parent_height = Float(height)!
                                    }
                                    model.area_name = name
                                    var arr = path.components(separatedBy: "/")
                                    arr.removeLast()
                                    arr.append("\(name)/\(name).xml")
                                    let str = arr.joined(separator: "/")
                                    model.path = str
                                    if let mappingModel = IDH.getType(name, parentName: model.parent_name){
                                        model.idh_id = mappingModel.ID
                                        model.type = mappingModel.type
                                    }
                                    
                                    model.area_id = parentID * 100 + i
                                    model.parent_id = parentID
                                    
                                    print("----\(model.area_id)---\(model.parent_id)---\(model.idh_id)-----\(model.area_name)-----\(model.parent_name)")
                                    //queue
                                    queue.async {
                                        let realm = try! Realm()
                                        realm.beginWrite()
                                        if realm.objects(heatModel.self).filter("area_name = '\(model.area_name)' AND parent_name = '\(model.parent_name)'").isEmpty{
                                            realm.add(model)
                                        }else{
                                            //更新
//                                            let mo = realm.objects(heatModel.self).filter("area_name = '\(model.area_name)' AND parent_name = '\(model.parent_name)'").first
//                                            mo?.update(model)
                                            }
                                        try! realm.commitWrite()
                                    }
                                    self.getTreeDataSource(str, model.area_id)
                                }
                            }
                        }
                        AppProvider.instance.setVersion()
                        if AppProvider.instance.appVersion == .homs03 || AppProvider.instance.appVersion == .homsOther{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: self, userInfo: nil)
                        }
                    }catch{
                        print("error---\(path)")
                    }
                }
            }else{
                print(reponse.error!)
            }
        }
    }
}
