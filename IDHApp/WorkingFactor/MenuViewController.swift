//
//  MenuViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/18.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

protocol ChangeFactory {
    func change(factory: GroupingInfo)
}

class MenuViewController: UIViewController {
    var table = UITableView()
    var sceneChange = UIButton()
    var fac: HeatFactoryModel?
    
    var current = 0
    
    var groupArr: [GroupingInfo] = []
    
    var delegate: ChangeFactory?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTitle()
        self.table.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width/1.5, height: self.view.bounds.height)
        self.table.delegate = self
        self.table.dataSource = self
        self.view.addSubview(table)
        self.view.backgroundColor = UIColor.gray
        self.table.backgroundColor = UIColor.gray
        self.table.separatorStyle = .none
        self.table.register(MenuTableViewCell.self, forCellReuseIdentifier: "menuCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTitle() {
        for group in groupList {
            if group.GroupingType == "group"{
                self.navigationItem.title = group.GroupingName
            }else{
                self.groupArr.append(group)
            }
        }
        for index in 0..<self.groupArr.count {
            if groupArr[index].GroupingID == fac?.ID{
                current = index
            }
        }
        self.table.reloadData()
    }
    
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource{
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
        return groupArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        cell.titleLabel.text = groupArr[indexPath.row].GroupingName
        if indexPath.row == current {
            cell.titleLabel.textColor = #colorLiteral(red: 0, green: 0.9991016984, blue: 0.9278653264, alpha: 1)
        }else{
            cell.titleLabel.textColor = UIColor.white
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reveal = self.revealViewController()
        
        if heatExchangeArr.contains(where: { (element) -> Bool in
            if element.heatFactory.ID == groupArr[indexPath.row].GroupingID{
                return true
            }else{
                return false
            }
        }){
            
            current = indexPath.row
            self.table.reloadData()
            reveal?.setFrontViewPosition(FrontViewPosition.right, animated: true)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeFactory"), object: self, userInfo: ["datas": groupArr[current]])
            
        }else{
            //do nothing
            Toast.shareInstance().showView(self.view, title: "暂无数据")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }
        
        
    }
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 0.5)
        Toast.shareInstance().hideView()
    }
    
    
    
    
}
