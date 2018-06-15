//
//  AlarmSettingViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/23.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit


class AlarmSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
            return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width-8,height: 50))
        myView.backgroundColor = UIColor.darkGray
        //名称
        let myLabel = UILabel(frame: CGRect(x: 35,y: 7,width: 140,height: 30))
        myLabel.textColor = UIColor(red: 0/255.0, green: 178/255.0, blue: 178/255.0, alpha: CGFloat(1.0))
        
        if section == 0{
            myLabel.text = "报警数据时效："
        }
        else{
            myLabel.text = "报警声音配置："
        }
        
        myView.addSubview(myLabel)
        return myView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! AlarmMenuTableViewCell
        cell.title.text = rowContent[indexPath.section][indexPath.row]
        cell.state = selected[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeState(indexPath)
    }
    
    func changeState(_ index:IndexPath) {
        if index.section == 0 {
            self.selected[index.section][index.row] = true
            self.selected[0][1-index.row] = false
            Defaults.instance.setValue(forKey: "time", forValue: "\(self.rowContent[index.section][index.row])")
        }else{
             self.selected[index.section][index.row] = !self.selected[index.section][index.row]
            Defaults.instance.setValue(forKey: "mute", forValue: self.selected[index.section][index.row])
        }
        self.settingTable.reloadData()
    }
    
    
    @IBOutlet weak var settingTable: UITableView!
    //数据时效与是否静音
    var minuteSetting:String?
    var isMute:String?
    
    let rowContent = [["30分钟", "15分钟"], ["静音"]]
    var selected = [[false, true], [false]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTable.dataSource = self
        settingTable.delegate = self
        settingTable.tableFooterView = UIView()
        settingTable.backgroundColor = UIColor.darkGray
        if let time = Defaults.instance.getFor(key: "time") {
            selected.removeAll()
            let tim = time as! String
            if tim == "30分钟"{
                selected.append([true, false])
            }else{
                selected.append([false, true])
            }
        }
        
        if let time = Defaults.instance.getFor(key: "mute") {
            let tim = time as! Bool
            if tim{
                selected.append([true])
            }else{
                selected.append([false])
            }
        }
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
