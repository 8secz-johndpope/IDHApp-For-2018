//
//  WorkingViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/25.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Identify {
    static let cell = "Cell"
    static let header = "Header"
}

protocol refreshManager {
    func sendExchangersData(_ arr: [(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])])
}

class WorkingViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate,SWRevealViewControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    var timer: Timer!
    var groupingType = "-1"
    var groupingID = "-1"
    
    var delegate: refreshManager?
    var startUpdate: Int?
    
//    var heatExchangeArr: [(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])] = []
    
    var resultHeatExchangeArr: [(heatFactory: HeatFactoryModel, heatExchangerList:[HeatExchangeModel])] = []
    
    @IBOutlet weak var factoryTable: UITableView!
    @IBOutlet weak var search: UITextField!
    
    @IBAction func searchBtn(_ sender: UIButton) {
        toResult()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(getFactoryGroup), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        self.view.addSubview(activityIndicator)
//        getFactoryGroup()
        //网络加载提示条
        setUpNav()
        self.search.returnKeyType = .done
        self.search.delegate = self
        self.factoryTable.delegate = self
        self.factoryTable.dataSource = self
        self.factoryTable.register(FactoryTableViewCell.self, forCellReuseIdentifier: "facCell")
        self.factoryTable.keyboardDismissMode = .onDrag
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard))
        self.factoryTable.addGestureRecognizer(tap)
        self.factoryTable.reloadData()
        tap.cancelsTouchesInView = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "update"), object: nil)
    }
    
    @objc func updateData(){
        self.factoryTable.reloadData()
        self.getSearchRunningData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "factory-result"), object: self, userInfo: ["datas": self.resultHeatExchangeArr])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeData"), object: self, userInfo: nil)
    }
    
    @objc func hideKeyboard() {
        search.resignFirstResponder()
        factoryTable.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.search.resignFirstResponder()
        return true
    }
    
    func setUpNav() {
        if groupList.count > 0 {
            navigationItem.title = groupList[0].GroupingName
        }else{
            navigationItem.title = "热源厂"
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "quality_ico_home"), style: .plain, target: self, action: #selector(toHomeView))
    }
    
    @objc func getFactoryGroup() {
        Alamofire.request(workingURL, method: .get).responseJSON { reponse in
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                    self.activityIndicator.stopAnimating()
//                    self.heatExchangeArr = []
                    self.resultHeatExchangeArr = []
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
                        
                        let facModel = HeatFactoryModel.init(id: facID, name: facName, flag: facFlag, datatime: facDataTime, tagArr: facTagArr)
                        
                        //换热站
                        let heatExchangeerArrJson = facJson["HeatExchangers"].arrayValue
                        var exchModelArr:[HeatExchangeModel] = []
                        
                        for item in heatExchangeerArrJson{
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
                        }
                    }
                }
                self.factoryTable.reloadData()
            }else{
            }
        }
    }
    
    func getSearchRunningData() {
        let searchStr = search.text!
        if searchStr.isEmpty {
        }else{
            var tempHeatExchangerArr:[(heatFactory:HeatFactoryModel,heatExchangerList: [HeatExchangeModel])] = []
            for temp in heatExchangeArr{
                let facModel = temp.heatFactory
                let excmodel = temp.heatExchangerList
                if facModel.Name.components(separatedBy: searchStr).count > 1{
                    tempHeatExchangerArr.append(temp)
                }else{
                    var tempExchangerModelArr:[HeatExchangeModel] = []
                    for exc in excmodel{
                        if exc.Name.components(separatedBy: searchStr).count>1{
                            tempExchangerModelArr.append(exc)
                        }
                    }
                    if tempExchangerModelArr.count > 0 {
                        tempHeatExchangerArr.append((facModel,tempExchangerModelArr))
                    }
                    
                }
            }
            
            resultHeatExchangeArr = tempHeatExchangerArr
        }
    }
    
    func toResult() {
        if (search.text?.isEmpty)! {
        }else{
        getSearchRunningData()
        let result = resultCollectionViewController()
        result.models = self.resultHeatExchangeArr
        result.fromFactory = true
            let nav = UINavigationController.init(rootViewController: result)
            
        self.present(nav, animated: true, completion: nil)
        }
    }
    
    
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    
    //跳转到首页
    @objc func toHomeView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension WorkingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heatExchangeArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = heatExchangeArr[indexPath.section].heatFactory.tagArr.count
        return CGFloat(ceilf(Float(items/2)) * 20) + 40
    }
    
    //解决分割线不全的问题
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "facCell", for: indexPath) as! FactoryTableViewCell
            
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        cell.factoryModel = heatExchangeArr[indexPath.row].heatFactory
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exchanges = ExchangerCollectionViewController()
        exchanges.datas = heatExchangeArr[indexPath.row]
        exchanges.current = indexPath.row
        self.factoryTable.endEditing(true)
        
        let frontNav = UINavigationController.init(rootViewController: exchanges)
        let menu = MenuViewController()
        let fac = heatExchangeArr[indexPath.row].heatFactory
        menu.fac = fac
        let menuNav = UINavigationController.init(rootViewController: menu)
        
//        let menu = MenuViewController()
        let reveal = SWRevealViewController.init(rearViewController: nil, frontViewController: frontNav)
        reveal?.rightViewController = menuNav
        
        reveal?.rightViewRevealWidth = UIScreen.main.bounds.width/1.5
//        reveal?.rightViewRevealDisplacement = 100
        reveal?.rightViewRevealOverdraw = 0
        reveal?.delegate = self
        
        self.present(reveal!, animated: true, completion: nil)
    }
    
}
