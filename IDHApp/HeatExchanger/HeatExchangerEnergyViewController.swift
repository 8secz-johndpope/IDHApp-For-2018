//
//  HeatExchangerEnergyViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class HeatExchangerEnergyViewController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lineView: LineChartView!
    @IBOutlet weak var consumeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var totallabel: UILabel!
    @IBOutlet weak var consume: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var consumeUn: UILabel!
    @IBOutlet weak var unitUn: UILabel!
    @IBOutlet weak var totalUn: UILabel!
    @IBOutlet weak var temForOutdoor: UILabel!
    var currentIndex = 0
    var heatLegend:[String] = ["当日热耗", "当日单耗"]
    var waterLegend:[String] = ["当日水耗", "当日单耗"]
    var elecLegend:[String] = ["当日电耗", "当日单耗"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSegment()
        setLabels()
        setUpNav()
        datePicker.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
        self.lineView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        // Do any additional setup after loading the view.
    }
    
    @objc func toTrans() {
        globalFromVC = .heatExchangerEnergy
        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
        let nav = UINavigationController.init(rootViewController: trans)
        self.present(nav, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpNav()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
    }
    
    func setUpNav() {
        //
        if exchangersArr.count > 0 {
            //根据显示文本多少及字体大小动态计算标题的宽度
            let lblTitle = UILabel(frame: CGRect(x: 24, y: 0, width: 0, height: 20))
            lblTitle.text = heatExchangerName
            lblTitle.textColor = UIColor.white
            
            let boundingRect = (lblTitle.text! as NSString).boundingRect(with: CGSize(width: 0, height: 0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:lblTitle.font], context: nil).size
            let actualWidth = boundingRect.width
            
            //设置成实际宽度
            lblTitle.frame = CGRect(x: 24, y: 0, width: actualWidth, height: 20)
            let viewMiddle = UIView(frame: CGRect(x: 0,y: 0,width: 48 + actualWidth,height: 20))
            //根据当前热源厂所处数组的位置来判断上一个、下一个按钮是否灰显,先找出当前热源厂所在数组中的索引,再判断是否是首数或尾数
            let heatFacCount = exchangersArr.count
            
            for index in 0..<heatFacCount{
                if exchangersArr[index].ID == heatExchangerID{
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
        heatExchangerID = exchangersArr[currentIndex].ID
        heatExchangerName = exchangersArr[currentIndex].Name
        setUpNav()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            globalType = .heat
        case 1:
            globalType = .water
        case 2:
            globalType = .elec
        default:
            break
        }
        getData()
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        getData()
    }
    
    func getData() {
        setLabels()
        let url = ExchangerEneryURL + "\(globalType.rawValue)/\(heatExchangerID)/\(globalDate)"
        let chartUrl = ExchangerEneryChart + "\(globalType.rawValue)Chart/\(heatExchangerID)/\(globalDate)"
        
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let model = ExchangerEnergyModel.init(json)
                    self.consume.text = model.consume?.getLength(lengtn: 2)
                    self.unit.text = model.unitConsume?.getLength(lengtn: 2)
                    self.total.text = model.totalConsume?.getLength(lengtn: 2)
                    self.temForOutdoor.text = model.outdoorTem?.getLength(lengtn: 1)
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
                    default:
                        break
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
//            legend1.text = "当日热耗"
//            legend2.text = "当日热单耗"
            consumeLabel.text = "当日热耗"
            unitLabel.text = "当日热单耗"
            totallabel.text = "累计热耗"
            consumeUn.text = unitEnum.heat.rawValue
            unitUn.text = unitEnum.heatUnit.rawValue
            totalUn.text = unitEnum.heat.rawValue
        case .water:
//            legend1.text = "当日水耗"
//            legend2.text = "当日水单耗"
            consumeLabel.text = "当日水耗"
            unitLabel.text = "当日水单耗"
            totallabel.text = "累计水耗"
            consumeUn.text = unitEnum.water.rawValue
            unitUn.text = unitEnum.waterUnit.rawValue
            totalUn.text = unitEnum.water.rawValue
        case .elec:
//            legend1.text = "当日电耗"
//            legend2.text = "当日电单耗"
            consumeLabel.text = "当日电耗"
            unitLabel.text = "当日电单耗"
            totallabel.text = "累计电耗"
            consumeUn.text = unitEnum.ele.rawValue
            unitUn.text = unitEnum.eleUnit.rawValue
            totalUn.text = unitEnum.ele.rawValue
        default:
            break
        }
    }
    
    func setSegment() {
        switch globalType {
        case .heat:
            segment.selectedSegmentIndex = 0
        case .water:
            segment.selectedSegmentIndex = 1
        case .elec:
            segment.selectedSegmentIndex = 2
        default:
            break
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
