//
//  MenuViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/18.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias globalCallBack = (_ group: GroupingInfo) -> Void

class GlobalMenuViewController: UIViewController {
    var table = UITableView()
    var sceneChange = UIButton()
    var fac: HeatFactoryModel?
    
    var current = 0
    
    var groupArr: [GroupingInfo] = []
    
    var delegate: ChangeFactory?
    
    var menuCallback:globalCallBack?
    
    //2018.4.2
    //    var facModelArr:[TreeGroupModel] = []
    
    //    var arr:[(TreeGroupModel, group)]
    
    
    var closeArr: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getDataForGroup()
        getTitle()
        
        self.table.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width/1.5, height: self.view.bounds.height-48)
        self.table.delegate = self
        self.table.dataSource = self
        self.view.addSubview(table)
        self.view.backgroundColor = UIColor.gray
        self.table.backgroundColor = UIColor.gray
        //        self.table.register(UINib.init(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "TreeCell")
        self.table.register(GlobalTableViewCell.self, forCellReuseIdentifier: "menuCell")
        self.table.tableFooterView = UIView()
    }
    
    /*
     func getDataForGroup() {
     let url = "http://124.114.131.38:6099/Analyze.svc/GetGroupListAll"
     Alamofire.request(url, method: .get).responseJSON { (reponse) in
     if reponse.result.isSuccess{
     if let data = reponse.result.value{
     let jsData = JSON(data)
     for (_,data) in jsData{
     let id = data["ID"].stringValue
     let name = data["Name"].stringValue
     let Type = data["Type"].stringValue
     let list = data["ItemList"].arrayValue
     var arr:[TreeGroupModel] = []
     for temp in list{
     let name = temp["Name"].stringValue
     let id = temp["ID"].stringValue
     let type = temp["Type"].stringValue
     let hfID = temp["HeatFactoryID"].stringValue
     
     let data = TreeGroupModel.init(id, name, nil, type, hfID)
     arr.append(data)
     }
     self.facModelArr.append(TreeGroupModel.init(id, name, arr, Type))
     }
     for _ in self.facModelArr{
     self.closeArr.append(true)
     }
     self.table.reloadData()
     }
     }
     }
     }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTitle() {
        for group in groupList {
//            if group.GroupingType == "group"{
//                self.navigationItem.title = group.GroupingName
//            }else{
                self.groupArr.append(group)
//            }
        }
        for index in 0..<self.groupArr.count {
            if groupArr[index].GroupingID == globalGrouping?.GroupingID && groupArr[index].GroupingType == globalGrouping?.GroupingType{
                current = index
            }
        }
        self.table.reloadData()
    }
}

extension GlobalMenuViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return facModelArr.count
        
        return groupArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! GlobalTableViewCell
        
        cell.titleLabel.text = groupArr[indexPath.row].GroupingName
        if indexPath.row == current {
            cell.titleLabel.textColor = #colorLiteral(red: 0, green: 0.9991016984, blue: 0.9278653264, alpha: 1)
        }else{
            cell.titleLabel.textColor = UIColor.white
        }
        cell.selectionStyle = .none
        return cell
        //        cell.index = indexPath
        //        cell.isClose = closeArr[indexPath.row]
        //        cell.data = self.facModelArr[indexPath.row]
        //
        //        cell.icon.addTarget(self, action: #selector(showOrExpand(_:)), for: .touchUpInside)
        //
        //        if cell.data.ID == current?.ID && cell.data.Type == current?.Type {
        //            cell.title.textColor = #colorLiteral(red: 0, green: 0.9991016984, blue: 0.9278653264, alpha: 1)
        //        }else{
        //            cell.title.textColor = UIColor.white
        //        }
        //        cell.selectionStyle = .none
        //        print("\(cell.index)")
        //        return cell
    }
    
    /*
     @objc func showOrExpand(_ sender:MenuButton) {
     if let indexPath = sender.index{
     let cell = self.table.cellForRow(at: indexPath) as! MenuCell
     if cell.isClose {
     if !cell.childs.isEmpty{
     var i = 1
     var index: [IndexPath] = []
     closeArr[indexPath.row] = false
     for temp in cell.childs{
     facModelArr.insert(temp, at: indexPath.row + i)
     closeArr.insert(true, at: indexPath.row + i)
     let ip = IndexPath.init(row: indexPath.row + i, section: 0)
     index.append(ip)
     i += 1
     }
     self.table.insertRows(at: index, with: .none)
     cell.isClose = false
     }
     }else{
     if !cell.childs.isEmpty{
     closeArr[indexPath.row] = true
     cell.isClose = true
     var ips:[IndexPath] = []
     for i in 1...cell.childs.count{
     ips.append(IndexPath.init(row: indexPath.row + i, section: 0))
     }
     facModelArr.removeSubrange(ips[0].row...(ips.last?.row)!)
     closeArr.removeSubrange(ips[0].row...(ips.last?.row)!)
     self.table.deleteRows(at: ips, with: .none)
     }
     }
     
     }
     }
     
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let group = groupArr[indexPath.row]
        guard let call = self.menuCallback else { return }
        call(group)
        
        
        //        let cell = tableView.cellForRow(at: indexPath) as! MenuCell
        //点击 不同区域调用不同接口
        //        var userinfo :[String:Any] = [:]
        //        let data = cell.data
        //
        //        if cell.data.Type == "heatfactory" {
        //            userinfo = ["id":"\(cell.data.ID!)"]
        //        }else if cell.data.Type == "group"{
        //            userinfo = ["hfid":"\(data?.hfID! ?? "")", "id":"\(data?.ID! ?? "")"]
        //        }
        //        let reveal = self.revealViewController()
        ////            cell.data.ID
        //            current = cell.data
        //
        //            self.table.reloadData()
        //
        //            reveal?.setFrontViewPosition(FrontViewPosition.right, animated: true)
        //
        //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFactory"), object: self, userInfo: userinfo)
        
        /*
         if !cell.childs.isEmpty {
         if cell.isClose {
         var i = 1
         var index: [IndexPath] = []
         closeArr[indexPath.row] = false
         for temp in cell.childs{
         facModelArr.insert(temp, at: indexPath.row + i)
         closeArr.insert(true, at: indexPath.row + i)
         let ip = IndexPath.init(row: indexPath.row + i, section: 0)
         index.append(ip)
         i += 1
         }
         tableView.insertRows(at: index, with: .none)
         cell.isClose = false
         }else{
         closeArr[indexPath.row] = true
         cell.isClose = true
         var ips:[IndexPath] = []
         for i in 1...cell.childs.count{
         ips.append(IndexPath.init(row: indexPath.row + i, section: 0))
         }
         facModelArr.removeSubrange(ips[0].row...(ips.last?.row)!)
         closeArr.removeSubrange(ips[0].row...(ips.last?.row)!)
         tableView.deleteRows(at: ips, with: .none)
         }
         }else{
         //跳转
         
         }
         
         if cell.isClose {
         if !cell.childs.isEmpty{
         var i = 1
         var index: [IndexPath] = []
         closeArr[indexPath.row] = false
         for temp in cell.childs{
         facModelArr.insert(temp, at: indexPath.row + i)
         closeArr.insert(true, at: indexPath.row + i)
         let ip = IndexPath.init(row: indexPath.row + i, section: 0)
         index.append(ip)
         i += 1
         }
         tableView.insertRows(at: index, with: .none)
         cell.isClose = false
         }else{
         //
         }
         }else{
         if !cell.childs.isEmpty{
         closeArr[indexPath.row] = true
         cell.isClose = true
         var ips:[IndexPath] = []
         for i in 1...cell.childs.count{
         ips.append(IndexPath.init(row: indexPath.row + i, section: 0))
         }
         facModelArr.removeSubrange(ips[0].row...(ips.last?.row)!)
         closeArr.removeSubrange(ips[0].row...(ips.last?.row)!)
         tableView.deleteRows(at: ips, with: .none)
         }else{
         
         }
         }
         */
        
        let reveal = self.revealViewController()
        
//        if heatExchangeArr.contains(where: { (element) -> Bool in
//            if element.heatFactory.ID == groupArr[indexPath.row].GroupingID{
//                return true
//            }else{
//                return false
//            }
//        }){
        
            call(group)
            current = indexPath.row
            self.table.reloadData()
            reveal?.setFrontViewPosition(FrontViewPosition.right, animated: true)
            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFactory"), object: self, userInfo: ["datas": groupArr[current]])
        
//        }else{
        
            //do nothing
            
//            Toast.shareInstance().showView(self.view, title: "暂无数据")
//            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        
//        }
        
    }
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 0.5)
        Toast.shareInstance().hideView()
    }
}

