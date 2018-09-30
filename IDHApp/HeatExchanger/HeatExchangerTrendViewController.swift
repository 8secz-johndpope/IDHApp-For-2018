//
//  HeatExchangerTrendViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON


class HeatExchangerTrendViewController: UIViewController {
    let CellIdentifier = "TrendCell"
    @IBOutlet weak var chartView: PYZoomEchartsView!
    
    @IBOutlet weak var collection: UICollectionView!
//    @IBOutlet weak var lineView: LineChartView!
//    @IBOutlet weak var lab1: UILabel!
//    @IBOutlet weak var lab2: UILabel!
//    @IBOutlet weak var lab1Data: UILabel!
//    @IBOutlet weak var lab2Data: UILabel!
//    @IBOutlet weak var second2View: UIView!
//    @IBOutlet weak var s2lab1: UILabel!
//    @IBOutlet weak var s2lab2: UILabel!
//    @IBOutlet weak var s2lab1Data: UILabel!
//    @IBOutlet weak var s2lab2Data: UILabel!
    var currentIndex = 0
    var type:TrendEnum = .temperature
    var echartModel:EchartsModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        self.lineView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
        
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
//        setLabel()
        setUpNav()
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        setSegment()
        chartView.backgroundColor = #colorLiteral(red: 0.8242912889, green: 0.9481970072, blue: 0.9456497431, alpha: 1)
        
        self.collection.register(UINib(nibName:"TrendCollectionViewCell",bundle:nil), forCellWithReuseIdentifier: CellIdentifier)
        self.collection.delegate = self
        self.collection.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpNav()
    }
    
    func setSegment() {
        switch globalTrendType {
        case .temperature:
            changeType.selectedSegmentIndex = 0
        case .pressure:
            changeType.selectedSegmentIndex = 1
        case .flux:
            changeType.selectedSegmentIndex = 2
        case .ValveGiven:
            changeType.selectedSegmentIndex = 3
        }
    }
//
    @objc func toTrans() {
        globalFromVC = .heatExchangerTrend
        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
        let nav = UINavigationController.init(rootViewController: trans)
        self.present(nav, animated: true, completion: nil)
    }
    
    func setUpNav() {
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
    
    @IBOutlet weak var changeType: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeTypeBySeg(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            type = .temperature
        case 1:
            type = .pressure
        case 2:
            type = .flux
        default:
            type = .ValveGiven
        }
        globalTrendType = type
//        setLabel()
        getData()
        
    }
    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        getData()
    }
    /*
    func setLabel() {
        switch type {
        case .temperature:
//            legend1.text = "供水温度"
//            legend2.text = "回水温度"
//            legend2View.isHidden = false
//            legend2.isHidden = false
            lab1.text = "平均供水温度"
            lab2.text = "平均回水温度"
            second2View.isHidden = false
            s2lab1.text = "最高供水温度"
            s2lab2.text = "平均室外温度"
        case .pressure:
//            legend1.text = "供水压力"
//            legend2.text = "回水压力"
//            legend2View.isHidden = false
//            legend2.isHidden = false
            lab1.text = "最高供水压力"
            lab2.text = "最低供水压力"
            second2View.isHidden = true
        case .flux:
//            legend1.text = "瞬时流量"
//            legend2View.isHidden = true
//            legend2.isHidden = true
            lab1.text = "最大流量"
            lab2.text = "最小流量"
            second2View.isHidden = true
        case .ValveGiven:
            //            legend1.text = "瞬时流量"
            //            legend2View.isHidden = true
            //            legend2.isHidden = true
            lab1.text = "最大阀位"
            lab2.text = "最小阀位"
            second2View.isHidden = true
        }
        getData()
    }
 */
    
    
    func getData() {
        ToastView.instance.showLoadingDlg()
        
        //API fixed by echarts demo  change type string --> int value
        // * temperature -> 3   flux -> 1  perssure -> 2 valveGiven -> 4
        //2018-9-25
        
//        var urlType = ""
//        switch type {
//        case .temperature:
//            urlType = "Temp"
//        case .pressure:
//            urlType = "Press"
//        case .flux:
//            urlType = "Flow"
//        case .ValveGiven:
//            urlType = "ValveGiven"
//        }
        
        let url = ExchangerTrendURL + "\(heatExchangerID)" + "/\(globalDate)/\(type.rawValue)"
//        let url = ExchangerTrendURL + urlType + "Trend/\(heatExchangerID)/\(globalDate)"
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                    let data = JSON(value)
//                    let data = JSON.init(parseJSON: str)
                    self.echartModel = EchartsModel.init(data: data)
                    ToastView.instance.hide()
/*
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
                        let model = TrendValveGivenModel.init(data)
                        self.setData(model: model)
                    }
 */
                    self.chartView.setOption(ChartsOption.standardLineOption(chartDatas: self.echartModel!))
                    self.chartView.layoutMargins = UIEdgeInsetsMake(5, 5, 10, 5)
//                    self.chartView
                    self.chartView.loadEcharts()
                    self.collection.reloadData()
                }else{
                    ToastView.instance.showToast(text: "暂无数据", pos: .Bottom)
                }
            }else{
                ToastView.instance.showToast(text: "请求失败", pos: .Bottom)
            }
        }
    }
    
    /*
    func setData(model:Any) {
        var values:[[Double]] = []
        var title:[String] = []
        var colors:[UIColor] = []
        
        switch type {
        case .temperature:
            let mod = model as! TrendHeatModel
            lab1Data.text = mod.avgOutTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            lab2Data.text = mod.avgRetTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            s2lab1Data.text = mod.maxOutTem!.getLength(lengtn: 2) + unitEnum.tem.rawValue
            s2lab2Data.text = mod.outdoorTem!.getLength(lengtn: 1) + unitEnum.tem.rawValue
            
            if let charts = mod.chartData{
                var outArr:[Double] = []
                var retArr:[Double] = []
                for temp in charts{
                    outArr.append(temp.outTem!)
                    retArr.append(temp.retTem!)
                    title.append(temp.dataTime!)
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
            if let charts = mod.chartData{
                for temp in charts{
                    outArr.append(temp.outPre!)
                    retArr.append(temp.retPre!)
                    title.append(temp.dataTime!)
                }
                values.append(outArr)
                values.append(retArr)
                lab1Data.text = mod.maxOutP!.getLength(lengtn: 2) + unitEnum.press.rawValue
                lab2Data.text = mod.minOutP!.getLength(lengtn: 2) + unitEnum.press.rawValue
                Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
            
        case .flux:
            let mod = model as! TrendFluxModel
            lab1Data.text = mod.maxInsF!.getLength(lengtn: 2) + unitEnum.flux.rawValue
            lab2Data.text = mod.minInsF!.getLength(lengtn: 2) + unitEnum.flux.rawValue
            colors.append(UIColor.yellow)
            if let charts = mod.chartData{
                var outArr:[Double] = []
                for temp in charts{
                    outArr.append(temp.insFlux!)
                    title.append(temp.dataTime!)
                }
                values.append(outArr)
                Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
        case .ValveGiven:
            let mod = model as! TrendValveGivenModel
            lab1Data.text = mod.maxValve!.getLength(lengtn: 1) + unitEnum.valve.rawValue
            lab2Data.text = mod.minValve!.getLength(lengtn: 1) + unitEnum.valve.rawValue
            colors.append(UIColor.yellow)
            if let charts = mod.chartData{
                var outArr:[Double] = []
                for temp in charts{
                    outArr.append(temp.valve!)
                    title.append(temp.time!)
                }
                values.append(outArr)
                Chart.setLineCharts(self.lineView, dataPoints: title, values: values, circleRadius: 2, digit: 1, colors: colors)
            }
        }
    }
 
 */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension HeatExchangerTrendViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ec = self.echartModel {
            return ec.parmesList.count
        }
        return 0
//        return (self.echartModel?.parmesList.count)!
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as! TrendCollectionViewCell
        if let ec = self.echartModel {
            cell.setItemValue(data: (ec.parmesList[indexPath.item]))
        }
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension HeatExchangerTrendViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        return CGSize.init(width: width/2 - 10, height: 30)
    }
}

