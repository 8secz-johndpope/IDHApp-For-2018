//
//  EneryAnalyseViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/18.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EneryAnalyseViewController: UIViewController {
    
    @IBOutlet weak var heatConsume: UILabel!
    @IBOutlet weak var heatUnitConsume: UILabel!
    @IBOutlet weak var heatTotalConsume: UILabel!
    @IBOutlet weak var heatRatioConsume: UILabel!
    
    @IBOutlet weak var waterConsume: UILabel!
    @IBOutlet weak var waterUnitConsume: UILabel!
    @IBOutlet weak var waterTotalConsume: UILabel!
    @IBOutlet weak var waterRatioConsume: UILabel!
    
    @IBOutlet weak var elecConsume: UILabel!
    @IBOutlet weak var elecUnitConsume: UILabel!
    @IBOutlet weak var elecTotalConsume: UILabel!
    @IBOutlet weak var elecRatioConsume: UILabel!
    
    @IBOutlet weak var gasConsume: UILabel!
    @IBOutlet weak var gasUnitConsume: UILabel!
    @IBOutlet weak var gasTotalConsume: UILabel!
    @IBOutlet weak var gasRatioConsume: UILabel!
    
    @IBOutlet weak var coalConsume: UILabel!
    @IBOutlet weak var coalUnitConsume: UILabel!
    @IBOutlet weak var coalTotalConsume: UILabel!
    @IBOutlet weak var coalRatioConsume: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var labelArr:[(UILabel,UILabel,UILabel,UILabel)] = []
    var unitArr:[(String, String, String, String)] = []
    
//    var groupingType = "-1"
//    var groupID = "-1"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "quality_ico_home"), style: .plain, target: self, action: #selector(ToHome))
        self.title = grouping?.GroupingName
        
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
        
        heatTotalConsume.adjustsFontSizeToFitWidth = true
        waterTotalConsume.adjustsFontSizeToFitWidth = true
        elecTotalConsume.adjustsFontSizeToFitWidth = true
        gasTotalConsume.adjustsFontSizeToFitWidth = true
        coalTotalConsume.adjustsFontSizeToFitWidth = true
        heatUnitConsume.adjustsFontSizeToFitWidth = true
        waterUnitConsume.adjustsFontSizeToFitWidth = true
        elecUnitConsume.adjustsFontSizeToFitWidth = true
        gasUnitConsume.adjustsFontSizeToFitWidth = true
        coalUnitConsume.adjustsFontSizeToFitWidth = true
        
        self.labelArr = [(heatConsume, heatUnitConsume, heatTotalConsume, heatRatioConsume),(waterConsume, waterUnitConsume, waterTotalConsume, waterRatioConsume), (elecConsume, elecUnitConsume, elecTotalConsume,elecRatioConsume),(gasConsume, gasUnitConsume, gasTotalConsume, gasRatioConsume), (coalConsume, coalUnitConsume, coalTotalConsume, coalRatioConsume)]
        
        self.unitArr = [("(GJ)", "(GJ/万㎡.天)", "(GJ)", "%"), ("(T)", "(T/万㎡.天)", "(T)", "%"), ("(kwh)", "(kwh/万㎡.天)", "(kwh)", "%"), ("(m³)", "(m³/万㎡.天)", "(m³)", "%"), ("(T)", "(T/万㎡.天)", "(T)", "%")]
        
        getData(date: Tools.getSelectedDateString(datePicker))
        setNav()
        datePicker.addTarget(self, action: #selector(changeDate(_:)), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func changeDate(_ sender:UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        print(GroupANA)
        print(globalDate)
        getData((grouping?.GroupingType)!, id: (grouping?.GroupingID)!, date: globalDate)
    }
    
    func setNav() {
        let reveal = self.revealViewController()
//        reveal?.panGestureRecognizer()
//        reveal?.tapGestureRecognizer()
        
        let globalMenu = reveal?.rightViewController as! GlobalMenuViewController
        
        globalMenu.menuCallback = {[unowned self] group in
            print("\(group.GroupingName)")
            grouping = group
            self.changeTitle()
            self.getData((grouping?.GroupingType)!, id: (grouping?.GroupingID)!, date: globalDate)
        }
        
        self.title = globalGrouping?.GroupingName
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "menu"), style: .plain, target: reveal, action: #selector(reveal?.rightRevealToggle(_:)))
    }
    
    func changeTitle() {
        self.navigationItem.title = grouping?.GroupingName
    }
    
    @objc func ToHome() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func JumpTo(_ type:ConsumeType) {
        globalType = type
        
        if !(grouping?.GroupingType == "group") {
//            let root = UIStoryboard(name: "TabbarStoryboard", bundle: nil).instantiateViewController(withIdentifier: "facbar") as! UITabBarController
//            root.selectedIndex = 2
            let root = HeatFactoryTabBarControllerViewController()
            root.selectedIndex = 2
            
            let nav = UINavigationController.init(rootViewController: root)
            self.present(nav, animated: true, completion: nil)
            //            self.parent?.present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            print("factory")
        }else{
            ToTypeIndex(type)
        }
    }
    
    @IBAction func heatJump(_ sender: UITapGestureRecognizer) {
        JumpTo(.heat)
    }
    @IBAction func WaterJump(_ sender: UITapGestureRecognizer) {
        JumpTo(.water)
    }
    @IBAction func eleJump(_ sender: UITapGestureRecognizer) {
        JumpTo(.elec)
    }
    @IBAction func gasJump(_ sender: UITapGestureRecognizer) {
        JumpTo(.gas)
    }
    @IBAction func coalJump(_ sender: UITapGestureRecognizer) {
        JumpTo(.coal)
    }
    
    
    func ToTypeIndex(_ type:ConsumeType) {
        let main = UIStoryboard.init(name: "EneryAnalyseStoryBoard", bundle: nil)
        let home = main.instantiateViewController(withIdentifier: "typeIndex") as! TypeindexViewController
        home.type = type
        let nav = UINavigationController.init(rootViewController: home)
        
        self.present(nav, animated: true, completion: nil)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func getData(_ type:String = "-1", id:String = "-1",date:String){
        let url = GroupANA + "\(type)/\(id)/\(date)"
        print(url)
        ToastView.instance.showLoadingDlg()
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let heat = json["Heat"]
                    let water = json["Water"]
                    let elec = json["Electricity"]
                    let gas = json["Gas"]
                    let coal = json["Coal"]
                    let modelArr = [heat,water,elec,gas,coal]
                    ToastView.instance.hide()
                    for i in 0..<self.labelArr.count{
                        let model = AnalyseModel(modelArr[i])
                        self.setLabels(model, labels: self.labelArr[i], units: self.unitArr[i])
                    }
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Bottom)
            }
        }
    }
    
    func setLabels(_ model:AnalyseModel, labels:(UILabel, UILabel, UILabel, UILabel), units:(String, String, String, String)) {
        if let consume = model.consume {
            let data1 = NSMutableAttributedString(string: String(format: "%.2f", (consume as NSString).doubleValue), attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
            data1.append(NSAttributedString(string: units.0))
            let data2 = NSMutableAttributedString(string: String(format: "%.2f", (model.unitConsume! as NSString).doubleValue), attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
            data2.append(NSAttributedString(string: units.1))
            let data3 = NSMutableAttributedString(string: String(format: "%.2f", (model.totalConsume! as NSString).doubleValue), attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
            data3.append(NSAttributedString(string: units.2))
            let data4 = NSMutableAttributedString(string: String(format: "%.2f", (model.ratioConsume! as NSString).doubleValue), attributes: [NSAttributedStringKey.foregroundColor:UIColor.red])
            data4.append(NSAttributedString(string: units.3))
            
            labels.0.attributedText = data1
            labels.1.attributedText = data2
            labels.2.attributedText = data3
            labels.3.attributedText = data4
        }else{
            labels.0.text = "--" + units.0
            labels.1.text = "--" + units.1
            labels.2.text = "--" + units.2
            labels.3.text = "--" + units.3
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
