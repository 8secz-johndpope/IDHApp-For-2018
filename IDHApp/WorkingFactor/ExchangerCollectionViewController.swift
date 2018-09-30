//
//  ExchangerCollectionViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/29.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import KissXML
import SwiftyJSON
import MMDrawerController

private let reuseIdentifier = "Cell"


class ExchangerCollectionViewController: UICollectionViewController{
    
    var datas:(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])?
    var result:[(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])] = []
    
    var searchTxt = UITextField()
    var realm: Realm?
    
    var rightSlideMenu: UIViewController!
    
    var refreshTimer:Timer?
    
    var thisCurrent: Int = 0
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    //
    var factor:HFModel?
    var group:groupModel?
    var isFactor:Bool = true
    
    //
    var hfid:String?
    var groupid:String?
    
    var searchBtn: UIButton?
    var bgView:UIView?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate.landscape = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if needGroup {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if needGroup {
            ToastView.instance.showLoadingDlg()
            getData()
        }
        if #available(iOS 11.0, *) {
            self.collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let reveal = self.revealViewController()
        reveal?.panGestureRecognizer()
        reveal?.tapGestureRecognizer()
        if needGroup {
            let menu = reveal?.rightViewController as! MenuViewController
            menu.updateFromMenu = {[unowned self](isFactor,hfid,groupid) in
                self.isFactor = isFactor
                if isFactor {
                    self.bgView?.isHidden = false
                    self.collectionView?.frame = CGRect.init(x: 0, y: 108, width: self.view.bounds.width, height: self.view.bounds.height - 108)
                    self.hfid = hfid
                }else{
                    self.bgView?.isHidden = true
                    self.collectionView?.frame = CGRect.init(x: 0, y: 108-44, width: self.view.bounds.width, height: self.view.bounds.height - 108+44)
                    self.groupid = groupid
                    self.hfid = hfid
                }
                ToastView.instance.showLoadingDlg()
                self.getData()
            }
        }
        
        initCollectionView()
        initSearch()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = datas?.heatFactory.Name
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu"), style: .done, target: reveal, action: #selector(reveal?.rightRevealToggle(_:)))
        if !needGroup {
                    NotificationCenter.default.addObserver(self, selector: #selector(sendData(_:)), name: NSNotification.Name(rawValue: "changeData"), object: nil)
            
                    NotificationCenter.default.addObserver(self, selector: #selector(changeFactor(_:)), name: NSNotification.Name(rawValue: "changeFactory"), object: nil)
        }else{
            
            createTimer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.setNeedsLayout()
        self.collectionView?.setNeedsDisplay()
    }
    
    @objc func getData() {
        var url = ""
        if !isFactor {
            url = "http://124.114.131.38:6099/Analyze.svc/GetRunningDataByHeatFactoryIDAndGroupID/\(self.hfid!)/\(self.groupid!)"
        }else{
            url = "http://124.114.131.38:6099/Analyze.svc/GetRunningDataByHeatFactoryID/\(self.hfid!)"
        }
        print("huanrezhan--------\(url)")
        Alamofire.request(url, method: .get).responseJSON { (reponse) in
            ToastView.instance.hide()
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                let data = JSON(value)
                    self.factor = HFModel.init(data: data)
                    if !self.isFactor {
//                        self.group = groupModel.init(data: data)
                        self.title = self.factor?.groups.first?.Name
                    }else{
                        self.title = self.factor?.Name
                    }
                    self.collectionView?.reloadData()
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Mid)
                print("error")
            }
        }
    }
    
    func createTimer() {
        if let _ = self.refreshTimer{
            return
        }
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(getData), userInfo: nil, repeats: true)
        RunLoop.main.add(self.refreshTimer!, forMode: .commonModes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.refreshTimer?.invalidate()
    }
    
    @objc func changeFactor(_ sender: Notification) {
        
        let info = sender.userInfo as! [String: GroupingInfo]
        let factory = info["datas"]
        if datas?.heatFactory.ID == factory?.GroupingID {
        }else{
            for index in 0..<heatExchangeArr.count {
                if heatExchangeArr[index].heatFactory.ID == factory?.GroupingID{
                    thisCurrent = index
                    self.datas = heatExchangeArr[index]
                    self.navigationItem.title = datas?.heatFactory.Name
                    self.collectionView?.reloadData()
                }
            }
        }
        
//        let info = sender.userInfo as! [String: String]
//        var url = ""
//        if let hf = info["hfid"]{
//            //厂+分区
//            url = "http://124.114.131.38:6099/Analyze.svc/GetRunningDataByHeatFactoryIDAndGroupID/\(hf)/\(info["ID"]))"
//        }else{
//            //厂
//            url = "http://124.114.131.38:6099/Analyze.svc/GetRunningDataByHeatFactoryID/\(info["ID"] ?? "")"
//        }
        
//        getData(url)
//        if datas?.heatFactory.ID == factory?.GroupingID {
//        }else{
//            for index in 0..<heatExchangeArr.count {
//                if heatExchangeArr[index].heatFactory.ID == factory?.GroupingID{
//                    current = index
//                    self.datas = heatExchangeArr[index]
//                    self.navigationItem.title = datas?.heatFactory.Name
//                    self.collectionView?.reloadData()
//                }
//            }
//        }
    }
    
    
    @objc func sendData(_ sender: Notification) {
        let array = heatExchangeArr[thisCurrent]
        print("\(array.heatFactory.Name)")
        self.datas = array
        self.collectionView?.reloadData()
        
        getSearchData()
        let info = ["datas": result]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "exchanger-result"), object: self, userInfo: info)
    }
    
    func didSelecteItem(_ groupInfo: GroupingInfo) {
        UIView.beginAnimations(nil, context: nil)
        rightSlideMenu.view.center = CGPoint.init(x: UIScreen.main.bounds.width - rightSlideMenu.view.frame.width, y: 0)
        UIView.commitAnimations()
    }
    
    func initSearch() {
        bgView = UIView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 64), size: CGSize.init(width: self.view.bounds.width, height: 44)))
        bgView?.backgroundColor = UIColor(red: CGFloat(0)/255.0, green: CGFloat(178)/255.0, blue: CGFloat(178)/255.0, alpha: CGFloat(0.4))
        bgView?.backgroundColor = UIColor.init(hexString: "#DBf4f4")
        self.view.addSubview(bgView!)
        searchTxt.frame = CGRect.init(x: 10, y: 7, width: self.view.bounds.width - 90, height: 30)
        searchTxt.borderStyle = .roundedRect
        let imageview = UIImageView.init(image: #imageLiteral(resourceName: "search"))
        imageview.frame = CGRect.init(x: searchTxt.frame.width - 30, y: 0, width: 30, height: 30)
        searchTxt.addSubview(imageview)
        searchTxt.returnKeyType = .done
        searchTxt.delegate = self
        
        searchBtn = UIButton.init(type: .system)
        searchBtn?.frame = CGRect(x: self.view.bounds.width - 70, y: 7, width: 60, height: 30)
        searchBtn?.backgroundColor = UIColor(red: CGFloat(0)/255.0, green: CGFloat(178)/255.0, blue: CGFloat(178)/255.0, alpha: CGFloat(1.0))
        searchBtn?.setTitle("搜索", for: .normal)
        searchBtn?.layer.masksToBounds = true
        searchBtn?.layer.cornerRadius = 5
        searchBtn?.tintColor = UIColor.white
        searchBtn?.addTarget(self, action: #selector(toResult), for: .touchUpInside)
        bgView?.addSubview(searchBtn!)
        bgView?.addSubview(searchTxt)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func getSearchData() {
        result = []
        if let text = searchTxt.text {
            if !text.isEmpty{
                if needGroup{
                Alamofire.request("http://124.114.131.38:6099/Analyze.svc/SearchByHeatFactoryIDAndName/4/\(text)", method: .get).responseJSON(completionHandler: { (reponse) in
                    if reponse.result.isSuccess{
                        if let value = reponse.result.value{
                            let data = JSON(value)
                            let result = HFModel.init(data: data)
                            
                        }else{
                            
                        }
                    }
                })
                
                }
                let facModel = datas?.heatFactory
                let heatExchangers = datas?.heatExchangerList
                var exchangers: [HeatExchangeModel] = []
                
                for temp in heatExchangers!{
                    if temp.Name.components(separatedBy: text).count > 1{
                        exchangers.append(temp)
                    }
                }
                if exchangers.isEmpty{
                    result = []
                }else{
                    result.append((facModel!,exchangers))
                }
            }
        }
    }
    
    @objc func toResult() {
        if needGroup {
            if let text = searchTxt.text {
                if !text.isEmpty{
                    let story = UIStoryboard.init(name: "ResultStoryBoard", bundle: nil)
                    let result = story.instantiateViewController(withIdentifier: "result") as! ResultViewController
                    result.text = text
                    result.global = false
                    result.factorID = (self.factor?.ID)!
                    let nav = UINavigationController.init(rootViewController: result)
                    self.present(nav, animated: true, completion: nil)
                }
            }
        }else{
            
            getSearchData()
            let resultController = resultCollectionViewController()
            resultController.models = result
            resultController.fromFactory = false
            self.searchTxt.resignFirstResponder()
            let nav = UINavigationController.init(rootViewController: resultController)
            
            self.present(nav, animated: true, completion: nil)
        }
//        getSearchData()
//        let resultController = resultCollectionViewController()
//        resultController.models = result
//        resultController.fromFactory = false
    }
    
    private func initCollectionView() {
        self.collectionView?.frame = CGRect.init(x: 0, y: 108, width: self.view.bounds.width, height: self.view.bounds.height - 108)
        self.collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: Identify.cell)
        self.collectionView?.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identify.header)
        self.collectionView?.allowsMultipleSelection = false
        self.collectionView?.keyboardDismissMode = .onDrag
        self.collectionView?.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if needGroup {
            if isFactor {
                if let fac = self.factor{
                    return fac.isHaveGroup ? fac.groups.count : 1
                }
            }
            return 1
        }else{
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identify.header, for: indexPath) as! CollectionReusableView
        if needGroup {
            if isFactor{
                if let fac = self.factor {
                    if fac.isHaveGroup{
                        view.model = self.factor?.groups[indexPath.section]
                    }
                }
            }else{
                view.model = self.factor?.groups.first
            }
        }else{
//            view.frame.height = 0
            view.model1 = datas?.heatFactory
        }
        return view
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var num = 0
        if needGroup {
            if isFactor {
                if let fac = self.factor {
                    num = fac.isHaveGroup ? fac.groups[section].exchangers.count : fac.heatExchangers.count
                }
            }else{
                num = (self.factor?.groups.first?.exchangers.count)!
            }
        }else{
            num = datas!.heatExchangerList.count
        }
        return num
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identify.cell, for: indexPath) as! CollectionViewCell
        if needGroup {
        if isFactor {
        if let fac = self.factor {
        if fac.isHaveGroup {
            cell.exchangerModel = fac.groups[indexPath.section].exchangers[indexPath.row]
        }else{
            cell.exchangerModel = fac.heatExchangers[indexPath.row]
        }
            }
        }else{
            cell.exchangerModel = self.factor?.groups.first?.exchangers[indexPath.row]
        }
        }else{
            cell.exchangerModel1 = datas?.heatExchangerList[indexPath.row]
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppProvider.instance.setVersion()
        if AppProvider.instance.appVersion == .idh {
            
            let exc = HeatExchangerTabBarController()
            exc.selectedIndex = 0
            let nav = UINavigationController.init(rootViewController: exc)
            heatExchangerID = (datas?.heatExchangerList[indexPath.row].ID)!
            heatExchangerName = (datas?.heatExchangerList[indexPath.row].Name)!
            
            if let fac = self.factor{
                if fac.isHaveGroup{    
//              monitor.dataModel = factor?.groups[indexPath.section].exchangers
                }else{
//              monitor.dataModel = factor?.heatExchangers
                }
            }else{
            }
//            heatExchangerID =
//            monitor.dataModel = (datas?.heatExchangerList)!
//            monitor.currentIndex = indexPath.row
            self.present(nav, animated: true, completion: nil)
        }else{
//            model = getExchangerModel(indexPath)
            if needGroup{
                let md = self.factor?.groups[indexPath.section].exchangers[indexPath.row]
                heatExchangerID = (md?.ID)!
                heatExchangerName = (md?.Name)!
                if let fac = factor{
                    let a = fac.groups[indexPath.section].exchangers
                    print(indexPath)
                    model = getExchangerModel(indexPath)
                    models = []
                    current = indexPath.item
                    for temp in a{
                        models.append(HeatExchangeModel.init(id: temp.ID, name: temp.Name))
                    }
                }
            }else{
                heatExchangerID = (datas?.heatExchangerList[indexPath.row].ID)!
                heatExchangerName = (datas?.heatExchangerList[indexPath.row].Name)!
//                Tools.setMonitors((datas?.heatExchangerList[indexPath.row].ID)!)
            }
            let root = HeatExchangerTabBarController()
            root.selectedIndex = 0
            let nav = UINavigationController.init(rootViewController: root)
            
//            let heatStoryBoard = UIStoryboard(name: "MixMonitorVC", bundle: nil)
//            let monitor = heatStoryBoard.instantiateViewController(withIdentifier: "excMixMonitor")
            
//            let monitor = ExchangerMixMonitorViewController()
            
            
//            let monitor = MonitorViewController()
//            monitor.model = getModel(indexPath)
//            if let data = datas {
//                let exchangers = data.heatExchangerList
//                monitor.models = exchangers
//            }

//            let exc = HeatExchangerTabBarController()
//            exc.selectedIndex = 0
//            let monitor = MonitorViewController()
//            var models:[exchangerModel] = []
//            if needGroup{
//            monitor.model = getExchangerModel(indexPath)
//            monitor.groupModels = getModels(indexPath)
//            }else{
//                monitor.model = getModel(indexPath)
//                if let data = datas {
//                    let exchangers = data.heatExchangerList
//                    monitor.models = exchangers
//                }
//            }
//            monitor.current = indexPath.row
            
            self.searchTxt.resignFirstResponder()
            self.present(nav, animated: true, completion: nil)
            
//            if isFactor{
//                monitor.model = getExchangerModel(indexPath)
//                if let fac = self.factor{
//                    if fac.isHaveGroup{
//                    models = fac.groups[indexPath.section].exchangers
//                }else{
//                    models = fac.heatExchangers
//                }
//            }
//            }else{
//                models = (self.factor?.heatExchangers)!
//            }
//            monitor.models = models
//            monitor.current = indexPath.row
//            self.searchTxt.resignFirstResponder()
//            self.present(monitor, animated: true, completion: nil)
        }
    }

    //create for new working factor
    func getExchangerModel(_ index:IndexPath) -> heatModel? {
        realm = try! Realm()
        let model:exchangerModel?
        if isFactor {
            if let fac = self.factor {
                if fac.isHaveGroup{
                    model = fac.groups[index.section].exchangers[index.item]
                    if let id = model?.ID{
                        let modelRealm = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
                        return modelRealm
                    }

                }else{
                    model = fac.heatExchangers[index.item]
                    if let id = model?.ID{
                        let modelRealm = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
                        return modelRealm
                    }

                }
            }
        }else{
            model = factor?.groups.first?.exchangers[index.item]
            if let id = model?.ID{
                let modelRealm = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
                return modelRealm
            }
        }
        
        return nil
    }
    
    func getModels(_ index:IndexPath) -> [exchangerModel] {
        var models:[exchangerModel] = []
        
        if isFactor {
            if let fac = self.factor {
                if fac.isHaveGroup{
                    models = fac.groups[index.section].exchangers
                }else{
                    models = fac.heatExchangers
                }
            }
        }else{
            models = (factor?.groups.first?.exchangers)!
        }
        return models
    }
    
    func getModel(_ index: IndexPath) -> heatModel? {
        realm = try! Realm()
        if let data = datas {
            let exchangerList = data.heatExchangerList[index.row]
            let id = exchangerList.ID
            print("\(id)")
            let model = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
            return model
        }
        return nil
    }
    
//    func Last(_ model: heatModel) -> String {
//        Alamofire.request(MonitorURL, method: .get, parameters: ["action":"get", "path": model.path]).responseData { reponse in
//            if reponse.result.isSuccess{
//                let doc = try! DDXMLDocument.init(data: reponse.value!, options: 0)
//                let back = try! doc.nodes(forXPath: "//background").first as! DDXMLElement
//                let backPath = back.attribute(forName: "filename")?.stringValue
//                return backPath
//            }else{
//            return ""
//        }
//    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

//extension ExchangerCollectionViewController: ChangeFactory{
//    func change(factory: GroupingInfo) {
//        let factory = factory
//
//}

extension ExchangerCollectionViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTxt.resignFirstResponder()
        return true
    }
}

extension ExchangerCollectionViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if !isFactor {
            return CGSize.init(width: collectionView.bounds.width, height: 0)
        }
        return CGSize.init(width: collectionView.bounds.width, height: 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        return CGSize.init(width: width/3 - 10, height: 130)
    }
}
