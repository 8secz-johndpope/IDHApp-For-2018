//
//  HomeViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/22.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON
import RealmSwift
import AVFoundation

class HomeViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureWeature: UILabel!
    @IBOutlet weak var windDirection: UILabel!
    @IBOutlet weak var windPower: UILabel!
    @IBOutlet weak var weatureImage: UIImageView!
    @IBOutlet var myCity: UILabel!
    
    @IBOutlet weak var factory: UIView!

    @IBOutlet weak var EneryAnalyse: UIView!
    
    @IBOutlet weak var alarmManagment: UIView!
    @IBOutlet weak var heatQuality: UIView!
    var timer: Timer!
    var dataTimer: Timer!
    
    @IBAction func clearImageCache(_ sender: UIButton) {
        //clean picture memory
            let cache = KingfisherManager.shared.cache
            cache.cleanExpiredDiskCache()
            cache.clearMemoryCache()
            cache.clearDiskCache(completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInfo()
        setUpcityInfo()
        getWeatherInfo()
        setUpViews()
        if needGroup {
        }else{
            getFactoryGroup()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .compact)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    func setUpcityInfo() {
        myCity.text = city
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(getWeatherInfo), userInfo: nil, repeats: true)
        if needGroup {
        }else{
            dataTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(getFactoryGroup), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if timer != nil{
            timer.invalidate()
        }
        if dataTimer != nil{
            dataTimer.invalidate()
        }
    }
    
    func setUpViews() {
        //给四个视图块添加单击手势功能
        let energyGesture = UITapGestureRecognizer(target: self, action: #selector(handleEnergyGesture(_:)))
        let factorGesture = UITapGestureRecognizer(target: self, action: #selector(handleFactorGesture(_:)))
        let qualityGesture = UITapGestureRecognizer(target: self, action: #selector(handleQualityGesture(_:)))
        let alarmGesture = UITapGestureRecognizer(target: self, action: #selector(handleAlarmGesture(_:)))
        
        EneryAnalyse.addGestureRecognizer(energyGesture)
        factory.addGestureRecognizer(factorGesture)
        heatQuality.addGestureRecognizer(qualityGesture)
        alarmManagment.addGestureRecognizer(alarmGesture)
    }
    
    //设置四个视图块单击手势执行的方法
    @objc func handleEnergyGesture(_ sender:UITapGestureRecognizer)
    {
        setViewAnimation(EneryAnalyse,currentViewControllerIndex:1)
    }
    
    @objc func handleFactorGesture(_ sender:UITapGestureRecognizer)
    {
        setViewAnimation(factory,currentViewControllerIndex:0)
    }
    
    @objc func handleQualityGesture(_ sender:UITapGestureRecognizer)
    {
        setViewAnimation(heatQuality,currentViewControllerIndex:2)
    }

    @objc func handleAlarmGesture(_ sender:UITapGestureRecognizer)
    {
        setViewAnimation(alarmManagment,currentViewControllerIndex:3)
    }
    
    //设置UIView的动画效果
    func setViewAnimation(_ myView:UIView,currentViewControllerIndex:Int)
    {
        //默认是昨天
        let currentDate = Date()
        let yesterdayDate = Date(timeIntervalSince1970: currentDate.timeIntervalSince1970-60*60*24)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        globalDate = dateFormatter.string(from: yesterdayDate)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            UIView.setAnimationTransition(.flipFromLeft, for: myView, cache: false)
            UIView.setAnimationRepeatCount(2)
        }) { (finished: Bool) in
            
            if finished{
                
                let rootTabBarController = RootTabBarController()
                rootTabBarController.selectedIndex = currentViewControllerIndex
                
                //
//                let story = UIStoryboard.init(name: "Storyboard", bundle: nil)
//                let factor = story.instantiateViewController(withIdentifier: "mainNav")
                self.present(rootTabBarController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func getFactoryGroup() {
         Alamofire.request(workingURL, method: .get).responseJSON { reponse in
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                    heatFactorArr = []
                    exchangersArr = []
                    heatExchangeArr = []
                    let json = JSON(value)
                    for (_,facJson) in json{
                        let facID = facJson["ID"].stringValue
                        let facName = facJson["Name"].stringValue
                        let facFlag = facJson["Flag"].stringValue
                        let facDataTime = facJson["DataTime"].stringValue
                        let facItems = facJson["ItemList"].arrayValue
                        var facTagArr:[[String: String]] = []
                        for tagItem in facItems{
                            let facTagName = tagItem["TagName"].stringValue
                            let facTagUnit = tagItem["TagUnit"].stringValue
                            let factagValue = tagItem["TagValue"].stringValue
                            facTagArr.append(["TagName": facTagName, "TagUnit": facTagUnit, "TagValue": factagValue])
                        }
                        let facModel = HeatFactoryModel.init(id: facID, name: facName, flag: facFlag, datatime: facDataTime, type: "", offline: "", online: "", tagArr: facTagArr)
                    heatFactorArr.append(facModel)
                        
                        //换热站
                        let heatExchangeerArrJson = facJson["HeatExchangers"].arrayValue
                        var exchModelArr:[HeatExchangeModel] = []
                        
                        for item in heatExchangeerArrJson{
                            if !item.isEmpty{
                            let id = item["ID"].stringValue
                            let name = item["Name"].stringValue
                            let flag = item["Flag"].stringValue
                            let datatime = item["DataTime"].stringValue
                            let itemList = item["ItemList"].arrayValue
                            var tagArr: [[String: String]] = []
                            
                            for tagItem in itemList{
                                let tagName = tagItem["TagName"].stringValue
                                let tagUnit = tagItem["TagUnit"].stringValue
                                let tagValue = tagItem["TagValue"].stringValue
                                tagArr.append(["TagName":tagName, "TagUnit": tagUnit, "TagValue": tagValue])
                            }
                            let exchangerModel = HeatExchangeModel(id: id, name: name, flag: flag, datatime: datatime, tagArr: tagArr)
                            exchModelArr.append(exchangerModel)
                            exchangersArr.append(exchangerModel)
                            }
                        }
                        heatExchangeArr.append((facModel, exchModelArr))
                    }
                    self.setFAndE()
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: self, userInfo: nil)
            }else{
                print("get factory data error")
            }
        }
    }
    
    func setFAndE() {
        print(heatFactorArr)
        print(exchangersArr)
        if heatFactoryID.isEmpty {
            heatFactoryID = (heatFactorArr.first?.ID)!
            heatFactoryName = (heatFactorArr.first?.Name)!
        }
        if heatExchangerID.isEmpty {
            heatExchangerID = (exchangersArr.first?.ID)!
            heatExchangerName = (exchangersArr.first?.Name)!
        }
    }
    
    func getInfo() {
        print(idh_ip_port)
        print(factoryURL)
        groupList = []
            Alamofire.request(factoryURL, method: .get).responseJSON(completionHandler: { reponse in
                if reponse.result.isSuccess{
                    let myResult = reponse.result.value as? NSArray
                    if let myResult = myResult{
                        for item in myResult{
                                let groupInfo = GroupingInfo.init(dic: item as! NSDictionary)
                                groupList.append(groupInfo)
                            if groupInfo.GroupingType == "group"{
                                globalGrouping = groupInfo
                                grouping = groupInfo
//                                groupingType = (grouping?.GroupingType)!
                                groupingID = (grouping?.GroupingID)!
                            }
                            print("\(groupInfo.GroupingName)----\(groupInfo.GroupingID)---\(groupInfo.GroupingType)")
                        }
                    }
                }else{
                    print("\(reponse.error)")
                }
            })
    }
    
    @objc func getWeatherInfo() {
        
        Alamofire.request(weatherURL, method: .get).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                let result = reponse.result.value as? NSDictionary
                if let weatherResult = result{
                    
                    let str = weatherResult["Temp"] as! String
                    if str.isEmpty{
                    }else{
                        let num = Float(str)
                        self.temperatureLabel.text = String.init(format: "%.1f", num!)
                    }
                    
                    
                    let weather = weatherResult["Weather"] as? String
                    if !(weather?.isEmpty)!{
                        
                        self.temperatureWeature.text = weather
                        self.weatureImage.image = self.getWeatherImage(weather)
                    }
                    let windP = weatherResult["Winds"] as? String
                    let windD = weatherResult["Windd"] as? String
                    if !(windD?.isEmpty)!{
                        self.windDirection.text = windD
                    }
                    if !(windP?.isEmpty)!{
                        self.windPower.text = windP
                    }
                
                }
            }else{
                Toast.shareInstance().showView(self.view, title: "获取天气信息失败")
                Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                print("\(reponse.error ?? "default" as! Error)")
            }
        }
    }
    
    
    //find Weathger Image
    func getWeatherImage(_ weather:String?) -> UIImage?{
        var result = "Fine.png"
        
        if let str = weather
        {
            switch str
            {
            case str where str.components(separatedBy: "阴").count>1 || str.components(separatedBy: "阴天").count>1:
                result = "Overcast.png"
            case str where str.components(separatedBy: "阴").count>1 && str.components(separatedBy: "晴").count>1:
                result = "Sun.png"
            case str where str.components(separatedBy: "多云").count>1:
                result = "CloudyDay.png"
            case str where str.components(separatedBy: "晴天").count>1 || str.components(separatedBy: "晴").count>1:
                result = "Fine.png"
            case str where str.components(separatedBy: "浮尘").count>1 || str.components(separatedBy: "尘").count>1:
                result = "FloatingDust.png"
            case str where str.components(separatedBy: "雷阵雨伴有冰雹").count>1 || str.components(separatedBy: "雷").count>1 || str.components(separatedBy: "冰").count>1:
                result = "ThunderstormsWithHail.png"
            case str where str.components(separatedBy: "晴转阴").count>1 || str.components(separatedBy: "阴转晴").count>1 ||
                str.components(separatedBy: "晴转多云").count>1 || str.components(separatedBy: "多云转晴").count>1:
                result = "Cloudy.png"
            case str where str.components(separatedBy: "强沙尘暴").count>1:
                result = "StrongSandstorm.png"
            case str where str.components(separatedBy: "沙尘暴").count>1:
                result = "DustStorm.png"
            case str where str.components(separatedBy: "雾").count>1:
                result = "Fog.png"
            case str where str.components(separatedBy: "霾").count>1:
                result = "Haze.png"
            case str where str.components(separatedBy: "雷阵雨").count>1:
                result = "Thundershower.png"
            case str where str.components(separatedBy: "雷").count>1 && str.components(separatedBy: "暴").count>1:
                result = "Thunderstorms.png"
            case str where str.components(separatedBy: "沙").count>1 || str.components(separatedBy: "风").count>1:
                result = "BlowingSand.png"
            case str where str.components(separatedBy: "细").count>1 || str.components(separatedBy: "毛").count>1:
                result = "Drizzle.png"
            case str where str.components(separatedBy: "小").count>1 && str.components(separatedBy: "中").count>1 &&
                str.components(separatedBy: "雨").count>1:
                result = "LightMiddleRain.png"
            case str where str.components(separatedBy: "小雨").count>1:
                result = "LightRain.png"
            case str where str.components(separatedBy: "中雨").count>1:
                result = "Rain.png"
            case str where str.components(separatedBy: "阵雨").count>1:
                result = "Shower.png"
            case str where str.components(separatedBy: "大雨").count>1:
                result = "HeavyRain.png"
            case str where str.components(separatedBy: "特大").count>1 || str.components(separatedBy: "倾盆").count>1:
                result = "SevereRainstorm.png"
            case str where str.components(separatedBy: "暴雨").count>1 || str.components(separatedBy: "大暴雨").count>1:
                result = "Rainstorm.png"
            case str where str.components(separatedBy: "冰").count>1:
                result = "IceRain.png"
            case str where str.components(separatedBy: "雨夹雪").count>1 || str.components(separatedBy: "雹").count>1:
                result = "Sleet.png"
            case str where str.components(separatedBy: "小").count>1 && str.components(separatedBy: "中").count>1 &&
                str.components(separatedBy: "雪").count>1:
                result = "LightMiddleSnow.png"
            case str where str.components(separatedBy: "小雪").count>1:
                result = "LightSnow.png"
            case str where str.components(separatedBy: "中雪").count>1:
                result = "Snow.png"
            case str where str.components(separatedBy: "大雪").count>1:
                result = "HeavySnow.png"
            case str where str.components(separatedBy: "暴雪").count>1 && str.components(separatedBy: "大").count>1:
                result = "Blizzard.png"
            case str where str.components(separatedBy: "暴雪").count>1:
                result = "SnowBlizzard.png"
            default:
                result = ""
            }
        }
        
        return UIImage(named: result)
    }

    @IBAction func LoginOut(_ sender: UIButton) {
        if globalTimer != nil {
            globalTimer.invalidate()
        }
//        let realm = try! Realm()
//        try! realm.write {
//            realm.deleteAll()
//        }
        let login = UIStoryboard.init(name: "Login", bundle: nil)
        let logonVC = login.instantiateViewController(withIdentifier: "login")
        
        self.present(logonVC, animated: true) {
            Defaults.instance.removeValue(key: "userInfo")
            UserDefaults.standard.removeObject(forKey: "roleID")
            loginOut = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("home")
        // Dispose of any resources that can be recreated.
    }
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
