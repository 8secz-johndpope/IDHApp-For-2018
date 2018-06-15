//
//  MonitorViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/29.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import RealmSwift
import KissXML

class ExchangerMixMonitorViewController: UIViewController {
//    var imageView = UIImageView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var Home: UIButton!
    @IBOutlet weak var backView: UIView!
    var newModel:HeatExchangeModel?
//    var factorModel:HeatFactoryModel?
    
    
    var labelArr: [LabelModel] = []
    var stationLabelArr: [(station: String, modles:[LabelModel])] = []
    var stationIDArr: [String] = []
    var groupModels:[exchangerModel] = []
    
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let dateView = UILabel()
    var lastPoint: CGPoint?
    var maxScale: CGFloat = 1.5
    var minScale: CGFloat = 0.5

    @IBOutlet weak var trendButton: UIButton!
    //    var preButton: UIButton?
//    var nextButton: UIButton?
    var timer: Timer!
    var dataDate:Date = Date()
    var timeStamp: String = ""
    
    var pointValue = CGPoint.zero
    var scaleValue: CGFloat = 1.0
    
    var originalRatio:CGFloat = 0
    var activityIndicator = UIActivityIndicatorView()
    
    //deprecated
    var textArr: [UILabel] = []
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageActivity = UIActivityIndicatorView()
    
    //    var testLabel = UILabel()
//    @IBOutlet weak var titleName: UILabel!
//    @IBOutlet weak var Home: UIButton!
    @IBAction func toHome(_ sender: UIButton) {
        let home = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = home.instantiateViewController(withIdentifier: "home")

        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func toTrend(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
    @IBAction func toEnery(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func toSurvey(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @IBAction func toQUality(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 4
    }
    
//    @IBAction func toTab(_ sender: UIButton) {
//        let tag = sender.tag
//        switch tag {
//        case 0:
//            return
//        case 1:
//            self.tabBarController?.selectedIndex = 1
//        case 2:
//            self.tabBarController?.selectedIndex = 2
//        case 3:
//            self.tabBarController?.selectedIndex = 3
//        case 4:
//            self.tabBarController?.selectedIndex = 4
//        default:
//            break
//        }
//    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.parent?.navigationController?.isNavigationBarHidden = true
//        self.tabBarController?.tabBar.isHidden = true
//        appDelegate.landscape = true
//        let value = UIInterfaceOrientation.landscapeRight.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//        self.view.frame = CGRect.init(x: 0, y: 0, width: globalHeight, height: globalWidth)
//        self.view.layoutSubviews()
//        Tools.setMonitors(heatExchangerID)
//        changeExchanger()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appDelegate.landscape = true
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.parent?.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.frame = CGRect.init(x: 0, y: 0, width: globalHeight, height: globalWidth)
        if factoryMonitor{
            Tools.setMonitors(heatFactoryID, isFactor: true)
            changeFactory()
        }else{
            Tools.setMonitors(heatExchangerID)
            changeExchanger()
        }
    }
    
    
    @IBAction func changeExc(_ sender: UIButton) {
        changeModel(sender)
    }
    
    @IBAction func backTo(_ sender: UIButton) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let value = UIInterfaceOrientation.landscapeRight.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//        self.view.frame = CGRect.init(x: 0, y: 0, width: globalHeight, height: globalWidth)
        self.view.backgroundColor = UIColor.white
        
        setUpViews()
        if factoryMonitor {
            if facModels.count > 1 {
                if current == 0 {
                    preButton?.isHidden = true
                    nextButton?.isHidden = false
                }else if current == models.count - 1 {
                    preButton?.isHidden = false
                    nextButton?.isHidden = true
                }else{
                    preButton?.isHidden = false
                    nextButton?.isHidden = false
                }
            }else{
                preButton?.isHidden = true
                nextButton?.isHidden = true
            }
        }else{
            if models.count > 1 {
                if current == 0 {
                    preButton?.isHidden = true
                    nextButton?.isHidden = false
                }else if current == models.count - 1 {
                    preButton?.isHidden = false
                    nextButton?.isHidden = true
                }else{
                    preButton?.isHidden = false
                    nextButton?.isHidden = false
                }
            }else{
                preButton?.isHidden = true
                nextButton?.isHidden = true
            }
        }
//        if models.count > 1 {
//            if current == 0 {
//                preButton?.isHidden = true
//                nextButton?.isHidden = false
//            }else if current == models.count - 1 {
//                preButton?.isHidden = false
//                nextButton?.isHidden = true
//            }else{
//                preButton?.isHidden = false
//                nextButton?.isHidden = false
//            }
//        }else{
//            preButton?.isHidden = true
//            nextButton?.isHidden = true
//        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//        Tools.setMonitors(heatExchangerID)
//        changeExchanger()
//    }
    
    @objc func startUpdate() {
        //        Toast.shareInstance().showView(self.view, title: "数据更新中...")
        requestValues(true)
    }
    
    func setUpViews() {
//        let editorView = LayoutableView()
//        editorView.layout = WeightsLayout.init(horizontal: false)
//        editorView.layout?.weights = [1,1,1,4,1,1,1]
//        editorView.frame = CGRect.init(x: 0, y: 0, width: 48, height: self.view.bounds.width)
//        editorView.backgroundColor = UIColor.gray
//
//        let home = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
//        home.setImage(#imageLiteral(resourceName: "quality_ico_home"), for: .normal)
//        home.addTarget(self, action: #selector(toHome), for: .touchUpInside)
//
//        if AppProvider.instance.appVersion == .homs03 || AppProvider.instance.appVersion == .homsOther {
//            home.isHidden = true
//        }
//
//        let back = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - 48, width: 48, height: 48))
//        back.setImage(#imageLiteral(resourceName: "back_factory"), for: .normal)
//        back.addTarget(self, action: #selector(backTo), for: .touchUpInside)
//        preButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
//        preButton?.setImage(#imageLiteral(resourceName: "next"), for: .normal)
//        preButton?.tag = 100
//        preButton?.addTarget(self, action: #selector(changeModel(_:)), for: .touchUpInside)
//
//        nextButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
//        nextButton?.setImage(#imageLiteral(resourceName: "pre"), for: .normal)
//        nextButton?.tag = 200
//        nextButton?.addTarget(self, action: #selector(changeModel(_:)), for: .touchUpInside)
//
//        titleName.numberOfLines = 0
//        titleName.lineBreakMode = .byCharWrapping
//        titleName.textAlignment = .center
//        var newName = ""
//        //        if models.isEmpty {
//        //            for char in (model?.area_name)!{
//        //                newName.append(char)
//        //                newName.append("\n")
//        //            }
//        //            preButton?.isHidden = true
//        //            nextButton?.isHidden = true
//        //        }else{
//        //            if models.count == 1 {
//        //                preButton?.isHidden = true
//        //                nextButton?.isHidden = true
//        //            }else{
//        //                if current == 0 {
//        //                    preButton?.isHidden = true
//        //                }else if current == (models.count) - 1{
//        //                    nextButton?.isHidden = true
//        //                }
//        //            }
//        //            for char in models[current].Name {
//        //                newName.append(char)
//        //                newName.append("\n")
//        //            }
//        //        }
        
        titleName.text = model?.area_name
        
        
//        titleName.textColor = UIColor.white
//        editorView.addSubview(home)
//        editorView.addSubview(UIView())
//        editorView.addSubview(preButton!)
//        editorView.addSubview(titleName)
//        editorView.addSubview(nextButton!)
//        editorView.addSubview(UIView())
//        editorView.addSubview(back)
        
//        imageView.frame = CGRect(x: 48, y: 0, width: self.view.bounds.height, height: self.view.bounds.width)
//
        
//        trendButton.addTarget(self, action: #selector(toTrend(_:)), for: .touchUpInside)
        let gesture = UIPinchGestureRecognizer.init(target: self, action: #selector(zoomImage(_:)))
        
        imageView.addGestureRecognizer(gesture)
        imageView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(move)))
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
//
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        activityIndicator.center.x = self.view.center.y
        activityIndicator.center.y = self.view.center.x
        activityIndicator.color = UIColor.gray
//
        imageActivity = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        imageActivity.center.x = self.view.center.y
        imageActivity.center.y = self.view.center.x
//
//        let backView = LayoutableView()
//        backView.layout = WeightsLayout.init(horizontal: false)
//        backView.layout?.weights = [1,1,1,1,1]
//        backView.frame = CGRect.init(x: self.view.bounds.height-48, y: 0, width: 48, height: self.view.bounds.width)
//        let tAtt = ["监控画面", "运行趋势", "能耗", "概况", "供热质量"]
//        let IArr = [#imageLiteral(resourceName: "heat_btn_look_select"), #imageLiteral(resourceName: "heat_btn_trend_unselect"), #imageLiteral(resourceName: "heat_btn_power_unselect"), #imageLiteral(resourceName: "heat_btn_survey_unselect"), #imageLiteral(resourceName: "heat_btn_qu_unselect")]
//
//        for index in 0..<4 {
//            let btn = LayoutableView()
//            btn.layout = WeightsLayout.init(horizontal: false)
//            btn.layout?.weights = [2,1]
//            let image = UIImageView.init()
//            image.image = IArr[index]
//            let label = UILabel()
//            label.textAlignment = .center
//            label.text = tAtt[index]
//            btn.addSubview(image)
//            btn.addSubview(label)
//            btn.tag = index
//            btn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(toTab(_:))))
//            backView.addSubview(btn)
//
//        }
//        backView.backgroundColor = UIColor.darkGray
//
        AppProvider.instance.setVersion()
        if AppProvider.instance.appVersion == .homs03 && AppProvider.instance.appVersion == .homsOther{
            backView.isHidden = true
            Home.isHidden = true
        }
//        self.view.addSubview(backView)
//        self.view.addSubview(imageView)
//        self.view.addSubview(editorView)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(imageActivity)
        self.view.bringSubview(toFront: activityIndicator)
//        loadDatas()
        //        start()
    }
    
    func start() {
        if let model = model {
            loadDatas()
        }else{
            print("no data model")
        }
    }
    
    func changeFactory() {
        if timer != nil {
            timer.invalidate()
        }
        imageView.transform = CGAffineTransform.identity
        //        changeButtonState()
        
        var name = ""
        if facModels.isEmpty {
            name = (model?.area_name)!
            AppProvider.instance.setVersion()
            if AppProvider.instance.appVersion == .idhWithHoms{
                let realm = try! Realm()
                if let model = realm.objects(heatModel.self).filter("idh_id = '\(model?.idh_id)' AND type = '换热站'").first{
                }else{
                    Toast.shareInstance().showView(self.imageView, title: "暂无数据", landscape: true)
                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                    return
                }
            }
        }else{
            let exchanger = facModels[current]
            name = exchanger.Name
            //
            heatFactoryID = exchanger.ID
            heatFactoryName = exchanger.Name
            //
            model = getFacModel(exchanger)
            //
        }
        var newName = ""
        
        for char in name {
            newName.append(char)
            newName.append("\n")
        }
        
        titleName.text = heatFactoryName
        
        labelArr.removeAll()
        stationLabelArr.removeAll()
        stationIDArr.removeAll()
        loadDatas()
    }
    
    func changeExchanger() {
        if timer != nil {
            timer.invalidate()
        }
        imageView.transform = CGAffineTransform.identity
        //        changeButtonState()

        var name = ""
        if models.isEmpty {
            name = (model?.area_name)!
            AppProvider.instance.setVersion()
            if AppProvider.instance.appVersion == .idhWithHoms{
                let realm = try! Realm()
                if let model = realm.objects(heatModel.self).filter("idh_id = '\(model?.idh_id)' AND type = '换热站'").first{
                }else{
                    Toast.shareInstance().showView(self.imageView, title: "暂无数据", landscape: true)
                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                    return
                }
            }
        }else{
            let exchanger = models[current]
            name = exchanger.Name
            //
            heatExchangerID = exchanger.ID
            heatExchangerName = exchanger.Name
            //
            model = getModel(exchanger)
            //
        }
        var newName = ""
        
        for char in name {
            newName.append(char)
            newName.append("\n")
        }
        
        titleName.text = heatExchangerName
        
        labelArr.removeAll()
        stationLabelArr.removeAll()
        stationIDArr.removeAll()
        loadDatas()
    }
    
    func getModel(_ exchange: HeatExchangeModel) -> heatModel? {
        let realm = try! Realm()
        let id = exchange.ID
        if let model = realm.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first{
            return model
        }else{
            Toast.shareInstance().showView(self.view, title: "暂无数据")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            for view in imageView.subviews{
                view.removeFromSuperview()
            }
            return nil
        }
    }
    
    
    //    func getExchangerModel(_ index:IndexPath) -> heatModel? {
    //        realm = try! Realm()
    //        if let fac = self.factor {
    //            let model:exchangerModel?
    //            if fac.isHaveGroup{
    //                model = fac.groups[index.section].exchangers[index.item]
    //            }else{
    //                model = fac.heatExchangers[index.item]
    //            }
    //            if let id = model?.ID{
    //                let modelRealm = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
    //                return modelRealm
    //            }
    //        }
    //        return nil
    //    }
    
    func getFacModel(_ exchange: HeatFactoryModel) -> heatModel? {
        let realm = try! Realm()
        let id = exchange.ID
        if let model = realm.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '热源厂'").first{
            return model
        }else{
            Toast.shareInstance().showView(self.view, title: "暂无数据")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            for view in imageView.subviews{
                view.removeFromSuperview()
            }
            return nil
        }
    }
    
    
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    
    @objc func changeModel(_ sender: UIButton) {

        if factoryMonitor {
            if current == 0 && current == (facModels.count) - 1{
                return
            }
            if sender.tag == 100 {
                current -= 1
            } else if sender.tag == 200{
                current += 1
            }
            changeButtonState()
        }else{
            if current == 0 && current == (models.count) - 1{
                return
            }
            if sender.tag == 100 {
                current -= 1
            } else if sender.tag == 200{
                current += 1
            }
            changeButtonState()
        }
        
        
//        if current == 0 && current == (arr.count) - 1{
//            return
//        }
//        if sender.tag == 100 {
//            current -= 1
//        } else if sender.tag == 200{
//            current += 1
//        }
//        changeButtonState()
    }
    
    func changeButtonState() {
//        if models.count > 1 {
//            if current == 0 {
//                preButton?.isHidden = true
//                nextButton?.isHidden = false
//            }else if current == models.count - 1 {
//                preButton?.isHidden = false
//                nextButton?.isHidden = true
//            }else{
//                preButton?.isHidden = false
//                nextButton?.isHidden = false
//            }
//        }else{
//            preButton?.isHidden = true
//            nextButton?.isHidden = true
//        }
        if factoryMonitor {
            if facModels.count > 1 {
                if current == 0 {
                    preButton?.isHidden = true
                    nextButton?.isHidden = false
                }else if current == facModels.count - 1 {
                    preButton?.isHidden = false
                    nextButton?.isHidden = true
                }else{
                    preButton?.isHidden = false
                    nextButton?.isHidden = false
                }
            }else{
                preButton?.isHidden = true
                nextButton?.isHidden = true
            }
            changeFactory()
        }else{
            if models.count > 1 {
                if current == 0 {
                    preButton?.isHidden = true
                    nextButton?.isHidden = false
                }else if current == models.count - 1 {
                    preButton?.isHidden = false
                    nextButton?.isHidden = true
                }else{
                    preButton?.isHidden = false
                    nextButton?.isHidden = false
                }
            }else{
                preButton?.isHidden = true
                nextButton?.isHidden = true
            }
            changeExchanger()
        }
    }
    
    @objc func zoomImage(_ sender: UIPinchGestureRecognizer) {
        
        adjustAnchorPoint(for: sender)
        if sender.state == .began {
            scaleValue = sender.scale
        }
        
        if sender.state == .began || sender.state == .changed {
            
            let currentScale: CGFloat = sender.view!.layer.value(forKeyPath: "transform.scale") as! CGFloat
            let kMaxScale: CGFloat = 2.0
            let kMinScale: CGFloat = 1.0
            var newScale = 1 - (scaleValue - sender.scale)
            newScale = min(newScale, kMaxScale / currentScale)
            newScale = max(newScale, kMinScale / currentScale)
            sender.view?.transform = sender.view!.transform.scaledBy(x: newScale, y: newScale)
            scaleValue = sender.scale
        }
        
    }
    
    private func adjustAnchorPoint(for gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let piece = gestureRecognizer.view!
            let locationInView = gestureRecognizer.location(in: piece)
            let locationInSuperview = gestureRecognizer.location(in: piece.superview!)
            piece.layer.anchorPoint = CGPoint(x: CGFloat(locationInView.x / piece.bounds.size.width), y: CGFloat(locationInView.y / piece.bounds.size.height))
            piece.center = locationInSuperview
        }
    }
    
    @objc func move(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in:self.view)
        let cropViewPosition: CGPoint? = imageView.center
        var recognizerFrame = imageView.frame
        recognizerFrame.origin.x += translation.x
        recognizerFrame.origin.y += translation.y
        imageView.center = cropViewPosition!
        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        sender.setTranslation(CGPoint(x: CGFloat(0), y: CGFloat(0)), in: self.view)
    }
    

    
    func requestImage(_ path: String) {
        imageActivity.startAnimating()
        let str = MonitorURL+"?action=get&path=\(path)"
        let url = URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
            self.imageActivity.stopAnimating()
        }
    }
    
    
    func requestImageFor03(_ path: String, _ doc: DDXMLDocument) {
        imageActivity.startAnimating()
        let str = MonitorURL+"?action=get&path=\(path)"
        let url = URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
            self.imageActivity.stopAnimating()
            if AppProvider.instance.appVersion == .homs03{
                let dataStrs = doc.rootElement()?.elements(forName: "datastr")
                if let dataW = doc.rootElement()?.attribute(forName: "width")?.stringValue, let dataH = doc.rootElement()?.attribute(forName: "height")?.stringValue{
                    let H = (dataH as NSString).floatValue
                    let W = (dataW as NSString).floatValue
                    self.originalRatio = CGFloat(H/W)
                }
                for data in dataStrs!{
                    let model = LabelModel()
                    if let location = data.elements(forName: "location").first{
                        let x = location.attribute(forName: "x")?.stringValue
                        let y = location.attribute(forName: "y")?.stringValue
                        let width = location.attribute(forName: "width")?.stringValue
                        let height = location.attribute(forName: "height")?.stringValue
                        let fixedW = location.attribute(forName: "fixedparentwidth")?.stringValue
                        let fixedH = location.attribute(forName: "fixedparentheight")?.stringValue
                        model.x = (x! as NSString).floatValue * 0.01
                        model.y = (y! as NSString).floatValue * 0.01
                        model.width = (width! as NSString).floatValue * 0.01
                        model.height = (height! as NSString).floatValue * 0.01
                    }
                    if let object = data.elements(forName: "object").first{
                        let text = try! object.nodes(forXPath: "text").first?.stringValue
                        if let objs = object.elements(forName: "text").first{
                            let foreColor = objs.attribute(forName: "forecolor")?.stringValue
                            let valueColor = objs.attribute(forName: "datacolor")?.stringValue
                            let valuetrans = objs.attribute(forName: "valuetrans")?.stringValue
                            let specialUnit = objs.attribute(forName: "specialunit")?.stringValue
                            model.specialunit = specialUnit!
                            model.text = text!
                            model.foreColor = self.strToColor(foreColor!)
                            model.dataColor = self.strToColor(valueColor!)
                            model.valueTrans = valuetrans!
                        }
                        if let values = object.elements(forName: "values").first{
                            let format = values.attribute(forName: "format")?.stringValue
                            model.format = format!
                        }
                    }
                    if let dataSource = data.elements(forName: "datasource").first{
                        
                        if let stationid = dataSource.attribute(forName: "stationid")?.stringValue{
                            model.station_id = stationid
                        }
                        let tagid = dataSource.attribute(forName: "datatagid")?.stringValue
                        let unit = dataSource.attribute(forName: "unit")?.stringValue
                        model.tag_id = tagid!
                        model.unit = unit!
                    }
                    if !self.stationIDArr.contains(model.station_id) && !model.station_id.isEmpty{
                        self.stationIDArr.append(model.station_id)
                    }
                    self.labelArr.append(model)
                }
                self.archiverModels(self.labelArr)
                self.requestValues()
            }
        }
    }
    
    @objc func loadDatas() {
        if let heat = model {
            let realm = try! Realm()
            if !realm.objects(heatModel.self).filter("parent_id == \(heat.area_id)").isEmpty{
                Alamofire.request(MonitorURL, method: .get, parameters: ["action": "get", "path": heat.path]).responseData(completionHandler: { reponse in
                    if reponse.result.isSuccess{
                        
                        let doc = try! DDXMLDocument.init(data: reponse.value!, options: 0)
                        if let back = doc.rootElement()?.elements(forName: "background").first{
                            if let image = back.attribute(forName: "filename")?.stringValue{
                                var arr = heat.path.components(separatedBy: "/")
                                arr.removeLast()
                                arr.append(image)
                                let path = arr.joined(separator: "/")
                                self.requestImage(path)
                            }
                        }
                        let objects = try! doc.nodes(forXPath: "//objects/object") as! [DDXMLElement]
                        for temp in objects{
                            let model = LabelModel()
                            model.text = (temp.attribute(forName: "name")?.stringValue)!
                            if let location = temp.elements(forName: "location").first{
                                if let x = location.attribute(forName: "x")?.stringValue{
                                    model.x = percentToFloat(x)
                                }
                                if let y = location.attribute(forName: "y")?.stringValue{
                                    model.y = percentToFloat(y)
                                }
                                if let width = location.attribute(forName: "width")?.stringValue{
                                    model.width = percentToFloat(width)
                                }
                                if let height = location.attribute(forName: "height")?.stringValue{
                                    model.height = percentToFloat(height)
                                }
                            }
                            self.labelArr.append(model)
                        }
                    }
                    self.drawLabels(true)
                })
            }else{
                activityIndicator.startAnimating()
                print("\(heat.path)-----")
                
                Alamofire.request(MonitorURL, method: .get, parameters: ["action": "get", "path": heat.path]).responseData(completionHandler: { reponse in
                    if reponse.result.isSuccess{
                        let doc = try! DDXMLDocument.init(data: reponse.value!, options: 0)
                        if AppProvider.instance.appVersion == .homs03{
                            var arr = heat.path.components(separatedBy: "/")
                            arr.removeLast()
                            if let hob = doc.rootElement()?.elements(forName: "hob").first{
                                if let name = hob.attribute(forName: "name")?.stringValue{
                                    arr.append("\(name)/\(name).xml")
                                    let str = arr.joined(separator: "/")
                                    self.loadDataFor03(str)
                                }
                            }
                        }else{
                            if let back = doc.rootElement()?.elements(forName: "background").first{
                                if let image = back.attribute(forName: "filename")?.stringValue{
                                    var arr = heat.path.components(separatedBy: "/")
                                    arr.removeLast()
                                    arr.append(image)
                                    let path = arr.joined(separator: "/")
                                    self.requestImage(path)
                                    self.activityIndicator.stopAnimating()
                                }
                            }
                            
                            if let dataW = doc.rootElement()?.attribute(forName: "width")?.stringValue, let dataH = doc.rootElement()?.attribute(forName: "height")?.stringValue{
                                let H = (dataH as NSString).floatValue
                                let W = (dataW as NSString).floatValue
                                self.originalRatio = CGFloat(H/W)
                            }else{
                                self.originalRatio = CGFloat(1028/853)
                            }
                            if let dataStrs = doc.rootElement()?.elements(forName: "datastr"){
                                if dataStrs.isEmpty{
                                    self.activityIndicator.stopAnimating()
                                    Toast.shareInstance().showView(self.view, title: "暂无数据")
                                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                }else{
                                    
                                    for data in dataStrs{
                                        let model = LabelModel()
                                        if let location = data.elements(forName: "location").first{
                                            let x = location.attribute(forName: "x")?.stringValue
                                            let y = location.attribute(forName: "y")?.stringValue
                                            let width = location.attribute(forName: "width")?.stringValue
                                            let height = location.attribute(forName: "height")?.stringValue
                                            let fixedW = location.attribute(forName: "fixedparentwidth")?.stringValue
                                            let fixedH = location.attribute(forName: "fixedparentheight")?.stringValue
                                            self.originalRatio = CGFloat((fixedH! as NSString).floatValue/(fixedW! as NSString).floatValue)
                                            model.x = (x! as NSString).floatValue * 0.01
                                            model.y = (y! as NSString).floatValue * 0.01
                                            model.width = (width! as NSString).floatValue * 0.01
                                            model.height = (height! as NSString).floatValue * 0.01
                                        }
                                        if let object = data.elements(forName: "object").first{
                                            let text = try! object.nodes(forXPath: "text").first?.stringValue
                                            if let objs = object.elements(forName: "text").first{
                                                let foreColor = objs.attribute(forName: "forecolor")?.stringValue
                                                let valueColor = objs.attribute(forName: "datacolor")?.stringValue
                                                let valuetrans = objs.attribute(forName: "valuetrans")?.stringValue
                                                let specialUnit = objs.attribute(forName: "specialunit")?.stringValue
                                                model.specialunit = specialUnit!
                                                model.text = text!
                                                model.foreColor = self.strToColor(foreColor!)
                                                model.dataColor = self.strToColor(valueColor!)
                                                model.valueTrans = valuetrans!
                                            }
                                            if let values = object.elements(forName: "values").first{
                                                let format = values.attribute(forName: "format")?.stringValue
                                                model.format = format!
                                            }
                                        }
                                        if let dataSource = data.elements(forName: "datasource").first{
                                            if let stationid = dataSource.attribute(forName: "stationid")?.stringValue{
                                                model.station_id = stationid
                                            }
                                            let tagid = dataSource.attribute(forName: "datatagid")?.stringValue
                                            let unit = dataSource.attribute(forName: "unit")?.stringValue
                                            model.tag_id = tagid!
                                            model.unit = unit!
                                        }
                                        //                      存起来所有的ID
                                        if !self.stationIDArr.contains(model.station_id) && !model.station_id.isEmpty{
                                            self.stationIDArr.append(model.station_id)
                                            //                                            print("\(stationIDArr)")
                                        }
                                        self.labelArr.append(model)
                                    }
                                }
                            }
                            self.archiverModels(self.labelArr)
                            self.requestValues()
                        }
                    }else{
                        Toast.shareInstance().showView(self.view, title: "请求数据失败")
                        Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                        print("error")
                    }
                })
            }
        }else{
            Toast.shareInstance().showView(self.view, title: "暂无数据")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }
    }
    
    
    func loadDataFor03(_ path: String) {
        Alamofire.request(MonitorURL, method: .get, parameters: ["action": "get", "path": path]).responseData { reponse in
            if reponse.result.isSuccess{
                let doc = try! DDXMLDocument.init(data: reponse.value!, options: 0)
                if let back = doc.rootElement()?.elements(forName: "background").first{
                    if let image = back.attribute(forName: "filename")?.stringValue{
                        var arr = path.components(separatedBy: "/")
                        arr.removeLast()
                        arr.append(image)
                        let path = arr.joined(separator: "/")
                        self.requestImageFor03(path, doc)
                        self.activityIndicator.stopAnimating()
                    }
                }
                
                //                    let dataStrs = doc.rootElement()?.elements(forName: "datastr")
                //                    if let dataW = doc.rootElement()?.attribute(forName: "width")?.stringValue, let dataH = doc.rootElement()?.attribute(forName: "height")?.stringValue{
                //                        let H = (dataH as NSString).floatValue
                //                        let W = (dataW as NSString).floatValue
                //                        self.originalRatio = CGFloat(H/W)
                //                    }
                //
                //                    for data in dataStrs!{
                //                        let model = LabelModel()
                //                        if let location = data.elements(forName: "location").first{
                //                            let x = location.attribute(forName: "x")?.stringValue
                //                            let y = location.attribute(forName: "y")?.stringValue
                //                            let width = location.attribute(forName: "width")?.stringValue
                //                            let height = location.attribute(forName: "height")?.stringValue
                //                            let fixedW = location.attribute(forName: "fixedparentwidth")?.stringValue
                //                            let fixedH = location.attribute(forName: "fixedparentheight")?.stringValue
                ////                            self.originalRatio = CGFloat((fixedH! as NSString).floatValue/(fixedW! as NSString).floatValue)
                //                            model.x = (x! as NSString).floatValue * 0.01
                //                            model.y = (y! as NSString).floatValue * 0.01
                //                            model.width = (width! as NSString).floatValue * 0.01
                //                            model.height = (height! as NSString).floatValue * 0.01
                //                        }
                //                        if let object = data.elements(forName: "object").first{
                //                            let text = try! object.nodes(forXPath: "text").first?.stringValue
                //                            if let objs = object.elements(forName: "text").first{
                //                                let foreColor = objs.attribute(forName: "forecolor")?.stringValue
                //                                let valueColor = objs.attribute(forName: "datacolor")?.stringValue
                //                                let valuetrans = objs.attribute(forName: "valuetrans")?.stringValue
                //                                let specialUnit = objs.attribute(forName: "specialunit")?.stringValue
                //                                model.specialunit = specialUnit!
                //                                model.text = text!
                //                                model.foreColor = self.strToColor(foreColor!)
                //                                model.dataColor = self.strToColor(valueColor!)
                //                                model.valueTrans = valuetrans!
                //                            }
                //                            if let values = object.elements(forName: "values").first{
                //                                let format = values.attribute(forName: "format")?.stringValue
                //                                model.format = format!
                //                            }
                //                        }
                //                        if let dataSource = data.elements(forName: "datasource").first{
                //
                //                            if let stationid = dataSource.attribute(forName: "stationid")?.stringValue{
                //                                model.station_id = stationid
                //                            }
                //                            let tagid = dataSource.attribute(forName: "datatagid")?.stringValue
                //                            let unit = dataSource.attribute(forName: "unit")?.stringValue
                //                            model.tag_id = tagid!
                //                            model.unit = unit!
                //                        }
                //                        if !self.stationIDArr.contains(model.station_id){
                //                            self.stationIDArr.append(model.station_id)
                //                        }
                //                        self.labelArr.append(model)
                //                    }
                //                    self.archiverModels(self.labelArr)
                //                    self.requestValues()
            }else{
                print("\(path)---error")
            }
        }
    }
    
    func archiverModels(_ arr:[LabelModel]){
        self.stationLabelArr.removeAll()
        for temp in self.stationIDArr{
            var arr1: [LabelModel] = []
            for model in self.labelArr{
                if temp == model.station_id{
                    arr1.append(model)
                }
            }
            self.stationLabelArr.append((temp,arr1))
        }
    }
    
    func requestValues(_ update: Bool = false) {
        var count = 1
        
        
        for index in 0..<stationLabelArr.count {
            let station = stationLabelArr[index].station
            print("\(station)")
            
            //请求
            Alamofire.request(StationURL, method: .get, parameters: ["stationid": station]).responseData(completionHandler: { reponse in
                if reponse.result.isSuccess{
                    let doc = try! DDXMLDocument.init(data: reponse.result.value!, options: 0)
                    let data = doc.rootElement()?.elements(forName: "data")
                    for tem in data!{
                        if let tag = tem.elements(forName: "id").first?.stringValue{
                            for model in self.stationLabelArr[index].modles{
                                if tag == model.tag_id{
                                    model.value = (tem.elements(forName: "value").first?.stringValue)!
                                    print("\(model.station_id)---\(model.tag_id)---\(model.value)---\(model.text)")
                                    if let time = tem.elements(forName: "time").first?.stringValue{
                                        self.timeStamp = (self.timeStamp >= time) ? self.timeStamp : time
                                    }
                                }
                            }
                        }
                    }
                    if count == self.stationLabelArr.count{
                        self.getDate(fromStamp: self.timeStamp)
                        self.getlabelArrs()
                        if update{
                            self.reWriteData()
                        }else{
                            self.drawLabels()
                        }
                    }
                    count += 1
                }else{
                    print("error")
                }
            })
        }
    }
    
    func getDate(fromStamp: String) {
        //offset只能给出差值，未能显示正负时区
        let date = Date.init(timeIntervalSince1970: TimeInterval(fromStamp)!)
        let offset = TimeZone.current.secondsFromGMT()
        let currentDate = date.addingTimeInterval(TimeInterval(-offset))
        dataDate = currentDate
        
    }
    
    //更新实时数据
    func reWriteData() {
        for temp in labelArr{
            let label = imageView.viewWithTag((temp.tag_id as NSString).integerValue + ((temp.station_id as NSString).integerValue * 1000)) as! UILabel
            
            let textAttribute = [NSAttributedStringKey.foregroundColor: temp.foreColor]
            let valueAttribute = [NSAttributedStringKey.foregroundColor: temp.dataColor]
            let text = NSMutableAttributedString.init(string: temp.text, attributes: textAttribute)
            
            var unitAttribute = NSAttributedString.init(string: temp.unit)
            if !temp.specialunit.isEmpty{
                unitAttribute = NSAttributedString.init(string: temp.specialunit)
            }
            if temp.valueTrans.isEmpty{
                let num = (temp.value as NSString).floatValue
                let format = self.valueLength(temp.format)
                let value = NSAttributedString.init(string: String(format: "%.\(format)f", num), attributes: valueAttribute)
                text.append(value)
                text.append(unitAttribute)
                label.attributedText = text
            }else{
                let value = NSAttributedString(string: getTransValue(temp.valueTrans, temp.value)!, attributes: valueAttribute)
                text.append(value)
                text.append(unitAttribute)
                label.attributedText = text
            }
        }
        let formatt = DateFormatter()
        formatt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateView.text = "数据时间:" + formatt.string(from: self.dataDate)
    }
    
    func getlabelArrs() {
        labelArr.removeAll()
        for arr in stationLabelArr {
            self.labelArr += arr.modles
        }
    }
    
    func drawLabels(_ last:Bool = false) {
        imageView.frame = CGRect(x: 48, y: 0, width: UIScreen.main.bounds.width - 48 - 48, height: UIScreen.main.bounds.height)
        if let image = imageView.image {
            originalRatio = (image.size.height)/(image.size.width)
        }
        
        for view in imageView.subviews {
            view.removeFromSuperview()
        }
        
        var h = imageView.bounds.height
        var w = h/CGFloat(originalRatio)
        var x = (imageView.bounds.width - w)/2
        var y:CGFloat = 0
        
        if 1/originalRatio > imageView.bounds.width/imageView.bounds.height {
            w = imageView.bounds.width
            h = w*CGFloat(originalRatio)
            x = 0
            y = (imageView.bounds.height - h)/2
        }
        
        if last {
            for temp in labelArr {
                if !temp.text.isEmpty{
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 9)
                    
                    label.frame = CGRect(x: CGFloat(temp.x) * w + x, y: CGFloat(temp.y) * h + y, width: CGFloat(temp.width)*w, height: CGFloat(temp.height)*h)
                    label.text = temp.text
                    let size2 = (label.text! as NSString).boundingRect(with: CGSize.init(width: 0, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: label.font], context: nil).size
                    label.frame.size = size2
                    imageView.addSubview(label)
                }
            }
        }else{
            for temp in labelArr {
                print("label:------\(temp.text)----\(temp.value)")
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 9)
                label.tag = (temp.tag_id as NSString).integerValue + ((temp.station_id as NSString).integerValue * 1000)
                print("======\(temp.width)---\(temp.height)")
                label.frame = CGRect(x: CGFloat(temp.x) * w + x, y: CGFloat(temp.y) * h + y, width: CGFloat(temp.width)*w, height: CGFloat(temp.height)*h)
                //                label.backgroundColor = UIColor.white
                let textAttribute = [NSAttributedStringKey.foregroundColor: temp.foreColor]
                let valueAttribute = [NSAttributedStringKey.foregroundColor: temp.dataColor, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 9, weight: .thin)] as [NSAttributedStringKey : Any]
                let text = NSMutableAttributedString.init(string: temp.text, attributes: textAttribute)
                
                var unitAttribute = NSAttributedString.init(string: temp.unit)
                if !temp.specialunit.isEmpty{
                    unitAttribute = NSAttributedString.init(string: temp.specialunit)
                }
                if temp.valueTrans.isEmpty{
                    let num = (temp.value as NSString).floatValue
                    
                    let format = self.valueLength(temp.format)
                    let value = NSAttributedString.init(string: String(format: "%.\(format)f", num), attributes: valueAttribute)
                    text.append(value)
                    text.append(unitAttribute)
                    label.attributedText = text
                }else{
                    let value = NSAttributedString.init(string: getTransValue(temp.valueTrans, temp.value)!, attributes: valueAttribute)
                    text.append(value)
                    text.append(unitAttribute)
                    label.attributedText = text
                }
                label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
                label.adjustsFontSizeToFitWidth = true
                self.imageView.addSubview(label)
            }
            
        }
        let formatt = DateFormatter()
        formatt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateView.text = "数据时间:" + formatt.string(from: self.dataDate)
        dateView.textAlignment = .center
        dateView.font = UIFont.systemFont(ofSize: 9)
        dateView.textColor = UIColor.blue
        dateView.frame = CGRect.init(x: imageView.bounds.width/2 - 100, y: 5, width: 200, height: 20)
        dateView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        imageView.addSubview(dateView)
        
        //启用定时器，每30秒执行一次showRecentData方法
        //        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (timer) in
        //
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startUpdate), userInfo: nil, repeats: true)
        
        //        }
        //        Timer.perform(#selector(startUpdate), with: self, afterDelay: 10)
    }
    
    //保留小数位
    func valueLength(_ format:String) ->Int{
        if format.contains(".") {
            let arr = format.components(separatedBy: ".")
            if arr.count == 1{
                return 1
            }else{
                return (arr.last?.count)! + 1
            }
        }else{
            return 0
        }
    }
    
    
    func getTransValue(_ string: String, _ value: String) -> String? {
        print("\(string)----\(value)")
        let arr = string.components(separatedBy: ";")
        for temp in arr {
            if temp.contains(value){
                return temp.components(separatedBy: "|").first
            }
        }
        return ""
    }
    
    //not common function ,just for xml file color(like R:,G:,B: )
    func strToColor(_ str: String) -> UIColor{
        var numArr: [Float] = []
        let arr = str.components(separatedBy: ",")
        for color in arr {
            let str = color.components(separatedBy: ":").last
            let num = (str! as NSString).floatValue
            numArr.append(num)
        }
        return UIColor(red: CGFloat(numArr.first!), green: CGFloat(numArr[1]), blue: CGFloat(numArr.last!), alpha: 1.0)
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        delegate.landscape = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if timer != nil{
            timer.invalidate()
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

