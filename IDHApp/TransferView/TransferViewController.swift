//
//  TransferViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/24.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


enum globalVC {
    case energyTypeIndex
    case heatingQuality
    
    case heatFactoryMonitor
    case heatFactoryEnergy
    case heatFactoryTrend
    case heatFactorySurvey
    case heatFactoryQuality
    
    case heatExchangerMonitor
    case heatExchangerEnergy
    case heatExchangerTrend
    case heatExchangerSurvey
    case heatExchangerQuality
}

var globalFromVC:globalVC = .energyTypeIndex


class TransferViewController: UIViewController,UITextFieldDelegate {
    
//    static let instance = TransferViewController()
    
    static func newInstance() -> UIViewController{
        let root = UIStoryboard(name: "Transfer", bundle: nil)
//        if let vc = root.instantiateInitialViewController() {
//            return vc as? TransferViewController
//        }
//        return nil
        let trans = root.instantiateViewController(withIdentifier: "transfer")
        return trans
    }
    
    @IBOutlet weak var SearchTxt: UITextField!
    
    @IBAction func Search(_ sender: UIButton) {
        if let txt = SearchTxt.text, !txt.isEmpty{
            var tempHeatexchangers:[(factory:HeatFactoryModel,exchangers:[HeatExchangeModel])] = []
            for item in datas{
                let fac = item.factory
                let list = item.exchangers
                
                if fac.Name.contains(txt){
                    tempHeatexchangers.append(item)
                }else{
                    var tempArr:[HeatExchangeModel] = []
                    
                    for exc in list{
                        if exc.Name.contains(txt){
                            tempArr.append(exc)
                        }
                    }
                    if !tempArr.isEmpty{
                        tempHeatexchangers.append((fac,tempArr))
                    }
                }
            }
            resultDatas = tempHeatexchangers
        }else{
            resultDatas = datas
        }
        self.exchangerTable.reloadData()
    }
    
    @IBOutlet weak var exchangerTable: UITableView!
    
    var datas:[(factory:HeatFactoryModel,exchangers:[HeatExchangeModel])] = []
    
    var resultDatas:[(factory:HeatFactoryModel,exchangers:[HeatExchangeModel])] = []
    
    var closeArr:[Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "快速跳转"
        self.exchangerTable.delegate = self
        self.exchangerTable.dataSource = self
        
        self.exchangerTable.tableFooterView = UIView()
        self.SearchTxt.returnKeyType = .done
        self.exchangerTable.keyboardDismissMode = .onDrag
        
        self.SearchTxt.delegate = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "quality_ico_home"), style: .plain, target: self, action: #selector(toHome))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "transBack"), style: .plain, target: self, action: #selector(toPreview))
        // Do any additional setup after loading the view.
        self.getDatas()
        //解决分割线不全的问题
        if exchangerTable.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            exchangerTable.separatorInset = UIEdgeInsets.zero
        }
        if exchangerTable.responds(to: #selector(setter: UIView.layoutMargins)){
            exchangerTable.layoutMargins = UIEdgeInsets.zero
        }
        
//        let str = "[{\"HeatExchangers\":[{\"ID\":\"1003\",\"Name\":\"星河湾一期\"}],\"ID\":\"1\",\"Name\":\"秦元热力公司\"},{\"HeatExchangers\":[{\"ID\":\"13\",\"Name\":\"消防站\"},{\"ID\":\"1\",\"Name\":\"电厂西门（2号井）\"},{\"ID\":\"2\",\"Name\":\"7号阀门井\"},{\"ID\":\"3\",\"Name\":\"12号阀门井\"},{\"ID\":\"4\",\"Name\":\"光电科技计量井\"},{\"ID\":\"5\",\"Name\":\"明光路计量井\"},{\"ID\":\"6\",\"Name\":\"15号支线表（城北）\"},{\"ID\":\"7\",\"Name\":\"瑞行表计\"}],\"ID\":\"2\",\"Name\":\"热水一号线\"},{\"HeatExchangers\":[{\"ID\":\"10\",\"Name\":\"天宏计量（蒸汽表）\"},{\"ID\":\"11\",\"Name\":\"光电科技（蒸汽表）\"},{\"ID\":\"12\",\"Name\":\"蓝池宇洁（蒸汽表）\"}],\"ID\":\"1002\",\"Name\":\"蒸汽管线\"}]"
//        let data = str.data(using: .utf8)
//
//        let testJson = JSON(data)
//        var i = 0
//        for (_,facJson) in testJson{
//            var excModelArr: [HeatExchangeModel] = []
//            let fac = HeatFactoryModel.init(id: facJson["ID"].stringValue, name: facJson["Name"].stringValue)
//            let exs = facJson["HeatExchangers"].arrayValue
//            for temp in exs{
//                let excmodel = HeatExchangeModel.init(id: temp["ID"].stringValue, name: temp["Name"].stringValue)
//                excModelArr.append(excmodel)
//            }
//            self.datas.append((fac,excModelArr))
//
//
//
//            if globalFromVC == .energyTypeIndex || globalFromVC == .heatFactoryEnergy {
//                if globalType == .gas || globalType == .coal{
//                    self.closeArr.append(true)
//                }else{
//                    if i==0{
//                        self.closeArr.append(false)
//                    }
//                    else{
//                        self.closeArr.append(true)
//                    }
//                    i += 1
//                }
//            }else{
//                if i==0{
//                    self.closeArr.append(false)
//                }
//                else{
//                    self.closeArr.append(true)
//                }
//                i += 1
//            }
//        }
//        print("\(datas)")
//        self.resultDatas = self.datas
//        self.exchangerTable.reloadData()
    }
    
    @objc func toPreview() {
        if outsideToTrans {
                    self.dismiss(animated: true, completion: nil)
            outsideToTrans = false
        }else{
        self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func toHome() {
        let home = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = home.instantiateViewController(withIdentifier: "home")
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func getDatas() {
        let url = "http://219.145.102.165:6099/Analyze.svc/GetNavigation/1/1"
        
        //[{"HeatExchangers":[{"ID":"1003","Name":"星河湾一期"}],"ID":"1","Name":"秦元热力公司"},{"HeatExchangers":[{"ID":"13","Name":"消防站"},{"ID":"1","Name":"电厂西门（2号井）"},{"ID":"2","Name":"7号阀门井"},{"ID":"3","Name":"12号阀门井"},{"ID":"4","Name":"光电科技计量井"},{"ID":"5","Name":"明光路计量井"},{"ID":"6","Name":"15号支线表（城北）"},{"ID":"7","Name":"瑞行表计"},{"ID":"8","Name":"15号阀门井"},{"ID":"9","Name":"16号阀门井"}],"ID":"2","Name":"热水一号线"},{"HeatExchangers":[{"ID":"10","Name":"天宏计量（蒸汽表）"},{"ID":"11","Name":"光电科技（蒸汽表）"},{"ID":"12","Name":"蓝池宇洁（蒸汽表）"}],"ID":"1002","Name":"蒸汽管线"}]
        let str = "[{\"HeatExchangers\":[{\"ID\":\"1003\",\"Name\":\"星河湾一期\"}],\"ID\":\"1\",\"Name\":\"秦元热力公司\"},{\"HeatExchangers\":[{\"ID\":\"13\",\"Name\":\"消防站\"},{\"ID\":\"1\",\"Name\":\"电厂西门（2号井）\"},{\"ID\":\"2\",\"Name\":\"7号阀门井\"},{\"ID\":\"3\",\"Name\":\"12号阀门井\"},{\"ID\":\"4\",\"Name\":\"光电科技计量井\"},{\"ID\":\"5\",\"Name\":\"明光路计量井\"},{\"ID\":\"6\",\"Name\":\"15号支线表（城北）\"},{\"ID\":\"7\",\"Name\":\"瑞行表计\"},{\"HeatExchangers\":[{\"ID\":\"10\",\"Name\":\"天宏计量（蒸汽表）\"},{\"ID\":\"11\",\"Name\":\"光电科技（蒸汽表）\"},{\"ID\":\"12\",\"Name\":\"蓝池宇洁（蒸汽表）\"}],\"ID\":\"1002\",\"Name\":\"蒸汽管线\"}]"
        let data = str.data(using: .utf8)
        
        let testJson = JSON(data)
        
        Alamofire.request(TransFerURL).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                let data = reponse.result.value
                let json = JSON(data as Any)
                var i = 0
                
                for (_,facJson) in json{
                    var excModelArr: [HeatExchangeModel] = []
                    let fac = HeatFactoryModel.init(id: facJson["ID"].stringValue, name: facJson["Name"].stringValue)
                    let exs = facJson["HeatExchangers"].arrayValue
                    for temp in exs{
                        let excmodel = HeatExchangeModel.init(id: temp["ID"].stringValue, name: temp["Name"].stringValue)
                        excModelArr.append(excmodel)
                    }
                    self.datas.append((fac,excModelArr))
                    

                    if globalFromVC == .energyTypeIndex || globalFromVC == .heatFactoryEnergy {
                        if globalType == .gas || globalType == .coal{
                            self.closeArr.append(true)
                        }else{
                            if i==0{
                                self.closeArr.append(false)
                            }
                            else{
                                self.closeArr.append(true)
                            }
                            i += 1
                        }
                    }else{
                        if i==0{
                            self.closeArr.append(false)
                        }
                        else{
                            self.closeArr.append(true)
                        }
                        i += 1
                    }

                }
                self.resultDatas = self.datas
                self.exchangerTable.reloadData()
            }else{
                print(reponse.error ?? "")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.SearchTxt.resignFirstResponder()
        return true
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

extension TransferViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //闭合
        if closeArr[section]{
            return 0
        }
        else{
            return resultDatas[section].exchangers.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width-8,height: 50))
        myView.backgroundColor = UIColor(red: 0/255.0, green: 178/255.0, blue: 178/255.0, alpha: CGFloat(1.0))
        let facModel = resultDatas[section].factory
        //展开折叠按钮
        let myButton = UIButton(frame: CGRect(x: 15,y: 15,width: 14,height: 14))
        myButton.tag = section
        //闭合
        if closeArr[section]{
            myButton.setImage(UIImage(named: "jump_icon_close"), for: UIControlState())
        }
        else{
            myButton.setImage(UIImage(named: "jump_icon_open"), for: UIControlState())
        }
        myButton.addTarget(self, action: #selector(openAndCloseByButton(_:)), for: .touchUpInside)
        //名称
        let myLabel = UILabel(frame: CGRect(x: 40,y: 7,width: 240,height: 30))
        myLabel.tag = section
        myLabel.text = facModel.Name
        myLabel.textColor = UIColor.white
        
        //给标题添加点击手势
        let myTapGesture = UITapGestureRecognizer(target: self, action: #selector(openAndCloseByLabel(_:)))
        myLabel.addGestureRecognizer(myTapGesture)
        let transferButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width-40, y: 16, width: 20, height: 20))
        transferButton.setImage(UIImage(named: "close"), for: UIControlState())
        transferButton.tag = section
        transferButton.addTarget(self, action: #selector(toFactory(_:)), for: .touchUpInside)
        
        //if from exchanger and type is valvegiven do not show the button
        if globalFromVC == .heatExchangerTrend && globalTrendType == .ValveGiven {
            transferButton.isHidden = true
        }else{
            transferButton.isHidden = false
        }
        
        if globalFromVC == .energyTypeIndex || globalFromVC == .heatFactoryEnergy {
            if globalType == .gas || globalType == .coal{
                myButton.isEnabled = false
                myLabel.isUserInteractionEnabled = false
            }else{
                myButton.isEnabled = true
                myLabel.isUserInteractionEnabled = true
            }
        }else{
            myButton.isEnabled = true
            //设置Label可被点击
            myLabel.isUserInteractionEnabled = true
        }
        
        //跳转按钮
        myView.addSubview(myButton)
        myView.addSubview(myLabel)
        myView.addSubview(transferButton)
        
        return myView
    }
    
    @objc func toFactory(_ sender:UIButton){
        let facModel = resultDatas[sender.tag].factory
        heatFactoryID = facModel.ID
        heatFactoryName = facModel.Name
        let factorTabBar = HeatFactoryTabBarControllerViewController()
//        let factorTabBar = UIStoryboard(name: "TabbarStoryboard", bundle: nil).instantiateViewController(withIdentifier: "facbar") as! UITabBarController
        switch globalFromVC {
        case .energyTypeIndex, .heatExchangerEnergy, .heatFactoryEnergy:
            factorTabBar.selectedIndex = 2
        case .heatFactoryMonitor, .heatExchangerMonitor:
            factorTabBar.selectedIndex = 0
        case .heatFactoryTrend, .heatExchangerTrend:
            factorTabBar.selectedIndex = 1
        case .heatFactorySurvey, .heatExchangerSurvey:
            factorTabBar.selectedIndex = 3
        case .heatFactoryQuality, .heatExchangerQuality, .heatingQuality:
            factorTabBar.selectedIndex = 4
        }
//        let nav = UINavigationController.init(rootViewController: factorTabBar)
//        self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(factorTabBar, animated: true)
    }
    
    func toExchanger() {
//        let exchangerTabBar = UIStoryboard(name: "ExchangerTabBar", bundle: nil).instantiateViewController(withIdentifier: "exchanger") as! UITabBarController
        let exchangerTabBar = HeatExchangerTabBarController.instance
        
//        let exchangerTabBar = HeatExchangerTabBarController()
        
        switch globalFromVC {
        case .energyTypeIndex, .heatExchangerEnergy, .heatFactoryEnergy:
            exchangerTabBar.selectedIndex = 2
        case .heatFactoryMonitor, .heatExchangerMonitor:
            exchangerTabBar.selectedIndex = 0
        case .heatFactoryTrend, .heatExchangerTrend:
            exchangerTabBar.selectedIndex = 1
        case .heatFactorySurvey, .heatExchangerSurvey:
            exchangerTabBar.selectedIndex = 3
        case .heatFactoryQuality, .heatExchangerQuality, .heatingQuality:
            exchangerTabBar.selectedIndex = 4
        }
        let nav = UINavigationController.init(rootViewController: exchangerTabBar)
        self.navigationController?.pushViewController(exchangerTabBar, animated: true)
//        self.present(nav, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(exchangerTabBar, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transferCell", for: indexPath)
        cell.textLabel?.text = resultDatas[indexPath.section].exchangers[indexPath.row].Name
        cell.textLabel?.textColor = UIColor(red: 169/255.0, green: 169/255.0, blue: 169/255.0, alpha: CGFloat(1.0))
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let excModel = resultDatas[indexPath.section].exchangers[indexPath.row]
        heatExchangerID = excModel.ID
        heatExchangerName = excModel.Name
        toExchanger()
    }
    
    //展开折叠事件(Button)
    @objc func openAndCloseByButton(_ sender:UIButton) {
        let section = sender.tag
        closeArr[section] = !closeArr[section]
        self.exchangerTable.reloadSections(IndexSet(integer: section), with: .none)
    }
    
    //展开折叠事件(Label)
    @objc func openAndCloseByLabel(_ sender:UITapGestureRecognizer) {
        let section = (sender.view as! UILabel).tag
        closeArr[section] = !closeArr[section]
        self.exchangerTable.reloadSections(IndexSet(integer: section), with: .none)
    }
    
    
}
