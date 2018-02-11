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
    
    var textArr: [UILabel] = []
    var delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setUpViews()

        //启用定时器，每30秒执行一次showRecentData方法
        self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(startUpdate), userInfo: nil, repeats: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeLeft
    }
    
    @objc func startUpdate() {
        print("time update ")
        requestValues(true)
    }
    
    func setUpViews() {
        let editorView = LayoutableView()
        editorView.layout = WeightsLayout.init(horizontal: false)
        editorView.layout?.weights = [1,1,1,3,1,1,1]
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
        activityIndicator.center.x = self.view.bounds.height - 20
        activityIndicator.center.y = 20
        activityIndicator.color = UIColor.gray
        
        self.view.addSubview(imageView)
        self.view.addSubview(editorView)
        self.view.addSubview(activityIndicator)
    }
    
    func changeExchanger() {
        imageView.transform = CGAffineTransform.identity
        changeButtonState()
        var name = ""
        if models.isEmpty {
            name = (model?.area_name)!
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
        textArr.removeAll()
        loadDatas()
    }
    
    func getModel(_ exchange: HeatExchangeModel) -> heatModel? {
        let realm = try! Realm()
            let id = exchange.ID
        
        if let model = realm.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first{
            return model
        }else{
            for view in imageView.subviews{
                view.removeFromSuperview()
            }
            Toast.shareInstance().showView(self.view, title: "暂无数据")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
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
        let str = MonitorURL+"?action=get&path=\(path)"
        let url = URL(string: str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        imageView.kf.setImage(with: url)
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
                        
                    let dataStrs = doc.rootElement()?.elements(forName: "datastr")
                    if let dataW = doc.rootElement()?.attribute(forName: "width")?.stringValue, let dataH = doc.rootElement()?.attribute(forName: "height")?.stringValue{
                        let H = (dataH as NSString).floatValue
                        let W = (dataW as NSString).floatValue
                        self.originalRatio = CGFloat(H/W)
                    }else{
                        self.originalRatio = CGFloat(1028/853)
                    }
                    
                    for data in dataStrs!{
                        let model = LabelModel()
                        if let location = data.elements(forName: "location").first{
                            let x = location.attribute(forName: "x")?.stringValue
                            let y = location.attribute(forName: "y")?.stringValue
                            let width = location.attribute(forName: "width")?.stringValue
                            let height = location.attribute(forName: "height")?.stringValue
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
                            model.text = text!
                            model.foreColor = self.strToColor(foreColor!)
                            model.dataColor = self.strToColor(valueColor!)
                            model.valueTrans = valuetrans!
                            }
                        }
                        if let dataSource = data.elements(forName: "datasource").first{
                            let stationId = dataSource.attribute(forName: "stationid")?.stringValue
                            let tagid = dataSource.attribute(forName: "datatagid")?.stringValue
                            let unit = dataSource.attribute(forName: "unit")?.stringValue
                            model.station_id = stationId!
                            model.tag_id = tagid!
                            model.unit = unit!
                        }
                        self.labelArr.append(model)
                        }
                    self.requestValues()
                    }
                }else{
                    print("error")
                }
            })
            }
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
                        self.requestImage(path)
                        self.activityIndicator.stopAnimating()
                    }
                }
                    let dataStrs = doc.rootElement()?.elements(forName: "datastr")
                    if let dataW = doc.rootElement()?.attribute(forName: "width")?.stringValue, let dataH = doc.rootElement()?.attribute(forName: "height")?.stringValue{
                        let H = (dataH as NSString).floatValue
                        let W = (dataW as NSString).floatValue
                        self.originalRatio = CGFloat(H/W)
                    }else{
                        self.originalRatio = CGFloat(1028/853)
                    }
                    
                    for data in dataStrs!{
                        let model = LabelModel()
                        if let location = data.elements(forName: "location").first{
                            let x = location.attribute(forName: "x")?.stringValue
                            let y = location.attribute(forName: "y")?.stringValue
                            let width = location.attribute(forName: "width")?.stringValue
                            let height = location.attribute(forName: "height")?.stringValue
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
                                model.text = text!
                                model.foreColor = self.strToColor(foreColor!)
                                model.dataColor = self.strToColor(valueColor!)
                                model.valueTrans = valuetrans!
                            }
                        }
                        if let dataSource = data.elements(forName: "datasource").first{
                            let stationId = dataSource.attribute(forName: "stationid")?.stringValue
                            let tagid = dataSource.attribute(forName: "datatagid")?.stringValue
                            let unit = dataSource.attribute(forName: "unit")?.stringValue
                            model.station_id = stationId!
                            model.tag_id = tagid!
                            model.unit = unit!
                        }
                        self.labelArr.append(model)
                    }
                    self.requestValues()
            }else{
                print("\(path)---error")
            }
        }
    }
    
    func requestValues(_ update: Bool = false) {
        let station = labelArr.first?.station_id
        Alamofire.request(StationURL, method: .get, parameters: ["stationid": station ?? ""]).responseData(completionHandler: { reponse in
            if reponse.result.isSuccess{
                let doc = try! DDXMLDocument.init(data: reponse.result.value!, options: 0)
                let data = doc.rootElement()?.elements(forName: "data")
                for temp in self.labelArr {
                    for tem in data!{
                        if let tag = tem.elements(forName: "id").first?.stringValue{
                            if tag == temp.tag_id{
                                temp.value = (tem.elements(forName: "value").first?.stringValue)!
                            }
                        }
                    }
            }
                if update{
                    self.reWriteData()
                }else{
                    self.drawLabels()
                }
        }else{
            print("error")
        }
        })
    }
    
    func reWriteData() {
        for label in textArr {
            for temp in labelArr{
                if label.tag == (temp.tag_id as NSString).integerValue{
                    if !temp.text.isEmpty{
                        let textAttribute = [NSAttributedStringKey.foregroundColor: temp.foreColor]
                        let valueAttribute = [NSAttributedStringKey.foregroundColor: temp.dataColor]
                        let text = NSMutableAttributedString.init(string: temp.text, attributes: textAttribute)
                        
                        let unitAttribute = NSAttributedString.init(string: temp.unit)
                        if temp.valueTrans.isEmpty{
                            let num = (temp.value as NSString).floatValue
                            let value = NSAttributedString.init(string: String(format: "%.2f", num), attributes: valueAttribute)
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
            }
        }
    }
}
    
    func drawLabels(_ last:Bool = false) {
        imageView.frame = CGRect(x: 48, y: 0, width: UIScreen.main.bounds.width - 48, height: UIScreen.main.bounds.height)
        if let image = imageView.image {
            originalRatio = (image.size.height)/(image.size.width)
        }else{
            originalRatio = CGFloat(766/622)
        }
        for view in imageView.subviews {
            view.removeFromSuperview()
        }
        let w = imageView.bounds.height/CGFloat(originalRatio)
        let x = (imageView.bounds.width - w)/2
        print("\(x)-----\(imageView.bounds.width)----\(w)")
        if last {
            for temp in labelArr {
                if !temp.text.isEmpty{
                    let label = UILabel()
                    label.adjustsFontSizeToFitWidth = true
                    label.frame = CGRect(x: CGFloat(temp.x) * w + x, y: CGFloat(temp.y) * imageView.bounds.height, width: CGFloat(temp.width)*w, height: CGFloat(temp.height)*imageView.bounds.height)
                    label.text = temp.text
                    imageView.addSubview(label)
                }
            }
        }else{
        for temp in labelArr {
        let label = UILabel()
            label.tag = (temp.tag_id as NSString).integerValue
            if !temp.text.isEmpty{
                label.frame = CGRect(x: CGFloat(temp.x) * w + x, y: CGFloat(temp.y) * imageView.bounds.height, width: CGFloat(temp.width)*w, height: CGFloat(temp.height)*imageView.bounds.height)
                let textAttribute = [NSAttributedStringKey.foregroundColor: temp.foreColor]
                let valueAttribute = [NSAttributedStringKey.foregroundColor: temp.dataColor]
                let text = NSMutableAttributedString.init(string: temp.text, attributes: textAttribute)
                
            let unitAttribute = NSAttributedString.init(string: temp.unit)
                if temp.valueTrans.isEmpty{
                    let num = (temp.value as NSString).floatValue
                    let value = NSAttributedString.init(string: String(format: "%.2f", num), attributes: valueAttribute)
                    text.append(value)
                    text.append(unitAttribute)
                    label.attributedText = text
                }else{
                    let value = NSAttributedString.init(string: getTransValue(temp.valueTrans, temp.value)!, attributes: valueAttribute)
                    text.append(value)
                    text.append(unitAttribute)
                    label.attributedText = text
                }
                label.font = UIFont.systemFont(ofSize: 9)
                label.adjustsFontSizeToFitWidth = true
                
                label.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
                print("\(label.frame)---\(imageView.frame)")
                self.imageView.addSubview(label)
                textArr.append(label)
            }else{
            }
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
        
    }
    
    
    func getTransValue(_ string: String, _ value: String) -> String? {
        let arr = string.components(separatedBy: ";")
        for temp in arr {
            if temp.contains(value){
                return temp.components(separatedBy: "|").first
            }
        }
       return ""
    }
    
    
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
    
//    func getXML() {
//
//    }
    
    
//    func zoom(_ recognize: UIPinchGestureRecognizer) {
//        imageView.transform = CGAffineTransform.scaledBy(CGAffineTransform.init(scaleX: 0.3, y: 0.3))
//    }

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
