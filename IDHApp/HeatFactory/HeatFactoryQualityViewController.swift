//
//  HeatFactoryQualityViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON

class HeatFactoryQualityViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pieView: PieChartView!
    
    @IBOutlet weak var less16Num: UILabel!
    @IBOutlet weak var l16To18Num: UILabel!
    @IBOutlet weak var l18To20Num: UILabel!
    @IBOutlet weak var l20To22Num: UILabel!
    @IBOutlet weak var l22To24Num: UILabel!
    @IBOutlet weak var more24Num: UILabel!
    
    @IBOutlet weak var less16Ratio: UILabel!
    @IBOutlet weak var l16To18Ratio: UILabel!
    @IBOutlet weak var l18To20Ratio: UILabel!
    @IBOutlet weak var l20To22Ratio: UILabel!
    @IBOutlet weak var l22To24Ratio: UILabel!
    @IBOutlet weak var more234Ratio: UILabel!
    var currentIndex = 0
    @IBOutlet weak var totalNum: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
//        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
//    @IBOutlet weak var totalNum: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        pieView.noDataText = "暂无数据"
        pieView.backgroundColor = #colorLiteral(red: 0.003921568627, green: 0.6745098039, blue: 0.6823529412, alpha: 1)
        Tools.setDataPickerDate(datePicker, checkedDate: globalDate)
//        setTitle()
        setUpNav()
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTransFer))
        
        let titleArr:[String] = ["<16℃", "16℃-18℃", "18℃-20℃", "20℃-22℃", "22℃-24℃", ">24℃"]
        let colorArr:[UIColor] = [UIColor(red: 131/255.0, green: 229/255.0, blue: 161/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 244/255.0, green: 185/255.0, blue: 113/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 129/255.0, green: 236/255.0, blue: 234/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 247/255.0, green: 137/255.0, blue: 247/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 246/255.0, green: 249/255.0, blue: 140/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 249/255.0, green: 105/255.0, blue: 105/255.0, alpha: CGFloat(1.0))]
        
        var unitsSold:[Double] = [1,1,1,1,1,1]
        
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
//        let str = "{\"ArrayData\":[{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"<16\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"16~18\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"18~20\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"20~22\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"22~24\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\">24\"}]}"
//        let adata = str.data(using: .utf8)
//
//        let json = JSON(adata)
//        let aarr = json["ArrayData"].arrayValue
//
//        for i in 0..<aarr.count {
//            let sold = aarr[i]["Count"].stringValue
//            unitsSold.append((sold as NSString).doubleValue)
//        }
        
        //                    let color = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
        //
        //                    pieView.backgroundColor = color
        //
        //                    Chart.setPieChart(pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
        
        Chart.setPieChart(self.pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
    }
    
//    @objc func toTrans() {
//        globalFromVC = .heatFactoryQuality
//        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
//        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
//        let nav = UINavigationController.init(rootViewController: trans)
//        self.present(nav, animated: true, completion: nil)
//    }
    
    
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
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toTransFer() {
        globalFromVC = .heatFactoryQuality
        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
        self.navigationController?.pushViewController(trans, animated: true)
    }
    
    func setTitle() {
        self.title = heatFactoryName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        globalDate = Tools.getSelectedDateString(sender)
        getData()
    }
    
    func getData(_ date:String = globalDate, factoryID:String = heatFactoryID) {
        
        let titleArr:[String] = ["<16℃", "16℃-18℃", "18℃-20℃", "20℃-22℃", "22℃-24℃", ">24℃"]
        let colorArr:[UIColor] = [UIColor(red: 131/255.0, green: 229/255.0, blue: 161/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 244/255.0, green: 185/255.0, blue: 113/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 129/255.0, green: 236/255.0, blue: 234/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 247/255.0, green: 137/255.0, blue: 247/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 246/255.0, green: 249/255.0, blue: 140/255.0, alpha: CGFloat(1.0)),
                                  UIColor(red: 249/255.0, green: 105/255.0, blue: 105/255.0, alpha: CGFloat(1.0))]
        
        var unitsSold:[Double] = [0,0,0,0,0,0]
        let url = FactoryHeatQuality + "\(factoryID)/\(date)"
        
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let value = reponse.result.value{
                    let data = JSON(value)
                    let model = QualityForFactory.init(data: data)
                    let arr = model.roomsData
                    self.totalNum.text = model.totalCount
                    for i in 0..<arr.count{
                        let room = arr[i]
                        var number:Double = 0
                        
                        if let num = room.Count{
                            number = (num as NSString).doubleValue
                        }else{
                            number = 0
                        }
                        
                        unitsSold.append(number)
                        
                        switch i{
                        case 0:
                            if (room.Count?.isEmpty)!{
                                self.less16Num.text = "--"
                                self.less16Ratio.text = "--"
                            }else{
                            self.less16Num.text = room.Count
                            self.less16Ratio.text = room.Percent
                            }
                        case 1:
                            if (room.Count?.isEmpty)!{
                                self.l16To18Num.text = "--"
                                self.l16To18Ratio.text = "--"
                            }else{
                                self.l16To18Num.text = room.Count
                                self.l16To18Ratio.text = room.Percent
                            }
                        case 2:
                            if (room.Count?.isEmpty)!{
                                self.l18To20Num.text = "--"
                                self.l18To20Ratio.text = "--"
                            }else{
                                self.l18To20Num.text = room.Count
                                self.l18To20Ratio.text = room.Percent
                            }
                        case 3:
                            if (room.Count?.isEmpty)!{
                                self.l20To22Num.text = "--"
                                self.l20To22Ratio.text = "--"
                            }else{
                                self.l20To22Num.text = room.Count
                                self.l20To22Ratio.text = room.Percent
                            }
                        case 4:
                            if (room.Count?.isEmpty)!{
                                self.l22To24Num.text = "--"
                                self.l22To24Ratio.text = "--"
                            }else{
                                self.l22To24Num.text = room.Count
                                self.l22To24Ratio.text = room.Percent
                            }
                        case 5:
                            if (room.Count?.isEmpty)!{
                                self.more24Num.text = "--"
                                self.more234Ratio.text = "--"
                            }else{
                                self.more24Num.text = room.Count
                                self.more234Ratio.text = room.Percent
                            }
                        default:
                            break
                        }
                    }
                    
                    
//                    let colorArr = [UIColor(red: 131/255.0, green: 229/255.0, blue: 161/255.0, alpha: CGFloat(1.0)),
//                                    UIColor(red: 244/255.0, green: 185/255.0, blue: 113/255.0, alpha: CGFloat(1.0)),
//                                    UIColor(red: 129/255.0, green: 236/255.0, blue: 234/255.0, alpha: CGFloat(1.0)),
//                                    UIColor(red: 247/255.0, green: 137/255.0, blue: 247/255.0, alpha: CGFloat(1.0)),
//                                    UIColor(red: 246/255.0, green: 249/255.0, blue: 140/255.0, alpha: CGFloat(1.0)),
//                                    UIColor(red: 249/255.0, green: 105/255.0, blue: 105/255.0, alpha: CGFloat(1.0))]
                    
//                    let titleArr:[String] = ["<16℃", "16℃-18℃", "18℃-20℃", "20℃-22℃", "22℃-24℃", ">24℃"]
//                    var unitsSold:[Double] = []
//                    let url = "http://219.145.102.165:6099/Analyze.svc/GetTemperatureChart/1/1/-1/-1/2017-11-7"
                    
                    //        Alamofire.request(url).responseJSON { reponse in
                    //            if reponse.result.isSuccess{
                    //                if let data = reponse.result.value{
                    //                    let json = JSON(data)
                    //                    let arr = json["ArrayData"].arrayValue
                    //
                    //                    for i in 0..<arr.count {
                    //                        let sold = arr[i]["Count"].stringValue
                    //                        unitsSold.append((sold as NSString).doubleValue)
                    //                    }
                    //                }
                    //            }
                    //
                    //        }
                    
                    //        Alamofire.request(<#T##url: URLConvertible##URLConvertible#>)
                    
                    
                    let str = "{\"ArrayData\":[{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"<16\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"16~18\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"18~20\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"20~22\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\"22~24\"},{\"Count\":\"1\",\"Percent\":\"\",\"Scope\":\">24\"}]}"
                    let adata = str.data(using: .utf8)
                    
                    let json = JSON(adata)
                    let aarr = json["ArrayData"].arrayValue
                    
                    for i in 0..<aarr.count {
                        let sold = aarr[i]["Count"].stringValue
                        unitsSold.append((sold as NSString).doubleValue)
                    }
//                    let color = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)
//
//                    pieView.backgroundColor = color
//
//                    Chart.setPieChart(pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
                    Chart.setPieChart(self.pieView, dataPoints: titleArr, values: unitsSold, legendColor: colorArr, showPie: true)
                }
            }else{
                
            }
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
