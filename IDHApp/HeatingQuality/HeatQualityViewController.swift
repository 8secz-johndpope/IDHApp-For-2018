//
//  HeatQualityViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/18.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class HeatQualityViewController: UIViewController {
    
    
    //{"Max18to22":{"ID":"1","Name":"11","Ratio":""},"MaxAverage":{"ID":"2","Name":"22","Temperature":""},"MaxLess16":{"ID":"3","Name":"33","Ratio":""},"MaxMore24":{"ID":"4","Name":"44","Ratio":""},"Min18to22":{"ID":"5","Name":"55","Ratio":""},"MinAverage":{"ID":"6","Name":"66","Temperature":""}}
    
//    {"ArrayData":[{"Count":"1","Percent":"","Scope":"<16"},{"Count":"1","Percent":"","Scope":"16~18"},{"Count":"1","Percent":"","Scope":"18~20"},{"Count":"1","Percent":"","Scope":"20~22"},{"Count":"1","Percent":"","Scope":"22~24"},{"Count":"1","Percent":"","Scope":">24"}]}
    
    var backHome:backToHome?
    
    var groupType = ""
    var groupID = ""
    
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    

    @IBOutlet weak var lowerThan16Exchanger: UIButton!
    @IBOutlet weak var higherThan24Exchanger: UIButton!
    @IBOutlet weak var minExchanger: UIButton!
    @IBOutlet weak var maxExchanger: UIButton!
    @IBOutlet weak var interval18To22Max: UIButton!
    @IBOutlet weak var interval18To22Min: UIButton!
    
    @IBOutlet weak var textLow16: UILabel!
    @IBOutlet weak var texthigh24: UILabel!
    @IBOutlet weak var textmaxlower16: UILabel!
    @IBOutlet weak var textmaxhigher24: UILabel!
    @IBOutlet weak var text18To22: UILabel!
    
    @IBOutlet weak var pieView: PieChartView!
    
    @IBOutlet weak var text18To22Min: UILabel!
    
    var buttonArr:[UIButton] = []
    var labelArr:[UILabel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if groupList.isEmpty {
            
            self.navigationItem.title = "供热质量"
        }else{
            self.navigationItem.title = groupList[0].GroupingName
        }
        let color = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
        self.pieView.backgroundColor = color
        buttonArr = [minExchanger, maxExchanger, lowerThan16Exchanger, higherThan24Exchanger, interval18To22Max, interval18To22Min]
        labelArr = [textLow16, texthigh24, textmaxlower16, textmaxhigher24, text18To22, text18To22Min]
        let reveal = self.revealViewController()
//        reveal?.delegate = self
        
        reveal?.panGestureRecognizer()
        reveal?.tapGestureRecognizer()
        
        let globalMenu = reveal?.rightViewController as! GlobalMenuViewController
        
        globalMenu.menuCallback = {[unowned self] group in
            grouping = group
            self.setName()
            self.showPieChart((grouping?.GroupingType)!, groupID: (grouping?.GroupingID)!, date: globalDate)
        }
        
        let menu = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .done, target: reveal, action: #selector(reveal?.rightRevealToggle(_:)))
        
        let trans = UIBarButtonItem.init(image: UIImage.init(named: "back_factory"), style: .done, target: self, action: #selector(goToTrans))
        
        let spacing = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "quality_ico_home"), style: .done, target: self, action: #selector(backToHome))
        
        self.navigationItem.rightBarButtonItems = [menu, trans]
        // Do any additional setup after loading the view.
        
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
        
        showPieChart(groupType, groupID: groupID, date: globalDate)
        setTableData(groupType, groupID: groupID, date: globalDate)
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
    }
    
    func setName() {
        self.navigationItem.title = grouping?.GroupingName
    }
    
    @objc func changeDate(_ sender:UIDatePicker) {
        print("\(Tools.getSelectedDateString(sender))")
        globalDate = Tools.getSelectedDateString(sender)
        setTableData(groupType, groupID: groupID, date: Tools.getSelectedDateString(sender))
        showPieChart(groupType, groupID: groupID, date: Tools.getSelectedDateString(sender))
    }
    
    @objc func goToTrans() {
//        self.tabBarController?.tabBar.isHidden = true
        globalFromVC = .heatingQuality
        globalType = .heat
        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
        let nav = UINavigationController.init(rootViewController: trans)
        outsideToTrans = true
        self.present(nav, animated: true, completion: nil)
//        self.navigationController?.pushViewController(trans, animated: true)
    }
    
    @objc func backToHome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setTableData(_ groupType:String, groupID:String, date:String) {
        let url = GroupQualityData + "/\(globalDate)"
        
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    
                    let minAve = json["MinAverage"]
                    let maxAve = json["MaxAverage"]
                    let maxLess16 = json["MaxLess16"]
                    let maxMore24 = json["MaxMore24"]
                    let max18To22 = json["Max18To22"]
                    let min18To22 = json["Min18To22"]
                    
                    let MinAveModel = QualityModel(data: minAve)
                    let MaxAveModel = QualityModel(data: maxAve)
                    let MaxLess16Model = QualityModel(data: maxLess16)
                    let MaxMore24Model = QualityModel(data: maxMore24)
                    let Max18To22Model = QualityModel(data: max18To22)
                    let Min18To22Model = QualityModel(data: min18To22)
                    
                    let ModelArr = [MinAveModel, MaxAveModel, MaxLess16Model, MaxMore24Model, Max18To22Model, Min18To22Model]
                    
                    for i in 0..<ModelArr.count{
                        self.adaptButton(button: self.buttonArr[i], model: ModelArr[i], label: self.labelArr[i])
                    }
                    
                }else{
                    ToastView.instance.showToast(text: "暂无数据", pos: .Mid)
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Mid)
            }
        }
    }
    
    func adaptButton(button:UIButton, model:QualityModel, label:UILabel) {
        if (model.ID?.isEmpty)! {
            button.isEnabled = false
            button.setTitle("--", for: .normal)
            label.text = "--"
        }else{
        button.isEnabled = true
        button.tag = Int(model.ID!)!
        button.setTitle(model.Name, for: .normal)
        label.text = model.Ratio
        button.addTarget(self, action: #selector(toExchangers(_:)), for: .touchUpInside)
        }
    }
    
    @objc func toExchangers(_ sender:UIButton) {
        heatExchangerID = "\(sender.tag)"
        heatExchangerName = sender.currentTitle!
        let root = HeatExchangerTabBarController()
        root.selectedIndex = 4
        let nav = UINavigationController.init(rootViewController: root)
        self.present(nav, animated: true, completion: nil)
        print("\(heatExchangerName)")
    }
    
    func showPieChart(_ groupType:String, groupID:String, date:String) {
        let colorArr = [UIColor(red: 131/255.0, green: 229/255.0, blue: 161/255.0, alpha: CGFloat(1.0)),
                        UIColor(red: 244/255.0, green: 185/255.0, blue: 113/255.0, alpha: CGFloat(1.0)),
                        UIColor(red: 129/255.0, green: 236/255.0, blue: 234/255.0, alpha: CGFloat(1.0)),
                        UIColor(red: 247/255.0, green: 137/255.0, blue: 247/255.0, alpha: CGFloat(1.0)),
                        UIColor(red: 246/255.0, green: 249/255.0, blue: 140/255.0, alpha: CGFloat(1.0)),
                        UIColor(red: 249/255.0, green: 105/255.0, blue: 105/255.0, alpha: CGFloat(1.0))]
        
        let titleArr:[String] = ["<16℃", "16℃-18℃", "18℃-20℃", "20℃-22℃", "22℃-24℃", ">24℃"]
        var unitsSold:[Double] = []
        let url = GroupQuality + "/\(globalDate)"
        
        Alamofire.request(url).responseJSON { reponse in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let arr = json["ArrayData"].arrayValue

                    for i in 0..<arr.count {
                        let sold = arr[i]["Count"].stringValue
                        unitsSold.append((sold as NSString).doubleValue)
                    }
                    let color = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
                    Chart.setPieChart(self.pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
                }else{
                    ToastView.instance.showToast(text: "暂无数据", pos: .Mid)
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Mid)
            }

        }
        
        
//        let str = "{\"ArrayData\":[{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"<16\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"16~18\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"18~20\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"20~22\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"22~24\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\">24\"}]}"
//        let data = str.data(using: .utf8)
        
//        let json = JSON(data)
//        let arr = json["ArrayData"].arrayValue
//
//        for i in 0..<arr.count {
//            let sold = arr[i]["Count"].stringValue
//            unitsSold.append((sold as NSString).doubleValue)
//        }
//        let color = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
//
//        pieView.backgroundColor = color
//
//        Chart.setPieChart(pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
        
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
