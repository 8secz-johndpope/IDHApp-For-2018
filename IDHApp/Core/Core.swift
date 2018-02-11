//
//  Core.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/21.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

var globalTimer: Timer!
var globalDate: String = ""

var idh_ip_port = ""
var homs_ip_port = ""
var homs_mapping_ip_port = ""
var groupid = ""
var city = ""
var weatherid = ""
var role_id = ""
var currentVersion = ""
var idh_monitor_ip_port = ""


var heatFactoryID = "0"
var heatExchangerID = "0"
var heatFactoryName = ""
var heatExchangerName = ""
var heatExchangerModelArr:[(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])] = []




//AES
let key = "1101121191221200"


let MonitorURL = "http://\(homs_ip_port)/DataCenter/Config/HobConfig.aspx"
let MappingURL = "http://\(homs_mapping_ip_port)/mapping.xml"
let StationURL = "http://\(homs_ip_port)/datacenter/dataservice/RecentData.aspx"
var workingURL = "http://\(idh_ip_port)/Analyze.svc/GetRunningState/\(groupid)/\(role_id)/-1/-1"
let weatherURL = "http://\(idh_ip_port)/Analyze.svc/GetCurrentWeather/\(weatherid)"
var factoryURL = "http://\(idh_ip_port)/Analyze.svc/GetGroupingInfo/\(groupid)/\(role_id)"



var heatExchangeArr: [(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])] = []

var groupList:[GroupingInfo] = []
var grouping: GroupingInfo?

func percentToFloat(_ str: String) -> Float{
    var s = str
    s.removeLast()
    return (s as NSString).floatValue * 0.01
}

//对字符串进行MD5加密
extension String{
    func MD5() ->String!{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        return String(format: hash as String)
    }
    
    func subStr(_ char: String, length: Int) -> String {
        var arr = self.components(separatedBy: char)
        let string = (arr.last! as NSString).substring(to: length)
//        arr.last?.index(, offsetBy: 3)
        arr.removeLast()
        arr.append(string)
        return arr.joined(separator: "")
    }
    
    
    func subStringwith(_ start: Int) -> String {
        let length = self.count - start
        let st = self.index(startIndex, offsetBy: start)
        let end = self.index(st, offsetBy: length)
        return String(self[st..<end])
    }
    
    func uiColor() -> UIColor {
        // 存储转换后的数值
        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
        
        // 分别转换进行转换
        
        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 0, length: 2))).scanHexInt32(&red)
        
        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 2, length: 2))).scanHexInt32(&green)
        
        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 4, length: 2))).scanHexInt32(&blue)
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
}

//通用正则验证方法
struct MyRegex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern,options: NSRegularExpression.Options.caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, input.count))
        {
            return matches.count > 0
        }
        else
        {
            return false
        }
    }
}

extension UIColor{
    //UIColor 16进制 To RGB
    convenience init(hexString:String){
        //处理数值
        var cString = hexString.uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let length = (cString as NSString).length
        //错误处理
        if (length < 6 || length > 7 || (!cString.hasPrefix("#") && length == 7)){
            //返回whiteColor
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            return
        }
        if cString.hasPrefix("#"){
            cString = (cString as NSString).substring(from: 1)
        }
        //字符chuan截取
        var range = NSRange()
        range.location = 0
        range.length = 2
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        //存储转换后的数值
        var r:UInt32 = 0,g:UInt32 = 0,b:UInt32 = 0
        //进行转换
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        //根据颜色值创建UIColor
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
    }
}

extension Results{
    func toArray<T>(of Type: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}
