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
var group_name = ""
var needGroup = false
var needAdvice = false
var fromMonitor = false

var loginOut = false

var factoryMonitor = false


var fromFactory = false
var outsideToTrans = false


var heatFactoryID = "0"
var heatExchangerID = "0"
var heatFactoryName = ""
var heatExchangerName = ""
var heatExchangerModelArr:[(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])] = []

//AES
let key = "1101121191221200"
//APP ID
let appID = ""
let ChecekUpdateURL = "http://182.50.123.37:8080/version/is_updateApp"
let UpdateAPPUrl = "https://itunes.apple.com/cn/app/id1339095288?mt=8"

var groupList:[GroupingInfo] = []
var grouping: GroupingInfo?
var globalGrouping:GroupingInfo?
var heatFactorArr:[HeatFactoryModel] = []
var exchangersArr:[HeatExchangeModel] = []

var model: heatModel?
var models: [HeatExchangeModel] = []
var facModels:[HeatFactoryModel] = []

var current = 0


var groupingType = "-1"
var groupingID = "-1"

var globalType:ConsumeType = .heat
var globalTrendType:TrendEnum = .temperature


//enum API:String {
//    case update = "http://182.50.123.37:8080/version/is_updateApp"
//}
let AuthenticationURL = "http://118.190.146.153:7919/authentication/find"

//https://itunes.apple.com/cn/app/id1277388929?mt=8


var MonitorURL = "http://\(homs_ip_port)/DataCenter/Config/HobConfig.aspx"
var MappingURL = "http://\(homs_mapping_ip_port)/mapping.xml"
var StationURL = "http://\(homs_ip_port)/datacenter/dataservice/RecentData.aspx"
var workingURL = "http://\(idh_ip_port)/Analyze.svc/GetRunningState/\(groupid)/\(role_id)/-1/-1"
var weatherURL = "http://\(idh_ip_port)/Analyze.svc/GetCurrentWeather/\(weatherid)"
var factoryURL = "http://\(idh_ip_port)/Analyze.svc/GetGroupingInfo/\(groupid)/\(role_id)"

//ana
var GroupANA = "http://\(idh_ip_port)/Analyze.svc/GetEnergySum/\(groupid)/\(role_id)/"

var GroupAnaURL = "http://\(idh_ip_port)/Analyze.svc/GetRunningState/\(groupid)/\(role_id)/\(groupingType)/\(groupingID)"
var GroupAnaLineURL = "http://\(idh_ip_port)/Analyze.svc/"

var NewFactorURL = "http://\(idh_ip_port)/Analyze.svc/GetFactoryList"
var NewExchangerURL = "http://\(idh_ip_port)/Analyze.svc/GetRunningDataByHeatFactoryIDAndGroupID"
var NewResultByFactorURL = ""
var NewResultByFAndGroupURL = ""
var NewSideMenuURL = ""

var GroupQualityData = "http://\(idh_ip_port)/Analyze.svc/GetTemperatureSum/\(groupid)/\(role_id)/\(groupingType)/\(groupingID)"
var GroupQuality = "http://\(idh_ip_port)/Analyze.svc/GetTemperatureChart/\(groupid)/\(role_id)/\(groupingType)/\(groupingID)"


//heatFactory
var FactoryHeatQuality = "http://\(idh_ip_port)/Analyze.svc/GetHeatFactoryTemperature/"
var FactorySurvey = "http://\(idh_ip_port)/Analyze.svc/GetHeatFactoryInformation/\(groupid)/"
var FactoryEneryURL = "http://\(idh_ip_port)/Analyze.svc/GetHeatFactory"
var FactoryEneryChart = "http://\(idh_ip_port)/Analyze.svc/GetHeatFactory"
var FactoryTrendURL = "http://\(idh_ip_port)/Analyze.svc/GetHeatFactory"


//heatExchange
var ExchangerEneryURL = "http://\(idh_ip_port)/Analyze.svc/GetHeatExchanger"
var ExchangerEneryChart = "http://\(idh_ip_port)/Analyze.svc/GetHeatExchanger"
var ExchangerTrendURL = "http://\(idh_ip_port)/Analyze.svc/GetHeatExchangerTempTrendByXML/"
var ExchangerSurvey = "http://\(idh_ip_port)/Analyze.svc/GetHeatExchangerInformation/\(groupid)/"
var ExchangerHeatQuality = "http://\(idh_ip_port)/Analyze.svc/GetHeatExchangerTemperature/"
//alarm
var AlarmURL = "http://\(idh_ip_port)/GetAlarmInformation/\(role_id)"
//
var TransFerURL = "http://\(idh_ip_port)/Analyze.svc/GetNavigation/\(groupid)/\(role_id)"

var heatExchangeArr: [(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])] = []


func percentToFloat(_ str: String) -> Float{
    var s = str
    s.removeLast()
    return (s as NSString).floatValue * 0.01
}

var globalWidth = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width

var globalHeight = UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width



public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod1,1":  return "iPod Touch 1"
        case "iPod2,1":  return "iPod Touch 2"
        case "iPod3,1":  return "iPod Touch 3"
        case "iPod4,1":  return "iPod Touch 4"
        case "iPod5,1":  return "iPod Touch (5 Gen)"
        case "iPod7,1":   return "iPod Touch 6"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":  return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"
        case "iPhone5,1":   return "iPhone 5"
        case  "iPhone5,2":  return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3":  return "iPhone 5c (GSM)"
        case "iPhone5,4":  return "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1":  return "iPhone 5s (GSM)"
        case "iPhone6,2":  return "iPhone 5s (GSM+CDMA)"
        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"
        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1":   return "国行、日版、港行iPhone 7"
        case "iPhone9,2":  return "港行、国行iPhone 7 Plus"
        case "iPhone9,3":  return "美版、台版iPhone 7"
        case "iPhone9,4":  return "美版、台版iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":   return "iPhone X"
        case "iPad1,1":   return "iPad"
        case "iPad1,2":   return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":   return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":   return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":   return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":  return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":   return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1","AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":   return "Apple TV 4"
        case "i386", "x86_64":   return "Simulator"
        default:  return identifier
        }
    }
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
        print("----------------\(String(format: hash as String))")
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
    
//    func uiColor() -> UIColor {
//        // 存储转换后的数值
//        var red:UInt32 = 0, green:UInt32 = 0, blue:UInt32 = 0
//
//        // 分别转换进行转换
//        
//        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 0, length: 2))).scanHexInt32(&red)
//
//        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 2, length: 2))).scanHexInt32(&green)
//
//        Scanner(string: (self as NSString).substring(with: NSRange.init(location: 4, length: 2))).scanHexInt32(&blue)
//
//        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
//    }
    
    
    func getLength(lengtn:Int) -> String{
        return String.init(format: "%.\(lengtn)f", (self as NSString).doubleValue)
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

//extension UIColor{
//    //UIColor 16进制 To RGB
//    convenience init(hexString:String){
//        //处理数值
//        var cString = hexString.uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        let length = (cString as NSString).length
//        //错误处理
//        if (length < 6 || length > 7 || (!cString.hasPrefix("#") && length == 7)){
//            //返回whiteColor
//            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//            return
//        }
//        if cString.hasPrefix("#"){
//            cString = (cString as NSString).substring(from: 1)
//        }
//        //字符chuan截取
//        var range = NSRange()
//        range.location = 0
//        range.length = 2
//        let rString = (cString as NSString).substring(with: range)
//        range.location = 2
//        let gString = (cString as NSString).substring(with: range)
//        range.location = 4
//        let bString = (cString as NSString).substring(with: range)
//        //存储转换后的数值
//        var r:UInt32 = 0,g:UInt32 = 0,b:UInt32 = 0
//        //进行转换
//        Scanner(string: rString).scanHexInt32(&r)
//        Scanner(string: gString).scanHexInt32(&g)
//        Scanner(string: bString).scanHexInt32(&b)
//        //根据颜色值创建UIColor
//        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
//    }
//}

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
