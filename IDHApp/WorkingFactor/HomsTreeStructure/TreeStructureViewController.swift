//
//  TreeStructureViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/2/2.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

class TreeStructureViewController: UIViewController {
    var datas:[heatModel] = [] //当前数据库
    var isopen:[Bool] = [] //开关数组
    var levelArr: [Int] = []
    
    
    var treeTable = UITableView()
    var realm:Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        if #available(iOS 11.0, *) {
            self.treeTable.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        realm = try! Realm()
        setupTable()
        getFirstData()
        NotificationCenter.default.addObserver(self, selector: #selector(getFirstData), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    func setupNav() {
        if group_name.isEmpty {
            self.navigationItem.title = "监控画面列表"
        }else{
            self.navigationItem.title = group_name
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "退出", style: .done, target: self, action: #selector(logionut))
    }
    
    @objc func logionut() {
        let alert = UIAlertController.init(title: "退出登录", message: "是否确认退出", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "退出", style: .destructive, handler: { alert  in
            let login = UIStoryboard.init(name: "Login", bundle: nil)
            let logonVC = login.instantiateViewController(withIdentifier: "login")
            self.present(logonVC, animated: true) {
                UserDefaults.standard.removeObject(forKey: "roleID")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupTable() {
        treeTable.frame = CGRect.init(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height-64)
        treeTable.delegate = self
        treeTable.dataSource = self
        treeTable.register(HomsTreeTableViewCell.self, forCellReuseIdentifier: "treeCell")
        treeTable.separatorStyle = .singleLine
        self.treeTable.tableFooterView = UIView()
        
        
        //解决分割线不全的问题
        if treeTable.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            treeTable.separatorInset = UIEdgeInsets.zero
        }
        if treeTable.responds(to: #selector(setter: UIView.layoutMargins)){
            treeTable.layoutMargins = UIEdgeInsets.zero
        }
        self.view.addSubview(treeTable)
    }
    
    @objc func getFirstData() {
        print("1111")
        datas = (realm?.objects(heatModel.self).filter("parent_name = 'topviews'").toArray(of: heatModel.self))!
        for _ in datas {
            self.isopen.append(false)
        }
        treeTable.reloadData()
    }
    
    func hasChild(_ model:heatModel) -> Bool {
        if (realm?.objects(heatModel.self).filter("parent_id = '\(model.area_id)'").isEmpty)!{
            return false
        }else{
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TreeStructureViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
//    //解决分割线不全的问题
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeCell", for: indexPath) as! HomsTreeTableViewCell
        cell.isOpen = isopen[indexPath.row]
        cell.data = datas[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomsTreeTableViewCell
        if !cell.isOpen{
            if !cell.childs.isEmpty{
                //查询，插入数据
                var i = 1
                var indexpaths: [IndexPath] = []
                isopen[indexPath.row] = true
                for temp in cell.childs{
                    datas.insert(temp, at: indexPath.row + i)
                    isopen.insert(false, at: indexPath.row + i)
                    let ip = IndexPath.init(row: indexPath.row + i, section: 0)
                    indexpaths.append(ip)
                    i += 1
                }
                tableView.insertRows(at: indexpaths, with: .none)
                cell.isOpen = true
            }
        }else{
            if !cell.childs.isEmpty{
                isopen[indexPath.row] = false
                cell.isOpen = false
                let level = cell.level
                var ips:[IndexPath] = getRemovedIndexpath(level, indexPath)
                datas.removeSubrange(ips[0].row...(ips.last?.row)!)
                isopen.removeSubrange(ips[0].row...(ips.last?.row)!)
                tableView.deleteRows(at: ips, with: .none)
            }
        }
    }
    func getRemovedIndexpath(_ level: Int, _ indexpath:IndexPath) -> [IndexPath]{
        var ips: [IndexPath] = []
        for i in indexpath.row + 1..<datas.count {
            if getLevel(datas[i]) <= level{
                return ips
            }
            let index = IndexPath.init(row: i, section: 0)
            ips.append(index)
        }
        return ips
    }
    
    func getLevel(_ data: heatModel) -> Int{
        var count = 0
        let realm = try! Realm()
        var model:heatModel = data
        while !(realm.objects(heatModel.self).filter("area_id == \(model.parent_id)").isEmpty) {
            count += 1
            model = (realm.objects(heatModel.self).filter("area_id == \(model.parent_id)").first)!
        }
        return count
    }
}

extension TreeStructureViewController:TreeCellProtocol{
    func chooseCell(_ data: heatModel) {
        
        let monitor = MonitorViewController()
//        monitor.model = data
//        monitor.models = []
//        monitor.current = 0
        model = data
        models = []
       current = 0
        self.present(monitor, animated: true, completion: nil)
        
    }
}
