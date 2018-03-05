//
//  resultCollectionViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

class resultCollectionViewController: UICollectionViewController {
    
    var models: [(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])] = []

    var realm: Realm?
    var exchangersArr: [HeatExchangeModel] = []
    
    var fromFactory = true
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: Identify.cell)
        self.collectionView?.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identify.header)
        self.collectionView?.frame.size = CGSize.init(width: self.view.bounds.width, height: self.view.bounds.height)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.title = "搜索结果"
        if fromFactory {
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: "factory-result"), object: nil)
        }else{
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: "exchanger-result"), object: nil)
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if models.isEmpty {
            Toast.shareInstance().showView(self.view, title: "未搜索到匹配项")
            Thread.detachNewThreadSelector(#selector(self.hiddenThreadView), toTarget: self, with: nil)
        }
    }
    
    @objc func hiddenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func update(_ noti: Notification) {
        let dic = noti.userInfo as! [String:[(heatFactory: HeatFactoryModel, heatExchangerList: [HeatExchangeModel])]]
        self.models = dic["datas"]!
        print("\(models)")
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return models.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return models[section].heatExchangerList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identify.cell, for: indexPath) as! CollectionViewCell
        cell.exchangerModel = models[indexPath.section].heatExchangerList[indexPath.row]
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if AppProvider.instance.appVersion == .idh {
            let storyBoard = UIStoryboard.init(name: "HomsExchanger", bundle: nil)
            let monitor = storyBoard.instantiateViewController(withIdentifier: "HomsMonitor") as! HomsMonitorViewController
            monitor.dataModel = getAllExchangers()
            monitor.currentIndex = foundIndex(models[indexPath.section].heatExchangerList[indexPath.row])
            self.present(monitor, animated: true, completion: nil)
        }else if AppProvider.instance.appVersion == .idhWithHoms{
            let monitor = MonitorViewController()
            monitor.model = getModel(indexPath)
            monitor.models = getExchangers(indexPath)
            monitor.current = indexPath.row
            self.present(monitor, animated: true, completion: nil)
        }
        
    }
    
    func foundIndex(_ heat:HeatExchangeModel) -> Int {
        for i in 0..<getAllExchangers().count {
            if heat.ID == getAllExchangers()[i].ID && heat.Name == getAllExchangers()[i].Name{
                return i
            }
        }
        return 0
    }
    
    func getAllExchangers() -> [HeatExchangeModel]{
        var arr:[HeatExchangeModel] = []
        for temp in models {
            for ech in temp.heatExchangerList{
                arr.append(ech)
            }
        }
        return arr
    }
    
    func getModel(_ index: IndexPath) -> heatModel? {
        realm = try! Realm()
            let exchangerList = models[index.section].heatExchangerList[index.row]
            let id = exchangerList.ID
            let model = realm?.objects(heatModel.self).filter("idh_id = '\(id)'").first
            return model
    }
    
    func getExchangers(_ index: IndexPath) -> [HeatExchangeModel]{
        return models[index.section].heatExchangerList
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if models.isEmpty {
            return UIView() as! UICollectionReusableView
        }else{
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identify.header, for: indexPath) as! CollectionReusableView
        view.model = models[indexPath.section].heatFactory
        return view
        }
    }

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

extension resultCollectionViewController: UICollectionViewDelegateFlowLayout{
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
        //        collectionView.cellForItem(at: indexPath)?.layoutIfNeeded()
        //        let height = collectionView.cellForItem(at: indexPath)?.bounds.height
        
        return CGSize.init(width: collectionView.bounds.width/3 - 10, height: 130)
    }
}
