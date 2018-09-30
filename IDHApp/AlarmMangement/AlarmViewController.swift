//
//  AlarmViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/12.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias backToHome = ()->Void

class AlarmViewController: UIViewController {

    @IBOutlet weak var alarmTable: UITableView!
    
    @IBOutlet weak var shimmerView: UIView!
    
    @IBOutlet weak var CallImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    var originalX:CGFloat = 0
    var alarmInfos:[AlarmModel] = []
    
    var timer:Timer!
    
    var backHomeClosure:backToHome?
    
    
    @IBAction func telTap(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "请输入电话", message: "", preferredStyle: .alert)
        alert.addTextField { (txt) in
            if let dic = Defaults.instance.getForKey(key: "alarm"){
                let phone = dic["phone"] as! String
                txt.text = phone
            }else{
                txt.placeholder = "请输入11位电话"
            }
            txt.keyboardType = .numberPad
        }
        let doneAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
            if let text = alert.textFields?.first?.text{
                let telPattern = "^[0-9]{11}$"
                let matcher = MyRegex(telPattern)
                if matcher.match(text){
                    Defaults.instance.setValue(forKey: "alarm", forValue: ["phone":text])
                }else{
                    ToastView.instance.showToast(text: "电话格式有误", pos: .Mid)
                }
            }
        }
        
        alert.addAction(doneAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getAlarmInfo()
        self.navigationItem.title = "报警管理"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "转发", style: .plain, target: self, action: #selector(toWeChat))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "quality_ico_home"), style: .plain, target: self, action: #selector(toHome))
        self.alarmTable.delegate = self
        self.alarmTable.dataSource = self
//        self.alarmTable.register(AdviceTableViewCell.self, forCellReuseIdentifier: "advice")
        self.alarmTable.register(UINib(nibName: "AdviceTableViewCell", bundle: nil), forCellReuseIdentifier: "advice")
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        CallImage.isUserInteractionEnabled = true
        CallImage.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panImage(_:))))
        originalX = CallImage.center.x
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getAlarmInfo), userInfo: nil, repeats: true)
    }
    
    
    @objc func getAlarmInfo() {
        ToastView.instance.showLoadingDlg()
//        let url = "http://113.140.66.34:6099/Analyze.svc/GetAlarmInformation/1"
        Alamofire.request(AlarmURL).responseJSON { (data) in
            ToastView.instance.hide()
            if data.result.isSuccess{
                self.alarmInfos = []
                let json = JSON(data.result.value)
                for (_,alarm) in json{
                    let model = AlarmModel.init(data: alarm)
                    self.alarmInfos.append(model)
                }
                ToastView.instance.hide()
                self.alarmTable.reloadData()
            }else{
                ToastView.instance.showToast(text: "暂无数据", pos: .Bottom)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        if timer != nil{
            timer.invalidate()
        }
    }
    
    @objc func panImage(_ sender:UIPanGestureRecognizer) {
                        messageLabel.isHidden = true
        let point = sender.translation(in: self.view)
        sender.view?.center = CGPoint.init(x: (sender.view?.center.x)! + point.x, y: CallImage.center.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        if sender.state == .ended {
            messageLabel.isHidden = false
            if CallImage.center.x > self.view.bounds.width - CallImage.bounds.width/2 - 20 {
                
                print("call")
                CallImage.transform = CGAffineTransform.init(translationX: 0, y: 0)
                CallImage.center.x = originalX
//                CallImage.transform = CGAffineTransform.identity
//                return
                
                callTele()
            }else{
                                CallImage.center.x = originalX
            }
        }else if sender.state == .changed{
            
            if CallImage.center.x < originalX {
                CallImage.center.x = originalX

//                print("call")
//                CallImage.transform = CGAffineTransform.identity
//                CallImage.transform = CGAffineTransform.init(translationX: 1, y: 1)
//                return
            }
        }
//        if sender.state == .ended {
//        }else if sender.state == .changed{
//
//        }
        
    }
    
    func callTele() {
        if let dic = Defaults.instance.getForKey(key: "alarm") {
            let str = dic["phone"] as! String
            if str.isEmpty{
                ToastView.instance.showToast(text: "请先设置电话号码", pos: .Mid)
            }else{
                let telPattern = "^[0-9]{11}$"
                let matcher = MyRegex(telPattern)
                if matcher.match(str){
                    UIApplication.shared.open(URL(string :"tel://\(str)")!, options: [:], completionHandler: nil)
                }else{
                    print("不符合")
                }
            }
        }else{
            ToastView.instance.showToast(text: "请先设置电话号码", pos: .Mid)
        }
    }
    
    @objc func toHome() {
        guard let back = backHomeClosure else { return }
        back()
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toWeChat() {
        ToastView.instance.showLoadingDlg()
        guard let window = UIApplication.shared.keyWindow else
        {
            return
        }
        //截屏
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //转发至系统分享
//        let active = UIActivityViewController(activityItems: [fileUrl], applicationActivities: [UIActivity()])
        let active = UIActivityViewController.init(activityItems: [image as Any], applicationActivities: [UIActivity()])
        
        //            active.excludedActivityTypes = [.airDrop]
        let pop = active.popoverPresentationController
        if let p = pop{
            p.sourceView = self.alarmTable
            p.permittedArrowDirections = .any
        }
        ToastView.instance.hide()
        self.present(active, animated: true, completion: nil)
        //转发
//        let share = WXImageObject()
//        share.imageData = UIImagePNGRepresentation(image!)
//        let msg = WXMediaMessage()
//        msg.mediaObject = share
//
//        //生成缩略图
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 60),false,0.0)
//        image?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 60))
//        let thumbImage=UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        msg.thumbData=UIImagePNGRepresentation(thumbImage!)
//
//        let req = SendMessageToWXReq()
//        req.text = nil
//        req.message = msg
//        req.bText = false
//
//        WXApi.send(req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ala")
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


extension AlarmViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmInfos.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if needAdvice {
            
            return HeaderForAlarm.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        }else{
            return HeaderForAlarmOne.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 40))
            
//            return UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return needAdvice ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if needAdvice{
            let cell = tableView.dequeueReusableCell(withIdentifier: "advice", for: indexPath) as! AdviceTableViewCell
            cell.selectionStyle = .none
            cell.setView(alarmInfos[indexPath.row])
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.selectionStyle = .none
            let lblTime = cell.viewWithTag(1) as! UILabel
            let lblValue = cell.viewWithTag(2) as! UILabel
            let lblinfo = cell.viewWithTag(3) as! UILabel
            let alamo = alarmInfos[indexPath.row]
            lblTime.text = alamo.Datatime
            lblValue.text = alamo.CurrentValue
            lblinfo.text = alamo.Message
            lblinfo.numberOfLines = 0
            lblinfo.adjustsFontSizeToFitWidth = true
            return cell
        }
    }
    
    
}
