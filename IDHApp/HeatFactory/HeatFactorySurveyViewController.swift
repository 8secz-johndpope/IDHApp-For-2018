//
//  HeatFactorySurveyViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class HeatFactorySurveyViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var principal: UILabel!
    @IBOutlet weak var planLoad: UILabel!
    @IBOutlet weak var heatArea: UILabel!
    @IBOutlet weak var amount: UILabel!
    
//    var titleView:TitleView!
//    var viewc:TitleForChange!
    
    var currentIndex:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        
        self.parent?.navigationItem.title = "概况"
        setUpNav()
        showMap(address: "123", name: "测试")
        
//                self.parent?.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
    }
    
//    @objc func toTrans() {
//        globalFromVC = .heatFactorySurvey
//        let transSB = UIStoryboard(name: "Transfer", bundle: nil)
//        let trans = transSB.instantiateViewController(withIdentifier: "transfer")
//        let nav = UINavigationController.init(rootViewController: trans)
//        self.present(nav, animated: true, completion: nil)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight)
        print("\(self.view.frame.width)")
        print("\(UIScreen.main.bounds.width)")
        
        self.view.layoutIfNeeded()
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getData() {
        let url = FactorySurvey + "\(heatFactoryID)"
        Alamofire.request(url).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                if let data = reponse.result.value{
                    let json = JSON(data)
                    let model = SurveyModel.init(json)
                    self.address.text = model.Address
                    self.phone.text = model.Telephone
                    self.principal.text = model.Leader
                    self.planLoad.text = model.PlannedHeatLoad
                    self.heatArea.text = model.HeatArea
                    self.amount.text = model.HexCount! + "个"
                    
                    self.showMap(model.Longitude!, lati: model.Latitude!, address: model.Address, name: model.Name)
                }
            }
        }
    }
    
    func showMap(_ long:String="108.905383", lati:String="34.248835",address:String?,name:String?) {
        if !long.isEmpty && !lati.isEmpty {
            mapView.mapType = .standard
            //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
            let latDelta = 0.05
            let longDelta = 0.05
            let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
            //使用自定义位置
            let center:CLLocation = CLLocation(latitude: Double(lati)!, longitude: Double(long)!)
            let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate,
                                                                      span: currentLocationSpan)
            mapView.setRegion(currentRegion, animated: true)
            let arr = mapView.annotations
        
            mapView.removeAnnotations(arr)
            let point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: (lati as NSString).doubleValue, longitude: (long as NSString).doubleValue)
            point.title = name
            point.subtitle = address
            mapView.addAnnotation(point)
//            mapView.showsUserLocation = true
//            mapView.setCenter(mapView.userLocation.coordinate, animated: true)
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
