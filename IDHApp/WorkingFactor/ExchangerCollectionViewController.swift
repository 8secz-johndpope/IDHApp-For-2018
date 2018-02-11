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
import MMDrawerController

private let reuseIdentifier = "Cell"

class ExchangerCollectionViewController: UICollectionViewController{
    
    var datas:(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])?
    var result:[(heatFactory:HeatFactoryModel, heatExchangerList:[HeatExchangeModel])] = []
    
    var searchTxt = UITextField()
    var realm: Realm?
    
    var rightSlideMenu: UIViewController!
    
    var current: Int = 0
    
//    var delegate: refreshManager?
//
//    var changeDelegate: ChangeFactory?
    
    
    var searchBtn: UIButton?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let reveal = self.revealViewController()
        reveal?.panGestureRecognizer()
        reveal?.tapGestureRecognizer()
        
        initCollectionView()
        initSearch()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = datas?.heatFactory.Name
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu"), style: .done, target: reveal, action: #selector(reveal?.rightRevealToggle(_:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendData(_:)), name: NSNotification.Name(rawValue: "changeData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeFactor(_:)), name: NSNotification.Name(rawValue: "changeFactory"), object: nil)
    }
    
    @objc func changeFactor(_ sender: Notification) {
        let info = sender.userInfo as! [String: GroupingInfo]
        let factory = info["datas"]
        
        if datas?.heatFactory.ID == factory?.GroupingID {
        }else{
            for index in 0..<heatExchangeArr.count {
                if heatExchangeArr[index].heatFactory.ID == factory?.GroupingID{
                    current = index
                    self.datas = heatExchangeArr[index]
                    self.navigationItem.title = datas?.heatFactory.Name
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    
    @objc func sendData(_ sender: Notification) {
        let array = heatExchangeArr[current]
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
        let bgView = UIView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 64), size: CGSize.init(width: self.view.bounds.width, height: 44)))
        bgView.backgroundColor = UIColor(red: CGFloat(0)/255.0, green: CGFloat(178)/255.0, blue: CGFloat(178)/255.0, alpha: CGFloat(0.4))
        bgView.backgroundColor = UIColor.init(hexString: "#DBf4f4")
        self.view.addSubview(bgView)
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
        bgView.addSubview(searchBtn!)
        bgView.addSubview(searchTxt)
    }
    
    

    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func getSearchData() {
        result = []
        if let text = searchTxt.text {
            if !text.isEmpty{
                let facModel = datas?.heatFactory
                let heatExchangers = datas?.heatExchangerList
                var exchangers: [HeatExchangeModel] = []
                
                for temp in heatExchangers!{
                    if temp.Name.components(separatedBy: text).count > 1{
                        exchangers.append(temp)
                    }
                }
                result.append((facModel!,exchangers))
            }
        }
    }
    
    @objc func toResult() {
        getSearchData()
        let resultController = resultCollectionViewController()
        resultController.models = result
        resultController.fromFactory = false
        self.searchTxt.resignFirstResponder()
        let nav = UINavigationController.init(rootViewController: resultController)
        
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    private func initCollectionView() {
        self.collectionView?.frame = CGRect.init(x: 0, y: 108, width: self.view.bounds.width, height: self.view.bounds.height - 108)
        self.collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: Identify.cell)
        self.collectionView?.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identify.header)
        self.collectionView?.allowsMultipleSelection = false
        self.collectionView?.keyboardDismissMode = .onDrag
        self.collectionView?.backgroundColor = UIColor.clear
        
//        let changers = MenuViewController()
//        changers.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identify.header, for: indexPath) as! CollectionReusableView
        view.model = datas?.heatFactory
        return view
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return datas!.heatExchangerList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identify.cell, for: indexPath) as! CollectionViewCell
        cell.exchangerModel = datas?.heatExchangerList[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppProvider.instance.appVersion == .idh {
            
            let storyBoard = UIStoryboard.init(name: "HomsExchanger", bundle: nil)
            let monitor = storyBoard.instantiateViewController(withIdentifier: "HomsMonitor") as! HomsMonitorViewController
            monitor.dataModel = (datas?.heatExchangerList)!
            monitor.currentIndex = indexPath.row
            self.present(monitor, animated: true, completion: nil)
        }else{
            
            let monitor = MonitorViewController()
            monitor.model = getModel(indexPath)
            if let data = datas {
                let exchangers = data.heatExchangerList
                monitor.models = exchangers
            }
            monitor.current = indexPath.row
            self.searchTxt.resignFirstResponder()
            self.present(monitor, animated: true, completion: nil)
        }
        
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
        return CGSize.init(width: collectionView.bounds.width, height: 40)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width/3 - 10, height: 130)
    }
}
