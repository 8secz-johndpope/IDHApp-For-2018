//
//  ResultViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResultTableViewCell
        //下面这两个语句一定要添加，否则第一屏显示的collection view尺寸，以及里面的单元格位置会不正确
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        cell.reloadData(datas[indexPath.section])
        cell.transBlock = { (model, index) in
//            print("\(model?.area_name)")
//            self.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            self.gotoMonitor(indexPath, itemIndexpath: index, model: model)
        }
        
        return cell
    }
    
    func gotoMonitor(_ factorIndex:IndexPath, itemIndexpath:IndexPath, model:heatModel?) {
        
        let section = factorIndex.section
        
        if AppProvider.instance.appVersion == .idh {
            let storyBoard = UIStoryboard.init(name: "HomsExchanger", bundle: nil)
            let monitor = storyBoard.instantiateViewController(withIdentifier: "HomsMonitor") as! HomsMonitorViewController
//            monitor.dataModel = getAllExchangers()
//            monitor.currentIndex = foundIndex(models[indexPath.section].heatExchangerList[indexPath.row])
            self.present(monitor, animated: true, completion: nil)
        }else if AppProvider.instance.appVersion == .idhWithHoms{
            let monitor = MonitorViewController()
            
//            monitor.model = getModel(indexPath)
//            monitor.models = getExchangers(indexPath)
//            monitor.current = indexPath.row
            self.present(monitor, animated: true, completion: nil)
        }
        
    }
    
    
    //返回一组换热站
    func getexArr(_ section:Int, index:IndexPath) -> ([exchangerModel], Int) {
        if datas[section].isHaveGroup {
            return (datas[section].groups[index.section].exchangers, index.item)
        }else{
            return (datas[section].heatExchangers, index.item)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return datas[section].Name
    }

    @IBOutlet weak var table: UITableView!
    var datas:[HFModel] = []
    var text:String = ""
    var global:Bool = true
    var factorID = ""
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.dataSource = self
        self.table.delegate = self
        // Do any additional setup after loading the view.
        //去除单元格分隔线
        self.table.separatorStyle = .none
        //创建一个重用的单元格
        self.table.register(UINib(nibName:"ResultTableViewCell", bundle:nil),
                                 forCellReuseIdentifier:"cell")
        //设置estimatedRowHeight属性默认值
        self.table.estimatedRowHeight = 130
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.table.rowHeight = UITableViewAutomaticDimension
        loadSearchData(name: text, fromGlobal: global)
        ToastView.instance.showLoadingDlg()
        setUpViews()
    }
    
    func setUpViews(){
        self.title = "搜索结果"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadSearchData(name:String, fromGlobal:Bool = true) {
        //
        var url = ""
        
        if fromGlobal {
            
            url = "http://124.114.131.38:6099/Analyze.svc/SearchAllByName/\(name)"
        }else{
            url = "http://124.114.131.38:6099/Analyze.svc/SearchByHeatFactoryIDAndName/\(factorID)/\(name)"
        }
        print(url)
        let encodeStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let Url = URL.init(string: encodeStr!)
        
        Alamofire.request(Url!, method: .get).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    var resultArr:[HFModel] = []
                    if fromGlobal{
                        for (_,temp) in json{
                            let fac = HFModel.init(data: temp)
                            resultArr.append(fac)
                        }
                    }else{
                        let fac = HFModel.init(data: json)
                        resultArr.append(fac)
                    }
                    ToastView.instance.hide()
                    self.datas = resultArr
                    self.table.reloadData()
                }
            }else{
                ToastView.instance.showToast(text: "\(reponse.error.debugDescription)", pos: .Mid)
                print("\(reponse.error.debugDescription)")
            }
        }
    }
    
    
    override func loadView() {
        super.loadView()
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
