//
//  HeatFactoryTrendViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

enum TrendEnum:Int {
    case flux = 1
    case pressure
    case temperature
    case ValveGiven
}

class HeatFactoryTrendViewController: UIViewController {

    @IBOutlet weak var heatSegment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lineView: LineChartView!
    
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var lab1Num: UILabel!
    
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var lab2Num: UILabel!
    
    @IBOutlet weak var lab3: UILabel!
    @IBOutlet weak var lab3Num: UILabel!
    @IBOutlet weak var lab4: UILabel!
    @IBOutlet weak var lab4Num: UILabel!
    @IBOutlet weak var legend1: UILabel!
    @IBOutlet weak var legend2: UILabel!
    @IBOutlet weak var legend1View: UIView!
    @IBOutlet weak var legend2View: UIView!
    @IBOutlet weak var section2View: UIView!
    
    var type:TrendEnum = .temperature
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var currentIndex = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        self.lineView.backgroundColor = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
        
                setUpNav()
    }
    
//    @objc func toTrans() {
//        globalFromVC = .heatFactoryTrend
//        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
//        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
//        let nav = UINavigationController.init(rootViewController: trans)
//        self.present(nav, animated: true, completion: nil)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lineView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
        lineView.noDataText = "暂无数据"
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
        setLabel()
        setUpNav()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setSegment() {
        switch globalTrendType {
        case .temperature:
            heatSegment.selectedSegmentIndex = 0
        case .pressure:
            heatSegment.selectedSegmentIndex = 1
        case .flux:
            heatSegment.selectedSegmentIndex = 2
        case .ValveGiven:
            heatSegment.selectedSegmentIndex = 0
        }
    }
    
    func setUpNav() {
        //
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
    
//    func setNav() {
//        self.parent?.navigationItem.titleView = TitleForChange()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        var urlType = ""
        
        switch type {
        case .temperature:
            urlType = "Temp"
        case .pressure:
            urlType = "Press"
        case .flux:
            urlType = "Flow"
        case .ValveGiven:
            urlType = "ValveGiven"
        }
        let url = FactoryTrendURL + urlType + "Trend/\(heatFactoryID)/\(globalDate)"
        
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                    let data = JSON(value)
                    switch self.type {
                    case .temperature:
                        let model = TrendHeatModel.init(data)
                        self.setData(model: model)
                    case .pressure:
                        let model = TrendPressureModel.init(data)
                        self.setData(model: model)
                    case .flux:
                        let model = TrendFluxModel.init(data)
                        self.setData(model: model)
                    case .ValveGiven:
                        break
                    }
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Bottom)
            }
        }
    }
    
    func setData(model:Any) {
        var values:[[Double]] = []
        var title:[String] = []
        var colors:[UIColor] = []
        
        switch type {
        case .temperature:
            let mod = model as! TrendHeatModel
                lab1Num.text = mod.avgOutTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            lab2Num.text = mod.avgRetTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            lab3Num.text = mod.maxOutTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            lab4Num.text = mod.outdoorTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            if let charts = mod.chartData{
            var outArr:[Double] = []
            var retArr:[Double] = []
            for temp in charts{
                outArr.append(temp.outTem!)
                retArr.append(temp.retTem!)
                title.append(temp.date!)
            }
            colors.append(UIColor.yellow)
            colors.append(UIColor.green)
            values.append(outArr)
            values.append(retArr)
            Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
            
        case .pressure:
            colors.append(UIColor.yellow)
            colors.append(UIColor.green)
            var outArr:[Double] = []
            var retArr:[Double] = []
            let mod = model as! TrendPressureModel
            lab1Num.text = mod.maxOutP!.getLength(lengtn: 2) + unitEnum.press.rawValue
            lab2Num.text = mod.minOutP!.getLength(lengtn: 2) + unitEnum.press.rawValue
            if let charts = mod.chartData{
            for temp in charts{
                outArr.append(temp.outPre!)
                retArr.append(temp.retPre!)
                title.append(temp.date!)
            }
            values.append(outArr)
            values.append(retArr)
            Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
            
        case .flux:
            let mod = model as! TrendFluxModel
            lab1Num.text = mod.maxInsF!.getLength(lengtn: 2) + unitEnum.flux.rawValue
            lab2Num.text = mod.minInsF!.getLength(lengtn: 2) + unitEnum.flux.rawValue
            colors.append(UIColor.yellow)
            if let charts = mod.chartData{
            var outArr:[Double] = []
            for temp in charts{
                outArr.append(temp.insFlux!)
                title.append(temp.date!)
            }
            values.append(outArr)
            Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
        case .ValveGiven:
            break
        }
    }
    
    func setLabel() {
        switch type {
        case .temperature:
            legend1.text = "供水温度"
            legend2.text = "回水温度"
            legend2View.isHidden = false
            legend2.isHidden = false
            lab1.text = "平均供水温度"
            lab2.text = "平均回水温度"
            section2View.isHidden = false
            lab3.text = "最高供水温度"
            lab4.text = "平均室外温度"
        case .pressure:
            legend1.text = "供水压力"
            legend2.text = "回水压力"
            legend2View.isHidden = false
            legend2.isHidden = false
            lab1.text = "最高供水压力"
            lab2.text = "最低供水压力"
            section2View.isHidden = true
        case .flux:
            legend1.text = "瞬时流量"
            legend2View.isHidden = true
            legend2.isHidden = true
            lab1.text = "最大流量"
            lab2.text = "最小流量"
            section2View.isHidden = true
        case .ValveGiven:
            break
        }
    }

    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        getData()
    }
    @IBAction func changeType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            type = .temperature
            globalTrendType = .temperature
        case 1:
            type = .pressure
            globalTrendType = .pressure
        case 2:
            type = .flux
            globalTrendType = .flux
        default:
            break
        }
        setLabel()
        getData()
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
