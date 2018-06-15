//
//  HeatFactoryEneryViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class HeatFactoryEneryViewController: UIViewController {

    @IBOutlet weak var heatSegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lineView: LineChartView!
    
    @IBOutlet weak var legend1: UILabel!
    @IBOutlet weak var legend2: UILabel!
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var lab3: UILabel!
    @IBOutlet weak var lab1Num: UILabel!
    @IBOutlet weak var lab2Num: UILabel!
    @IBOutlet weak var lab3Num: UILabel!
    @IBOutlet weak var lab1Unit: UILabel!
    @IBOutlet weak var lab2Unit: UILabel!
    @IBOutlet weak var lab3Unit: UILabel!
    @IBOutlet weak var temOutdoor: UILabel!
    var currentIndex = 0
    var heatLegend:[String] = ["当日热耗","当日热单耗"]
    var waterLegend:[String] = ["当日水耗","当日水单耗"]
    var elecLegend:[String] = ["当日电耗","当日电单耗"]
    var gasLegend:[String] = ["当日气耗","当日气单耗"]
    var coalLegend:[String] = ["当日煤耗","当日煤单耗"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
//        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(toBack))
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        lineView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
        self.parent?.navigationItem.title = "能耗分析"
        setLabels()
        setSegment()
        setUpNav()
        lineView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
//        //        self.parent?.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(toBack))
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
//        self.parent?.navigationItem.title = "能耗分析"
//        setLabels()
//        setSegment()
//        setUpNav()
//        self.view.setNeedsLayout()
        setUpNav()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setUpNav() {
        if heatFactorArr.count > 0 {
            //根据显示文本多少及字体大小动态计算标题的宽度
            let lblTitle = UILabel(frame: CGRect(x: 24, y: 0, width: 0, height: 20))
            lblTitle.text = heatFactoryName
            lblTitle.textColor = UIColor.white
            
            let boundingRect = (lblTitle.text! as NSString).boundingRect(with: CGSize(width: 0, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:lblTitle.font], context: nil).size
            let actualWidth = boundingRect.width
            
            //设置成实际宽度
            lblTitle.frame = CGRect(x: 24, y: 0, width: actualWidth, height: 20)
            let viewMiddle = UIView(frame: CGRect(x: 0,y: 0,width: 48 + actualWidth,height: 20))
            //根据当前热源厂所处数组的位置来判断上一个、下一个按钮是否灰显,先找出当前热源厂所在数组中的索引,再判断是否是首数或尾数
            let heatFacCount = heatFactorArr.count
            
            for index in 0..<heatFacCount{
                if heatFactorArr[index].ID == heatFactoryID{
                    currentIndex = Int(index)
                    break
                }
            }
            //上一个按钮
            let prevButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            
            prevButton.setImage(UIImage(named: "left"), for: .normal)
            prevButton.tag = 100
            prevButton.addTarget(self, action: #selector(findBrotherHeatFactory(_:)), for: .touchUpInside)
            if currentIndex != 0{
                prevButton.isHidden = false
            }
            else{
                prevButton.isHidden = true
            }
            
            //下一个按钮
            let nextButton = UIButton(frame: CGRect(x: 28+actualWidth, y: 0, width: 20, height: 20))
            nextButton.setImage(UIImage(named: "right"), for: UIControlState())
            nextButton.tag = 101
            
            nextButton.addTarget(self, action: #selector(findBrotherHeatFactory(_:)), for: .touchUpInside)
            if currentIndex != (heatFacCount-1){
                nextButton.isHidden = false
            }
            else{
                nextButton.isHidden = true
            }
            
            viewMiddle.addSubview(prevButton)
            viewMiddle.addSubview(lblTitle)
            viewMiddle.addSubview(nextButton)
            
            self.parent?.navigationItem.titleView = viewMiddle
            
            //重新显示数据
            getData()
        }
    }
    
    
    
    //查找上一个、下一个热源厂
    @objc func findBrotherHeatFactory(_ sender: UIButton){
        //上一个
        if sender.tag == 100{
            currentIndex -= 1
        }
        else{
            currentIndex += 1
        }
        
        //将全局热源厂ID重新赋值成新的值
        heatFactoryID = heatFactorArr[currentIndex].ID
        heatFactoryName = heatFactorArr[currentIndex].Name
        setUpNav()
    }
    
    func setSegment() {
        switch globalType {
        case .heat:
            heatSegment.selectedSegmentIndex = 0
        case .water:
            heatSegment.selectedSegmentIndex = 1
        case .elec:
            heatSegment.selectedSegmentIndex = 2
        case .gas:
            heatSegment.selectedSegmentIndex = 3
        case .coal:
            heatSegment.selectedSegmentIndex = 4
        }
    }
    
//    @objc func toTrans() {
//        globalFromVC = .heatFactoryEnergy
//        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
//        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
//        let nav = UINavigationController.init(rootViewController: trans)
//        self.parent?.present(nav, animated: true, completion: nil)
//    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        getData()
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            globalType = .heat
        case 1:
            globalType = .water
        case 2:
            globalType = .elec
        case 3:
            globalType = .gas
        case 4:
            globalType = .coal
        default:
            break
        }
        getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        
        setLabels()
        let url = FactoryEneryURL + "\(globalType.rawValue)/\(heatFactoryID)/\(globalDate)"
        let chartUrl = FactoryEneryChart + "\(globalType.rawValue)Chart/\(heatFactoryID)/\(globalDate)"
        print("\(url)--\(chartUrl)")
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let model = EneryConsumeModel.init(json)
                    if let data1 = model.consume{
                        self.lab1Num.text = data1.getLength(lengtn: 2)
                    }else{
                        self.lab1Num.text = "--"
                    }
                    if let data1 = model.unitConsume{
                        self.lab2Num.text = data1.getLength(lengtn: 2)
                    }else{
                        self.lab2Num.text = "--"
                    }
                    if let data1 = model.totalConsume{
                        self.lab3Num.text = data1.getLength(lengtn: 2)
                    }else{
                        self.lab3Num.text = "--"
                    }
                    if let data1 = model.outdoorTem, !data1.isEmpty{
                        self.temOutdoor.text = data1.getLength(lengtn: 2)
                    }else{
                        self.temOutdoor.text = "--"
                    }
                }
            }else{
            }
        }
        
        Alamofire.request(chartUrl).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let model = EneryChartModel.init(json)
                    var titles:[String] = []
                    var values:[[Double]] = []
                    var legendTitle:[String] = []
                    let arr1 = model.titles
                    let arr2 = model.dayValues
                    let arr3 = model.unitValues

                    
                    titles = arr1!
                    values.append(arr2!)
                    values.append(arr3!)
                    switch globalType{
                    case .heat:
                        legendTitle = self.heatLegend
                    case .water:
                        legendTitle = self.waterLegend
                    case .elec:
                        legendTitle = self.elecLegend
                    case .gas:
                        legendTitle = self.gasLegend
                    case .coal:
                        legendTitle = self.coalLegend
                    }
                    
                    Chart.setLineCharts(self.lineView, dataPoints: titles, values: values, colors: [UIColor.green, UIColor.yellow],legend:true, legengTitle:legendTitle)
                }
            }else{

            }
        }
    }
    
    func setLabels() {
        switch globalType {
        case .heat:
            legend1.text = "当日热耗"
            legend2.text = "当日热单耗"
            lab1.text = "当日热耗"
            lab2.text = "当日热单耗"
            lab3.text = "累计热耗"
            lab1Unit.text = unitEnum.heat.rawValue
            lab2Unit.text = unitEnum.heatUnit.rawValue
            lab3Unit.text = unitEnum.heat.rawValue
        case .water:
            legend1.text = "当日水耗"
            legend2.text = "当日水单耗"
            lab1.text = "当日水耗"
            lab2.text = "当日水单耗"
            lab3.text = "累计水耗"
            lab1Unit.text = unitEnum.water.rawValue
            lab2Unit.text = unitEnum.waterUnit.rawValue
            lab3Unit.text = unitEnum.water.rawValue
        case .elec:
            legend1.text = "当日电耗"
            legend2.text = "当日电单耗"
            lab1.text = "当日电耗"
            lab2.text = "当日电单耗"
            lab3.text = "累计电耗"
            lab1Unit.text = unitEnum.ele.rawValue
            lab2Unit.text = unitEnum.eleUnit.rawValue
            lab3Unit.text = unitEnum.ele.rawValue
        case .gas:
            legend1.text = "当日气耗"
            legend2.text = "当日气单耗"
            lab1.text = "当日气耗"
            lab2.text = "当日气单耗"
            lab3.text = "累计气耗"
            lab1Unit.text = unitEnum.gas.rawValue
            lab2Unit.text = unitEnum.gasUnit.rawValue
            lab3Unit.text = unitEnum.gas.rawValue
        case .coal:
            legend1.text = "当日煤耗"
            legend2.text = "当日煤单耗"
            lab1.text = "当日煤耗"
            lab2.text = "当日煤单耗"
            lab3.text = "累计煤耗"
            lab1Unit.text = unitEnum.water.rawValue
            lab2Unit.text = unitEnum.waterUnit.rawValue
            lab3Unit.text = unitEnum.water.rawValue
        }
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
