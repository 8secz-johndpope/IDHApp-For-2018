//
//  TypeindexViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/5/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

enum ConsumeType:String {
    case heat = "Heat"
    case water = "Water"
    case elec = "Electricity"
    case gas = "Gas"
    case coal = "Coal"
}

class TypeindexViewController: UIViewController {
    
    var type:ConsumeType = .heat
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var heatBar: UIBarButtonItem!
    @IBOutlet weak var waterBar: UIBarButtonItem!
    @IBOutlet weak var eleBar: UIBarButtonItem!
    @IBOutlet weak var gasBar: UIBarButtonItem!
    @IBOutlet weak var coalBar: UIBarButtonItem!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    @IBOutlet weak var detailsView: UIView!
    var heatView: HeatViewDeatils!
    var water_eleView: Water_EleView!
    var gas_coalView:Gas_CoalView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = grouping?.GroupingName
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        lineChart.noDataText = "暂无数据"
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toTrans() {
        globalFromVC = .energyTypeIndex
        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
        let nav = UINavigationController.init(rootViewController: trans)
        self.present(nav, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(trans, animated: true)
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(datePicker)
        buttonTapped(type)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(detailsView.bounds)
        let width = detailsView.bounds.width
        let height = detailsView.bounds.height
        if heatView != nil {
            
        }else{
            heatView = HeatViewDeatils(frame: CGRect.init(x: 0, y: 0, width: detailsView.bounds.width, height: detailsView.bounds.height))
            detailsView.addSubview(heatView)
        }
        
        if water_eleView != nil {
        }else{
            water_eleView = Water_EleView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: height))
            detailsView.addSubview(water_eleView)
        }
        
        if gas_coalView != nil {
            
        }else{
            gas_coalView = Gas_CoalView(frame: CGRect.init(x: 0, y: 0, width: detailsView.bounds.width, height: detailsView.bounds.height))
            detailsView.addSubview(gas_coalView)
        }
        
        lineChart.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
        heatView.closure = {[unowned self] type,model,bool in
            self.handleIt(type, model: model, toFactory: bool!)
        }
        water_eleView.clousre = {[unowned self] type,model,bool in
            self.handleIt(type, model: model, toFactory: bool!)
        }
        gas_coalView.call = {[unowned self] type,model,bool in
            self.handleIt(type, model: model, toFactory: bool!)
        }
        
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
        adaptViews()
        buttonTapped(type)
    }
    
    
    func handleIt(_ type:ConsumeType,model:stationModel?,toFactory:Bool) {
        
        if toFactory {
//            let facTabBar = HeatFactoryTabBarControllerViewController()
//            if let mod = model{
//                heatFactoryID = mod.ID!
//                heatFactoryName = mod.Name!
//            }
//            facTabBar.selectedIndex = 2
//            self.present(facTabBar, animated: true, completion: nil)
            
//            let root = UIStoryboard(name: "TabbarStoryboard", bundle: nil).instantiateViewController(withIdentifier: "facbar") as! UITabBarController
            
            if let mod = model{
                heatFactoryName = mod.Name!
                heatFactoryID = mod.ID!
            }else{
                heatFactoryName = (heatFactorArr.first?.Name)!
                heatFactoryID = (heatFactorArr.first?.ID)!
            }
            
            let root = HeatFactoryTabBarControllerViewController()
            root.selectedIndex = 2
            let nav = UINavigationController.init(rootViewController: root)
            self.present(nav, animated: true, completion: nil)
        }else{
            if let mod = model{
                heatExchangerID = mod.ID!
                heatExchangerName = mod.Name!
            
            }else{
                heatExchangerName = (exchangersArr.first?.Name)!
                heatExchangerID = (exchangersArr.first?.ID)!
            }
            
//            let root = UIStoryboard(name: "ExchangerTabBar", bundle: nil).instantiateViewController(withIdentifier: "exchanger") as! UITabBarController
            
            
//            let root = HeatExchangerTabBarController()
            
            let root = HeatExchangerTabBarController.instance
            root.selectedIndex = 2
            let nav = UINavigationController.init(rootViewController: root)
//            self.navigationController?.pushViewController(root, animated: true)
            self.present(nav, animated: true, completion: nil)
            
//            let excTabBar = HeatExchangerTabBarController()
//            excTabBar.selectedIndex = 1
//            let nav = UINavigationController.init(rootViewController: excTabBar)
//            self.present(nav, animated: true, completion: nil)
        }
 
    }
    
    func adaptViews() {
        switch type {
        case .heat:
            water_eleView.isHidden = true
            gas_coalView.isHidden = true
            heatView.isHidden = false
        case .water, .elec:
            water_eleView.isHidden = false
            heatView.isHidden = true
            gas_coalView.isHidden = true
        default:
            gas_coalView.isHidden = false
            heatView.isHidden = true
            water_eleView.isHidden = true
        }
    }
    
    @IBAction func EleTap(_ sender: UIBarButtonItem) {
        type = .elec
        globalType = .elec
        buttonTapped(type)
    }
    @IBAction func GasTap(_ sender: UIBarButtonItem) {
        type = .gas
        globalType = .gas
        buttonTapped(type)
    }
    @IBAction func CoalTap(_ sender: UIBarButtonItem) {
        type = .coal
        globalType = .coal
        buttonTapped(type)
    }
    
    @IBAction func WaterTap(_ sender: UIBarButtonItem) {
        type = .water
        globalType = .water
        buttonTapped(type)
    }
    @IBAction func HeatTap(_ sender: UIBarButtonItem) {
        type = .heat
        globalType = .heat
        buttonTapped(type)
        
    }
    
    func buttonTapped(_ type: ConsumeType) {
        heatBar.tintColor = UIColor.white
        waterBar.tintColor = UIColor.white
        eleBar.tintColor = UIColor.white
        gasBar.tintColor = UIColor.white
        coalBar.tintColor = UIColor.white
        let color = UIColor(red: CGFloat(0)/255.0, green: CGFloat(178)/255.0, blue: CGFloat(178)/255.0, alpha: CGFloat(1.0))
        
        adaptViews()
        switch type {
        case .heat:
            heatBar.tintColor = color
            handleHeatView()
        case .water:
            waterBar.tintColor = color
            handleWaterElec()
        case .elec:
            eleBar.tintColor = color
            handleWaterElec()
        case .gas:
            handleGasCoal()
            gasBar.tintColor = color
        case .coal:
            handleGasCoal()
            coalBar.tintColor = color
        }
    }
    
    func handleGasCoal() {
        gas_coalView.setUpViews(type)
        requestData()
        setLineChart([UIColor.green])
    }
    
    func handleWaterElec() {
        water_eleView.setUpViews(type)
        
        requestData()
        setLineChart([UIColor.green, UIColor.yellow])
    }
    
    func handleHeatView() {
        let arr = [UIColor.red,UIColor.green]
//        let url = "http://219.145.102.165:6099/Analyze.svc/GetHeatSum/1/1/-1/-1/2017-11-7"
        requestData()
        setLineChart(arr)
//        heatView.setUpView()
//        heatView.maxFactory.addTarget(self, action: #selector(), for: .touchUpInside)
//        heatView.maxExchanger.addTarget(self, action: #selector(), for: .touchUpInside)
//        heatView.minExchanger.addTarget(self, action: #selector(), for: .touchUpInside)
    }
    
    func ToFactory(_ sender:UIButton) {
        
    }
    
    
    func setLineChart(_ color:[UIColor]) {
        
        let url = GroupAnaLineURL + "Get\(type.rawValue)SumChart/\(groupid)/\(role_id)/\(globalGrouping?.GroupingType ?? "-1")/\(globalGrouping?.GroupingID ?? "-1")/" + globalDate
        
        print(url)
        
        Alamofire.request(url).responseJSON { (reponse) in
            var title:[String] = []
            var values:[[Double]] = []
            var facValue:[Double] = []
            var exchValue:[Double] = []
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    
                    if let fac = json["HeatFactory\(self.type.rawValue)"].array{
                        
                        for item in fac{
                            
                            let str = item["DateTime"].stringValue
                            let a = str.components(separatedBy: " ").first?.components(separatedBy: "/")
                            
                            let string = a![1] + "/" + a![2]
                            
                            title.append(string)
                            facValue.append(item["Value"].doubleValue)
                        }
                        values.append(facValue)
                    }
                    if let exc = json["HeatExchange\(self.type.rawValue)"].array{
                        for item in exc{
                            exchValue.append(item["Value"].doubleValue)
                        }
                        values.append(exchValue)
                    }
                    Chart.setLineCharts(self.lineChart, dataPoints: title, values: values, colors: color)
                }
            }else{
                
            }
        }
    }
    
    
    func buttonFunc(_ factory:HeatFactoryModel?, exchanger:HeatExchangeModel?) {
        if let fac = factory {
            //jump to factory
            
        }else if let exc = exchanger{
            //jump to exchanger
        }else{
            return
        }
    }
    
    
    func requestData() {
        let u = GroupAnaLineURL + "Get\(type.rawValue)Sum/\(groupid)/\(role_id)/\(globalGrouping?.GroupingType ?? "-1")/\(globalGrouping?.GroupingID ?? "-1")/" + globalDate
        print("data----\(u)")
        Alamofire.request(u).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let type = self.type
                    
                    switch type{
                    case .heat:
                        self.heatView.setUpView(json)
                    case .water,.elec:
                        self.water_eleView.setUpData(json, type: type)
                    case .gas,.coal:
                        self.gas_coalView.setData(type, data: json)
                    }
                }
            }else{
                
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
