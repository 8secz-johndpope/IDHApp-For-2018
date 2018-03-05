//
//  DBManager.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/9.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

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

