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

class MonitorViewController: BaseViewController {
    var imageView = UIImageView()
    var model: heatModel?
    var labelArr: [LabelModel] = []
    var stationLabelArr: [(station: String, modles:[LabelModel])] = []
    var stationIDArr: [String] = []
    
    var current: Int = 0{
        didSet{
            changeExchanger()
        }
    }
    var models: [HeatExchangeModel] = []
    let dateView = UILabel()
    var titleName = UILabel()
    var lastPoint: CGPoint?
    var maxScale: CGFloat = 1.5
    var minScale: CGFloat = 0.5
    var preButton: UIButton?
    var nextButton: UIButton?
    var timer: Timer!
    
    var pointValue = CGPoint.zero
    var scaleValue: CGFloat = 1.0
    
    var originalRatio:CGFloat = 0
    var activityIndicator = UIActivityIndicatorView()
    
    //deprecated
    var textArr: [UILabel] = []
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var imageActivity = UIActivityIndicatorView()
    
    var testLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setUpViews()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeLeft
    }
    
    @objc func startUpdate() {
//        Toast.shareInstance().showView(self.view, title: "数据更新中...")
        requestValues(true)
    }
    
    func setUpViews() {
        let editorView = LayoutableView()
        editorView.layout = WeightsLayout.init(horizontal: false)
        editorView.layout?.weights = [1,1,1,4,1,1,1]
        editorView.frame = CGRect.init(x: 0, y: 0, width: 48, height: self.view.bounds.width)
        editorView.backgroundColor = UIColor.gray
        
        let home = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
        home.setImage(#imageLiteral(resourceName: "quality_ico_home"), for: .normal)
        home.addTarget(self, action: #selector(toHome), for: .touchUpInside)
        
        if AppProvider.instance.appVersion == .homs03 || AppProvider.instance.appVersion == .homsOther {
            home.isHidden = true
        }
        
        let back = UIButton(frame: CGRect(x: 0, y: self.view.bounds.width - 48, width: 48, height: 48))
        back.setImage(#imageLiteral(resourceName: "back_factory"), for: .normal)
        back.addTarget(self, action: #selector(backTo), for: .touchUpInside)
        preButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
        preButton?.setImage(#imageLiteral(resourceName: "next"), for: .normal)
        preButton?.tag = 100
        preButton?.addTarget(self, action: #selector(changeModel(_:)), for: .touchUpInside)
        
        nextButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
        nextButton?.setImage(#imageLiteral(resourceName: "pre"), for: .normal)
        nextButton?.tag = 200
        nextButton?.addTarget(self, action: #selector(changeModel(_:)), for: .touchUpInside)
        
        titleName.numberOfLines = 0
        titleName.lineBreakMode = .byCharWrapping
        titleName.textAlignment = .center
        var newName = ""
        if models.isEmpty {
            for char in (model?.area_name)!{
                newName.append(char)
                newName.append("\n")
            }
            preButton?.isHidden = true
            nextButton?.isHidden = true
        }else{
            if models.count == 1 {
                preButton?.isHidden = true
                nextButton?.isHidden = true
            }else{
                if current == 0 {
                    preButton?.isHidden = true
                }else if current == (models.count) - 1{
                    nextButton?.isHidden = true
                }
            }
            for char in models[current].Name {
                newName.append(char)
                newName.append("\n")
            }
        }
        print(newName)
        titleName.text = newName
        titleName.textColor = UIColor.white
        editorView.addSubview(home)
        editorView.addSubview(UIView())
        editorView.addSubview(preButton!)
        editorView.addSubview(titleName)
        editorView.addSubview(nextButton!)
        editorView.addSubview(UIView())
        editorView.addSubview(back)
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.height, height: self.view.bounds.width)
        
        imageView.addGestureRecognizer(UIPinchGestureRecognizer.init(target: self, action: #selector(zoomImage)))
        imageView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(move)))
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:.gray)
        activityIndicator.center.x = self.view.center.y
        activityIndicator.center.y = self.view.center.x
        activityIndicator.color = UIColor.gray
        
        imageActivity = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        imageActivity.center.x = self.view.center.y
        imageActivity.center.y = self.view.center.x
        
        self.view.addSubview(imageView)
        self.view.addSubview(editorView)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(imageActivity)
        self.view.bringSubview(toFront: activityIndicator)
    }
    
    func changeExchanger() {
        if timer != nil {
            timer.invalidate()
        }
        imageView.transform = CGAffineTransform.identity
        changeButtonState()
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
            model = getModel(exchanger)
        }
        var newName = ""
        
        for char in name {
            newName.append(char)
            newName.append("\n")
        }
        titleName.text = newName
        labelArr.removeAll()
        stationLabelArr.removeAll()
        stationIDArr.removeAll()
        testLabel.text = ""
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
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    
    @objc func changeModel(_ sender: UIButton) {
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
    
    func changeButtonState() {
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
    
    @objc func zoomImage(_ sender: UIPinchGestureRecognizer) {
        
        adjustAnchorPoint(for: sender)
        if sender.state == .began {
            scaleValue = sender.scale
        }
        
        if sender.state == .began || sender.state == .changed {
            
            let currentScale: CGFloat = sender.view!.layer.value(forKeyPath: "transform.scale") as! CGFloat
            let kMaxScale: CGFloat = 1.5
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
    
    @objc func backTo() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toHome() {
        let home = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = home.instantiateViewController(withIdentifier: "home")
        
        self.present(vc, animated: true, completion: nil)
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
                        //                            self.originalRatio = CGFloat((fixedH! as NSString).floatValue/(fixedW! as NSString).floatValue)
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
                    if !self.stationIDArr.contains(model.station_id){
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
            self.testLabel = UILabel.init(frame: CGRect.init(x: 48, y: 0, width: 300, height: 20))
            self.testLabel.text = heat.path
            self.view.addSubview(testLabel)
            self.view.bringSubview(toFront: testLabel)
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
                                    if !self.stationIDArr.contains(model.station_id){
                                        self.stationIDArr.append(model.station_id)
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
        testLabel.text = path
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
        for temp in self.stationIDArr{
            var arr: [LabelModel] = []
            for model in self.labelArr{
                if temp == model.station_id{
                    arr.append(model)
                }
            }
            self.stationLabelArr.append((temp,arr))
        }
    }
    
    func requestValues(_ update: Bool = false) {
        for index in 0..<stationLabelArr.count {
            let station = stationLabelArr[index].station
            //请求
            Alamofire.request(StationURL, method: .get, parameters: ["stationid": station]).responseData(completionHandler: { reponse in
                if reponse.result.isSuccess{
                    let doc = try! DDXMLDocument.init(data: reponse.result.value!, options: 0)
                    let data = doc.rootElement()?.elements(forName: "data")
                    for tem in data!{
                        if let tag = tem.elements(forName: "id").first?.stringValue{
                            
                            for model in self.labelArr{
                            if tag == model.tag_id{
                                model.value = (tem.elements(forName: "value").first?.stringValue)!
                            }
                            }
                        }
                    }
                    
                    if index == self.stationLabelArr.count - 1{
//                        Toast.shareInstance().hideView()
                        if update{
                            self.reWriteData()
                        }else{
                            self.drawLabels()
                        }
                    }
                }else{
                    print("error")
                }
            })
        }
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
        dateView.text = "数据时间:" + formatt.string(from: Date())
}
    
    func drawLabels(_ last:Bool = false) {
        imageView.frame = CGRect(x: 48, y: 0, width: UIScreen.main.bounds.width - 48, height: UIScreen.main.bounds.height)
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
        let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 9)
            label.tag = (temp.tag_id as NSString).integerValue + ((temp.station_id as NSString).integerValue * 1000)
//            if !temp.text.isEmpty{
                label.frame = CGRect(x: CGFloat(temp.x) * w + x, y: CGFloat(temp.y) * h + y, width: CGFloat(temp.width)*w, height: CGFloat(temp.height)*h)
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
                    let value = NSAttributedString.init(string: getTransValue(temp.valueTrans, temp.value)!, attributes: valueAttribute)
                    text.append(value)
                    text.append(unitAttribute)
                    label.attributedText = text
                }
                
                label.adjustsFontSizeToFitWidth = true
                self.imageView.addSubview(label)
        }
            
        }
        let formatt = DateFormatter()
        formatt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateView.text = "数据时间:" + formatt.string(from: Date())
        dateView.textAlignment = .center
        dateView.font = UIFont.systemFont(ofSize: 9)
        dateView.textColor = UIColor.blue
        dateView.frame = CGRect.init(x: imageView.bounds.width/2 - 100, y: 10, width: 200, height: 20)
        dateView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        imageView.addSubview(dateView)
        
        //启用定时器，每30秒执行一次showRecentData方法
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(startUpdate), userInfo: nil, repeats: true)
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
