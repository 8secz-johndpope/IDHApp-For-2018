//
//  DBManager.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/9.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class heatModel: Object {
    @objc dynamic var idh_id: String = ""
    @objc dynamic var parent_id: Int = 0
    @objc dynamic var area_id: Int = 0
    @objc dynamic var area_name = ""
    @objc dynamic var parent_name = ""
    @objc dynamic var width: Float = 0
    @objc dynamic var height: Float = 0
    @objc dynamic var parent_width: Float = 0
    @objc dynamic var parent_height: Float = 0
    @objc dynamic var x: Float = 0
    @objc dynamic var y: Float = 0
    @objc dynamic var path = ""
    @objc dynamic var image_path = ""
    @objc dynamic var type = ""
    @objc dynamic var is_last:Bool = false
    
    override static func primaryKey() -> String? {
        return "area_id"
    }
    
    func update(_ model: heatModel) {
//        self.idh_id = model.idh_id
//        self.parent_id = model.parent_id
//        self.area_name = model.area_name
//        self.parent_name = model.parent_name
//        self.width = model.width
//        self.height = model.height
//        self.parent_width = model.parent_width
//        self.parent_height = model.parent_height
//        self.x = model.x
//        self.y = model.y
//        self.path = model.path
//        self.image_path = model.image_path
//        self.type = model.type
//        self.is_last = model.is_last
    }
    
}


class GroupIPModel:Object{
    @objc dynamic var ip_port: String = ""
    @objc dynamic var group_name: String = ""
    override static func primaryKey() -> String?{
        return "ip_port"
    }
}

class HFModel{
        var ID = ""
        var Name = ""
        var groups:[groupModel] = []
        var `Type` = ""
    var isHaveGroup = true
    var heatExchangers:[exchangerModel] = []
        
    init(data:JSON) {
            self.ID = data["ID"].stringValue
            self.Name = data["Name"].stringValue
            self.Type = data["Type"].stringValue
        let haveG = data["IsHaveGroup"].stringValue
        if haveG == "1" {
            self.isHaveGroup = true
        }else{
            self.isHaveGroup = false
        }
        
//        self.isHaveGroup = data["IsHaveGroup"].stringValue
        if self.isHaveGroup {
            let arr = data["Group"].arrayValue
            for gr in arr {
                let gro = groupModel.init(data: gr)
                groups.append(gro)
            }
            
        }else{
            let arr = data["HeatExchangers"].arrayValue
            for gr in arr {
                let gro = exchangerModel.init(data: gr)
                heatExchangers.append(gro)
            }
        }
    }
    
}
class groupModel {
    var ID = ""
    var Name = ""
    var `Type` = ""
    var exchangers:[exchangerModel] = []
    
    init(data:JSON) {
        self.ID = data["GroupID"].stringValue
        self.Name = data["GroupName"].stringValue
        self.Type = data["Type"].stringValue
        for temp in data["HeatExchangers"].arrayValue {
            let exchanger = exchangerModel.init(data: temp)
            exchangers.append(exchanger)
        }
//        self.exchangers = exchangers
    }
}

class exchangerModel{
    var ID = ""
    var DataTime = ""
    var Name = ""
    var State = ""
    var `Type` = ""
    var ItemList:[Item] = []
    
    init(data:JSON) {
        self.ID = data["ID"].stringValue
        self.Name = data["Name"].stringValue
        self.State = data["State"].stringValue
        self.DataTime = data["DataTime"].stringValue
        for temp in data["ItemList"].arrayValue {
            let exchangerItem = Item.init(data: temp)
            ItemList.append(exchangerItem)
        }
        self.Type = data["Type"].stringValue
    }
}

struct Item {
    var TagName = ""
    var TagUnit = ""
    var TagValue = ""
    
    init(data:JSON) {
        TagName = data["TagName"].stringValue
        TagUnit = data["TagUnit"].stringValue
        TagValue = data["TagValue"].stringValue
    }
    
    
    
}


class TreeGroupModel {
    var ID: String?
    var Name: String?
    var List: [TreeGroupModel]?
    var `Type`: String?
    var hfID: String?
    
    
    init(_ id:String, _ name: String, _ list:[TreeGroupModel]?, _ type: String, _ hfid:String?) {
        self.Name = name
        self.List = list
        self.ID = id
        self.Type = type
        self.hfID = hfid
    }
    
}

enum HeatType:Int {
    case heatFactory = 0, group, exchanger
}

//class GroupModel {
//    var ID: Int?
//    var Name: String?
//    var type: HeatType?
//}

class TreeDataModel {
    var model:heatModel?
    var hasChild:Bool?
    var childs:[heatModel]?
    var parent_id:Int?
}

class MappingModel {
    var name = ""
    var type = ""
    var ID = ""
    
    init(_ name: String, _ type: String, ID: String) {
        self.name = name
        self.type = type
        self.ID = ID
    }
}

class LabelModel: NSObject {
    var text = ""
    var value = ""
    var x: Float = 0
    var y: Float = 0
    var width: Float = 0
    var height: Float = 0
    var foreColor: UIColor = UIColor.white
    var dataColor: UIColor = UIColor.white
    var valueTrans = ""
    var station_id = ""
    var tag_id = ""
    var unit = ""
    var format = ""
    var specialunit = ""
    
    
    
    override init() {
        super.init()
    }
    
    
    init(_ text:String, value:String, x:Float,y:Float, width:Float, height:Float,foreColor:UIColor, dataColor: UIColor, valueTrans: String, station: String, tag: String, unit: String, format: String, specialunit: String) {
        self.text = text
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.foreColor = foreColor
        self.dataColor = dataColor
        self.valueTrans = valueTrans
        self.value = value
        self.station_id = station
        self.tag_id = tag
        self.unit = unit
        self.specialunit = specialunit
        self.format = format
    }
    
    
}


class EchartsModel {
    var xArr:[String] = []
    var YaxisList:[Yaxis] = []
    var parmesList:[ParmesList] = []
    
    init(data:JSON) {
        self.xArr = data["Xaxis"].arrayObject as! [String]
        for temp in data["YaxisList"].arrayValue {
            self.YaxisList.append(Yaxis.init(data: temp))
        }
        for temp in data["parmesList"].arrayValue {
            self.parmesList.append(ParmesList.init(data: temp))
        }
    }
    
}

class Yaxis {
    var name:String = ""
    var chartsDataList:[yData] = []
    var unit:String = ""
    init(data:JSON) {
        self.name = data["name"].stringValue
        self.unit = data["unit"].stringValue
        for temp in data["chartsDataList"].arrayValue {
            self.chartsDataList.append(yData.init(data: temp))
        }
    }
}

class yData {
    var name = ""
    var unit = ""
    var data:[String] = []
    
    init(data:JSON) {
        self.name = data["name"].stringValue
        self.unit = data["unit"].stringValue
        for temp in data["data"].arrayValue {
        self.data.append(temp.stringValue)
        }
    }
    
}

class ParmesList {
    var name = ""
    var unit = ""
    var value = ""
    
    init(data:JSON) {
        self.name = data["name"].stringValue
        self.unit = data["unit"].stringValue
            self.value = data["value"].stringValue
    }
    
}




class RealmUtil {
    struct Path {
        static let DATA_DIRECTORY = NSHomeDirectory() + "/Library/IDH"
    }
    struct RealmConfig {
        static let CURRENT_SCHEMA_VERSION: UInt64 = 8
        static let DEFAULT_REALM_NAME = "model.realm"
    }
    
    class func configurRealm() {
        if FileManager.default.fileExists(atPath: Path.DATA_DIRECTORY) {
            
        }else{
            do {
                try FileManager.default.createDirectory(atPath: Path.DATA_DIRECTORY, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                print("create file failed \(error)")
            }
        }
        let location = Path.DATA_DIRECTORY + "/\(RealmConfig.DEFAULT_REALM_NAME)"
        
        let migrationBlock: MigrationBlock = {migration, oldVersion in
            if oldVersion <= 1 {
                
            }
        }
        let config = Realm.Configuration(fileURL: URL(string: location), schemaVersion: RealmConfig.CURRENT_SCHEMA_VERSION, migrationBlock:migrationBlock)
        
        Realm.Configuration.defaultConfiguration = config
        print("\(Path.DATA_DIRECTORY)")
    }
}

