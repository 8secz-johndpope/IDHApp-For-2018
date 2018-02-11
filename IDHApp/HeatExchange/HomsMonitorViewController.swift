//
//  HomsMonitorViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/29.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON
let landScapeWidth = UIScreen.main.bounds.height
let landScapeHeight = UIScreen.main.bounds.width

class HomsMonitorViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func preButton(_ sender: UIButton) {
        currentIndex -= 1
        setNavgationTitleAndButton()
    }
    @IBAction func nextButton(_ sender: UIButton) {
        currentIndex += 1
        setNavgationTitleAndButton()
    }
    @IBOutlet weak var preBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var monitorView: UIView!
    
    @IBAction func ToHome(_ sender: UIButton) {
        let home = UIStoryboard.init(name: "Home", bundle: nil)
        let vc = home.instantiateViewController(withIdentifier: "home")
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func Back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var monitorImageView: UIImageView!
    
    //发送的post串
    var postXml = ""
    
    var isData = false
    var currentElementValue:String = ""
    var cno:String?
    var id:String?
    var value:String?
    
    var dataModel:[HeatExchangeModel] = []
    
    //定时器
    var timer:Timer!
    var currentIndex = 0
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appDelegate.landscape = true
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        setNavgationTitleAndButton()
        
    }
    
    //页面即将要消失时设置回竖屏
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate.landscape = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if timer != nil{
            timer.invalidate()
        }
    }
    
    //设置换热站监控画面上要显示的参数
    func showBackgroundAndTags(){
        //清空之前添加的子视图
        for item in (self.monitorImageView?.subviews)!{
            item.removeFromSuperview()
        }
        
        if timer != nil{
            timer.invalidate()
        }
        
        //0:热源厂，1:换热站
        let url = "Http://\(idh_ip_port)/Analyze.svc/GetHoxConfig/\(dataModel[currentIndex].ID)/1"
        Alamofire.request(url).responseJSON { response in
            guard response.result.isSuccess else{
                return
            }
            
            guard let value = response.result.value else{
                return
            }
            DispatchQueue.global().sync {
                let json = JSON(value)
                var labelShowArr:[UILabel] = []
                
                //将耗时操作放在全局队列中去执行
                let postXmlBegin = "<?xml version=\"1.0\" encoding=\"GB2312\"?><homsdata xmlns=\"http://www.shuoren.com\">"
                let postXmlEnd = "</homsdata>"
                var postXmlContent = ""
                
                //设置显示的参数
                let tagArr = json["data"].arrayValue
                let originalAspect: CGFloat = 1.7628866
                let height = CGFloat((landScapeHeight - 96))/originalAspect
                
                for item in tagArr{
                    //计算距离原点的上、下偏移量
                    let postx = (item["postx"].stringValue).replacingOccurrences(of: "%", with: "")
                    let posty = (item["posty"].stringValue).replacingOccurrences(of: "%", with: "")
                    let posX = CGFloat((postx as NSString).floatValue/100) * self.monitorImageView.frame.width
                    let posY = CGFloat((posty as NSString).floatValue/100) * height
                    
                    //根据显示文本多少及字体大小动态计算Label的宽度与高度
                    let lblShow = UILabel(frame: CGRect(x: posX, y: posY, width: 0, height: 0))
                    lblShow.text = item["showname"].stringValue
                    lblShow.font = UIFont.systemFont(ofSize: 9)
                    
                    let options : NSStringDrawingOptions = .usesLineFragmentOrigin
                    let boundingRect = (lblShow.text! as NSString).boundingRect(with: CGSize.init(width: 0, height: 0), options: options, attributes: [NSAttributedStringKey.font:lblShow.font], context: nil).size
                    let actualWidth = boundingRect.width
                    let actualHeight = boundingRect.height
                    
                    lblShow.frame = CGRect(x: posX, y: posY, width: actualWidth, height: actualHeight)
                    
                    //获取通讯站号与标签
                    let commno = item["commno"].stringValue
                    let tagno = item["tagno"].stringValue
                    
                    postXmlContent += "<data><cno>\(commno)</cno><id>\(tagno)</id></data>"
                    
                    //放置一个显示实时数据的Label,与显示文本相距10个点
                    let lblData = UILabel(frame: CGRect(x: posX+actualWidth+5, y: posY, width: 30, height: 10))
                    
                    lblData.font = UIFont.systemFont(ofSize: 9)
                    lblData.textColor = UIColor.blue
                    lblData.tag = Int(commno)!*100000 + Int(tagno)!
                    
                    labelShowArr.append(lblShow)
                    labelShowArr.append(lblData)
                }
                
                self.postXml = postXmlBegin + postXmlContent + postXmlEnd
                
                DispatchQueue.main.async(){
                    let activityIndicatr = UIActivityIndicatorView(activityIndicatorStyle:.gray)
                    activityIndicatr.center = CGPoint(x: landScapeHeight/2, y: landScapeWidth/2)
                    activityIndicatr.color = UIColor.red
                    self.monitorView.addSubview(activityIndicatr)
                    self.monitorView.bringSubview(toFront: activityIndicatr)
                    
                    //启动
                    activityIndicatr.startAnimating()
                    
                    //设置背景图
                    let imgUrl = "Http://" + idh_ip_port + "/" + json["img"].stringValue
                    let myUrl = URL(string: imgUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    self.monitorImageView.kf.setImage(with: myUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageUrl) in
                        activityIndicatr.stopAnimating()
                        
                        //添加一个长按手势
                        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handlePressGesture(_:)))
                        self.monitorImageView.addGestureRecognizer(pressGesture)
                    })
                    
                    //设置系统当前时间
                    let currentDate = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    let lblCurrentDate = UILabel(frame: CGRect(x:0,y:0,width:160,height:10))
                    lblCurrentDate.textAlignment = .center
                    lblCurrentDate.center = CGPoint(x: self.monitorView.center.x - 80 + 48, y: (landScapeWidth - height)/2 + 5)
                    
                    lblCurrentDate.text = "当前时间：" + dateFormatter.string(from: currentDate)
                    lblCurrentDate.font = UIFont.systemFont(ofSize: 10)
                    lblCurrentDate.textColor = UIColor.blue
                    lblCurrentDate.tag = 1
                    self.monitorImageView.addSubview(lblCurrentDate)
                    
                    //设置显示的文本标签
                    for item in labelShowArr{
                        self.monitorImageView.addSubview(item)
                    }
                    
                    //调用显示实时数据函数显示各参数值，然后再开启定时器去实时刷新数据
                    self.showRecentData()
                    
                    //启用定时器，每30秒执行一次showRecentData方法
                    self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.showRecentData), userInfo: nil, repeats: true)
                }
            }
        }
    }
    
    //长按屏幕出现放大镜框
    @objc func handlePressGesture(_ sender:UILongPressGestureRecognizer){
        //截取区域的长、宽
        let rectWidth:CGFloat = 100
        let rectHeight:CGFloat = 100
        
        //放大倍数
        let scale:CGFloat = 1.5
        
        //长按开始
        if sender.state == .began{
            let scaleView = UIImageView()
            
            scaleView.tag = 1000
            scaleView.contentMode = .scaleToFill
            scaleView.layer.borderWidth = 1
            scaleView.layer.borderColor = UIColor(red: 169/255.0, green: 169/255.0, blue: 169/255.0, alpha: 1.0).cgColor
            //透明度
            scaleView.alpha = 1
            scaleView.layer.cornerRadius = 5
            
            monitorImageView.addSubview(scaleView)
            
            showScaleRect(sender, rectWidth: rectWidth, rectHeight: rectHeight, scale: scale)
        }
            //长按结束
        else if sender.state == .ended{
            //删除之前添加的放大镜框，删除之前最好做下判断
            if let prevView = monitorImageView.viewWithTag(1000){
                prevView.removeFromSuperview()
            }
        }
            //长按移动
        else if sender.state == .changed{
            showScaleRect(sender, rectWidth: rectWidth, rectHeight: rectHeight, scale: scale)
        }
    }
    
    func showScaleRect(_ sender:UILongPressGestureRecognizer,rectWidth:CGFloat,rectHeight:CGFloat,scale:CGFloat){
        let position = sender.location(in: monitorImageView)
        print("\(position)")
        
        let originalAspect: CGFloat = 1.7628866
        
        let height = CGFloat((landScapeHeight - 96))/originalAspect
        
        let pointX = position.x
        let pointY = position.y
        
        //实时判断放大框应出现在左侧还是右侧
        if let moveView = monitorImageView.viewWithTag(1000){
            //右侧
            if pointX <= monitorImageView.bounds.width/2{
                print("you")
                moveView.frame = CGRect(x: landScapeHeight-(rectWidth * scale)-96, y: monitorImageView.center.y - 75, width: (rectWidth * scale), height: (rectHeight * scale))
            }//左侧
            else{
                moveView.frame = CGRect(x: 0, y: monitorImageView.center.y - 75, width: (rectWidth * scale), height: (rectHeight * scale))
            }
            
            //先截取全屏图片
            //            let window = UIApplication.shared.keyWindow
            //            UIGraphicsBeginImageContextWithOptions(window!.bounds.size, false, 0.0)
            
            UIGraphicsBeginImageContextWithOptions(self.monitorImageView.bounds.size, false, 0.0)
            self.monitorImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let screenImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //截取全屏图片上的部分区域
            var scale:CGFloat = 0
            if UIScreen.main.bounds.width > 667{
                scale = 3
            }else{
                scale = 2
            }
            
            let rectCGImage = screenImage?.cgImage?.cropping(to: CGRect(x: pointX*scale, y: pointY*scale, width: rectWidth, height: rectHeight))
            (moveView as! UIImageView).image = UIImage(cgImage: rectCGImage!)
        }
    }
    
    //
    func setNavgationTitleAndButton(){
        if dataModel.count == 1 {
            preBtn.isHidden = true
            nextBtn.isHidden = true
        }else{
            if currentIndex == 0 {
                preBtn.isHidden = true
            }else if currentIndex == dataModel.count - 1{
                preBtn.isHidden = false
                nextBtn.isHidden = true
            }else{
                preBtn.isHidden = false
                nextBtn.isHidden = false
            }
        }
        
        var name = ""
        
        for char in dataModel[currentIndex].Name {
            name.append(char)
            name.append("\n")
        }
        titleLabel.text = name
        //重新显示数据
        showBackgroundAndTags()
    }
    
    //获取实时数据并更新到画面上
    @objc func showRecentData(){
        //先更新系统时间
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let lblCurrentDate = self.monitorView.viewWithTag(1) as! UILabel
        lblCurrentDate.text = "当前时间：" + dateFormatter.string(from: currentDate)
        
        let postUrl = "Http://\(idh_monitor_ip_port)/datacenter/dataservice/RecentData.aspx"
        
        //1.创建会话对象
        let session: URLSession = URLSession.shared
        //2.根据会话对象创建task
        let url: URL =  URL(string: postUrl)!
        //3.创建可变的请求对象
        var request: URLRequest =  URLRequest(url: url)
        //4.修改请求方法为POST
        request.httpMethod = "POST"
        //5.设置请求体
        request.httpBody = self.postXml.data(using: String.Encoding.utf8)
        
        //根据会话对象创建一个Task(发送请求）
        
        let dataTask: URLSessionDataTask = session.dataTask(with: request) { (data, reponse, error) in
            if data != nil{
                DispatchQueue.main.async{
                    let xmlParse = XMLParser(data: data!)
                    xmlParse.delegate = self
                    xmlParse.parse()
                }
            }
        }
        
        //执行任务
        dataTask.resume()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension HomsMonitorViewController:XMLParserDelegate{
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "data"{
            isData = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementValue = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if isData {
            if elementName == "cno"{
                cno = currentElementValue
            }
            else if elementName == "id"{
                id = currentElementValue
            }
            else if elementName == "value"{
                value = currentElementValue
            }
            
            if elementName == "data"{
                guard let tagCno = cno,let tagId = id, let tagValue = value else{
                    return
                }
                let tag = Int(tagCno)!*100000 + Int(tagId)!
                
                if monitorImageView.viewWithTag(tag) != nil{
                    let lblData = monitorImageView.viewWithTag(tag) as! UILabel
                    lblData.text = String(format:"%.2f",(tagValue as NSString).doubleValue)
                    
                    let posX = lblData.frame.origin.x
                    let posY = lblData.frame.origin.y
                    let options : NSStringDrawingOptions = .usesLineFragmentOrigin
                    let boundingRect = (lblData.text! as NSString).boundingRect(with: CGSize(width: 0, height: 0), options: options, attributes: [NSAttributedStringKey.font:lblData.font], context: nil).size
                    let actualWidth = boundingRect.width
                    let actualHeight = boundingRect.height
                    
                    lblData.frame = CGRect(x: posX, y: posY, width: actualWidth, height: actualHeight)
                    //进入到下一个元素
                    isData = false
                }
            }
        }
    }
}

