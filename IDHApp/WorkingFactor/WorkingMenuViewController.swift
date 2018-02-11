//
//  WorkingMenuViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/26.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

protocol TapSlider {
    func didSelecteItem(_ groupInfo: GroupingInfo)
}

class WorkingMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myTable: UITableView!
    var groupName = ""
    var List: [GroupingInfo] = []
    var delegate: TapSlider?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        groupName = (getGroupingName()?.GroupingName)!
        //消除滚动视图与导航栏、标签栏的垂直空隙
        self.automaticallyAdjustsScrollViewInsets = false
        
        myTable.dataSource = self
        myTable.delegate = self
        
        //解决分割线不全的问题
        if myTable.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            myTable.separatorInset = UIEdgeInsets.zero
        }
        if myTable.responds(to: #selector(setter: UIView.layoutMargins)){
            myTable.layoutMargins = UIEdgeInsets.zero
        }
        

        // Do any additional setup after loading the view.
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupName
    }
    
    func getGroupingName() -> GroupingInfo?{
        for index in 0..<groupList.count {
            if groupList[index].GroupingType == "group"{
                groupList.remove(at: index)
                List = groupList
                return groupList[index]
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return List.count
    }
    
    //设置行的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  39
    }


    @IBAction func sceneChange(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "mode"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell
        myCell.backgroundColor = UIColor.clear
        
        if indexPath.row == 0 {
            myCell.textLabel?.textColor = UIColor(red: 0/255.0, green: 178/255.0, blue: 178/255.0, alpha: CGFloat(1.0))
        }
        else {
            myCell.textLabel?.textColor = UIColor.white
        }
        
        myCell.textLabel?.text = "  \((List[indexPath.row]).GroupingName)"
        
        return myCell
    }
    
    // 处理点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupingID = List[indexPath.row].GroupingID
        let groupingType = List[indexPath.row].GroupingType
        let groupingName = List[indexPath.row].GroupingName
        
        delegate?.didSelecteItem(List[indexPath.row])
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
