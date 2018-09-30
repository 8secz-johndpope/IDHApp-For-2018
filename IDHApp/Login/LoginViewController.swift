//
//  LoginViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/21.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import CoreLocation
import RealmSwift

//var glo = <#value#>


class LoginViewController: UIViewController {
    
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    @IBOutlet weak var dropdownMenu: MKDropdownMenu!
    @IBOutlet weak var IPInputView: UIView!
    //播放器相关
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var location:CLLocationCoordinate2D?
    var locationManager:CLLocationManager = CLLocationManager()
    var realm:Realm?
    
    @IBOutlet weak var IP1: UITextField!
    @IBOutlet weak var IP2: UITextField!
    @IBOutlet weak var IP3: UITextField!
    @IBOutlet weak var IP4: UITextField!
    @IBOutlet weak var IP5: UITextField!
    //    var dropdownMenu:MKDropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        askNet()
        alertVoice()
        self.realm = try! Realm()
        self.dropdownMenu.layer.borderColor = UIColor.init(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0).cgColor
        self.dropdownMenu.layer.borderWidth = 0.5;
        
        let selectedBackgroundColor = UIColor.init(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.0)
        self.dropdownMenu.selectedComponentBackgroundColor = selectedBackgroundColor;
        self.dropdownMenu.dropdownBackgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1);
        
        self.dropdownMenu.dropdownShowsTopRowSeparator = false;
        self.dropdownMenu.dropdownShowsBottomRowSeparator = false;
        self.dropdownMenu.dropdownShowsBorder = true;
        self.dropdownMenu.useFullScreenWidth = true;
        self.dropdownMenu.fullScreenInsetLeft = 5;
        self.dropdownMenu.fullScreenInsetRight = 10;
        self.dropdownMenu.delegate = self
        self.dropdownMenu.dataSource = self
        
        self.dropdownMenu.backgroundDimmingOpacity = 0.05;
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
           locationManager.startUpdatingLocation()
        }
//        if (realm?.objects(GroupIPModel.self).isEmpty)! {
//            self.dropdownMenu.isUserInteractionEnabled = false
//        }else{
//            self.dropdownMenu.isUserInteractionEnabled = true
//        }
        
        
    }
    
    func askNet() {
        Alamofire.request("http://www.baidu.com")
    }
    
    func setUp() {
        pwdTF.delegate = self
        accountTF.delegate = self
        LoginBtn.isEnabled = false
        LoginBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        let contentView = LayoutableView()
//        contentView.frame = CGRect.init(x: 0, y: 0, width: IPInputView.frame.width, height: IPInputView.frame.height)
//        contentView.layout = WeightsLayout.init(horizontal: true)
//        contentView.layout?.weights = [2,1,2,1,2,1,2,1,2]
//        contentView.backgroundColor = UIColor.white
//        lab1.text = "."
//        lab2.text = "."
//        lab3.text = "."
//        lab4.text = ":"
//        text1.layer.borderColor = UIColor.black.cgColor
//        text1.backgroundColor = UIColor.gray
//        contentView.addSubview(text1)
//        contentView.addSubview(lab1)
//        contentView.addSubview(text2)
//        contentView.addSubview(lab2)
//        contentView.addSubview(text3)
//        contentView.addSubview(lab3)
//        contentView.addSubview(text4)
//        contentView.addSubview(lab4)
//        contentView.addSubview(text5)
        IP1.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        IP2.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        IP3.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        IP4.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        IP5.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        accountTF.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
        pwdTF.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
//        self.IPInputView.addSubview(contentView)
    }
    
    @objc func textChange(_ textField:UITextField) {
        if textField.text?.count == 3 {
        switch textField {
        case IP1:
            IP2.becomeFirstResponder()
        case IP2:
            IP3.becomeFirstResponder()
        case IP3:
            IP4.becomeFirstResponder()
        case IP4:
            IP5.becomeFirstResponder()
        default: break
        }
        }
        if textField == IP5 {
            if textField.text?.count == 4{
                IP5.resignFirstResponder()
            }
        }
        if !(IP1.text?.isEmpty)! && !(IP2.text?.isEmpty)! && !(IP3.text?.isEmpty)! && !(IP4.text?.isEmpty)! && !(IP5.text?.isEmpty)!{
            if !(accountTF.text?.isEmpty)! && !(pwdTF.text?.isEmpty)! {
                LoginBtn.isEnabled = true
                LoginBtn.backgroundColor = #colorLiteral(red: 0.08246031404, green: 0.6449468732, blue: 0.6372987032, alpha: 0.7043911638)
            }else{
                LoginBtn.isEnabled = false
                LoginBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }else{
            LoginBtn.isEnabled = false
            LoginBtn.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        loginByIP()
        
        /*
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        let alomo = Alamofire.SessionManager.default
        alomo.session.configuration.timeoutIntervalForRequest = 5.0
        
//        loginByIP()
//        AppProvider.instance.setVersion()
        
        if !(accountTF.text?.isEmpty)! && !(pwdTF.text?.isEmpty)!{
            if let user = accountTF.text, let pwd = pwdTF.text {
                //homs03直接登录
                AppProvider.instance.setVersion()
                if AppProvider.instance.appVersion == .homs03{
                    UserDefaults.standard.set("homs03", forKey: "roleID")
                    UserDefaults.standard.synchronize()
                    let str = AppProvider.instance.providerLogin()
                    let vc = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                    self.present(vc, animated: true, completion: nil)
                }else{
                    let match = MyRegex("^[^\\u4e00-\\u9fa5]{0,}$")
                    if(match.match(user)){
                        let url = "http://\(idh_ip_port)/Analyze.svc/GetRole/\(user)/\(pwd.MD5()!)"
                        print("++++++\(url)")
                        var roleID = ""
                        alomo.request(url, method: .get).responseJSON(completionHandler: { reponse in
                            if reponse.result.isSuccess{
                                let result = reponse.result.value as? NSDictionary
                                if let role = result!["RoleID"]{
                                    roleID = role as! String
                                }
                                if roleID.isEmpty{
                                    //弹出页面
                                    Toast.shareInstance().showView(self.view, title: "账号或密码有误!")
                                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                }else{
                                    UserDefaults.standard.set(roleID, forKey: "roleID")
                                    UserDefaults.standard.synchronize()
                                    role_id = roleID
                                    AppProvider.instance.setVersion()
                                    let str = AppProvider.instance.providerLogin()
                                    var vc:UIViewController
                                    if str == "home"{
                                        globalTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.alertVoice), userInfo: nil, repeats: true)
                                        let main = UIStoryboard.init(name: "Home", bundle: nil)
                                        vc = main.instantiateViewController(withIdentifier: "home")
                                    }else{
                                        vc = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                                    }
                                    Toast.shareInstance().showView(self.view, title: "登陆成功")
                                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                    self.present(vc, animated: true, completion: {
                                        self.accountTF.text = nil
                                        self.pwdTF.text = nil
                                    })
                                }
                            }else{
                                Toast.shareInstance().showView(self.view, title:"该服务暂未开通，不支持登录")
                                print(reponse.error)
                                Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                            }
                        })
                    }
                }
            }
        }else if (accountTF.text?.isEmpty)! && !(pwdTF.text?.isEmpty)!{
            Toast.shareInstance().showView(self.view, title: "请输入账号!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }else if (pwdTF.text?.isEmpty)! && (accountTF.text?.isEmpty)!{
            Toast.shareInstance().showView(self.view, title: "请输入账号和密码!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }else{
            Toast.shareInstance().showView(self.view, title: "请输入密码!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }
        */
    }
    
    func loginByIP() {
        guard let acc = accountTF.text, !acc.isEmpty else { Toast.shareInstance().showView(self.view, title: "请输入账号!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let pwd = pwdTF.text, !pwd.isEmpty else {Toast.shareInstance().showView(self.view, title: "请输入密码!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let ip1 = IP1.text, !ip1.isEmpty else {
            Toast.shareInstance().showView(self.view, title: "请输入集团IP!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let ip2 = IP2.text, !ip2.isEmpty else {
            Toast.shareInstance().showView(self.view, title: "请输入集团IP!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let ip3 = IP3.text, !ip3.isEmpty else {
            Toast.shareInstance().showView(self.view, title: "请输入集团IP!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let ip4 = IP4.text, !ip4.isEmpty else {
            Toast.shareInstance().showView(self.view, title: "请输入集团IP!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        guard let port = IP5.text, !port.isEmpty else {
            Toast.shareInstance().showView(self.view, title: "请输入集团端口号!")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
            return
        }
        
        let ipport = "\(ip1).\(ip2).\(ip3).\(ip4):\(port)"
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        let alomo = Alamofire.SessionManager.default
        alomo.session.configuration.timeoutIntervalForRequest = 5.0
        
            let regex = "\\d{0,3}\\.\\d{0,3}\\.\\d{0,3}\\.\\d{0,3}\\:\\d{0,4}"
            let match = MyRegex(regex)
            if(match.match(ipport)){
                let pwd1 = pwd.MD5()
                let dev = UIDevice.current.modelName
                let type = "iOS"
                let lat = self.location?.latitude
                let lon = self.location?.longitude
                let str = "{\"lat\":\(lat!),\"lon\":\(lon!)}"
                let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                Alamofire.request(AuthenticationURL, method: .post, parameters: ["account":acc,"pwd":pwd1!,"ip":ipport,"type":type,"device":dev,"location":str,"version":currentVersion]).responseJSON(completionHandler: { (reponse) in
                    if reponse.result.isSuccess{
                        if let value = reponse.result.value{
                            let resultJson = JSON(value)
                            if resultJson["code"].intValue != 200{
//                                ToastView.instance.showToast(text: resultJson["msg"].stringValue, pos: .Bottom)
                                ToastView.instance.showToast(text: "IP不存在", pos: .Bottom)
                            }else{
                                let data = resultJson["data"]
                                let dic = data.dictionaryObject
//                                print("data-----------------\(data)")
                                Defaults.instance.setValue(forKey: "userInfo", forValue: dic)
                                IDH.setupCore(dic)
                                AppProvider.instance.setVersion()
                                let realm = try! Realm()
                                let groupIpModel = GroupIPModel()
                                groupIpModel.ip_port = ipport
                                groupIpModel.group_name = group_name
                                try! realm.write {
                                    realm.add(groupIpModel, update: true)
                                }
                                //homs03直接登录
                                if AppProvider.instance.appVersion == .homs03{
                                    UserDefaults.standard.set("homs03", forKey: "roleID")
                                    UserDefaults.standard.synchronize()
                                    self.deleteMapModel()
                                    let str = AppProvider.instance.providerLogin()
                                    let vc = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                                    self.present(vc, animated: true, completion: nil)
                                    loginOut = false
                                }else{
                                    let match = MyRegex("^[^\\u4e00-\\u9fa5]{0,}$")
                                    if(match.match(acc)){
                                        let url = "http://\(idh_ip_port)/Analyze.svc/GetRole/\(acc)/\(pwd1!)"
                                        print("++++++\(url)")
                                        var roleID = ""
                                        alomo.request(url, method: .get).responseJSON(completionHandler: { reponse in
                                            if reponse.result.isSuccess{
                                                let result = reponse.result.value as? NSDictionary
                                                if let role = result!["RoleID"]{
                                                    roleID = role as! String
                                                }
                                                if roleID.isEmpty{
                                                    //弹出页面
                                                    Toast.shareInstance().showView(self.view, title: "账号或密码有误!")
                                                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                                }else{
                                                    UserDefaults.standard.set(roleID, forKey: "roleID")
                                                    UserDefaults.standard.synchronize()
                                                    role_id = roleID
                                                    self.deleteMapModel()
                                                    AppProvider.instance.setVersion()
                                                    let str = AppProvider.instance.providerLogin()
                                                    var vc:UIViewController
                                                    if str == "home"{
//                                                        globalTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.alertVoice), userInfo: nil, repeats: true)
                                                        let main = UIStoryboard.init(name: "Home", bundle: nil)
                                                        vc = main.instantiateViewController(withIdentifier: "home")
                                                    }else{
                                                        vc = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                                                    }
                                                    Toast.shareInstance().showView(self.view, title: "登陆成功")
                                                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                                    self.present(vc, animated: true, completion: {
                                                        self.accountTF.text = nil
                                                        self.pwdTF.text = nil
                                                    })
                                                    loginOut = false
                                                }
                                            }else{
                                                Toast.shareInstance().showView(self.view, title:"该服务暂未开通，不支持登录")
                                                Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                                            }
                                        })
                                    }
                                }
                            }
                        }
                    }else{
                        Toast.shareInstance().showView(self.view, title:"网络请求失败，请稍后再试")
                        Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                    }
                })
                
            }else{
                Toast.shareInstance().showView(self.view, title: "IP格式不正确!")
                Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }
    }
    
    func deleteMapModel() {
        let realm = try! Realm()
        let obs = realm.objects(heatModel.self)
        try! realm.write {
            realm.delete(obs)
        }
        print(realm.objects(heatModel.self))
    }
    
    @objc func alertVoice() {
        
        let mute = UserDefaults.standard.bool(forKey: "mute")
        let minute = UserDefaults.standard.string(forKey: "time")
        
        guard !mute else {
            return
        }
//TODO: compare 30/15 to alarm info
        
                var compareDiff = 1800
        
                if let minuteSetting = minute, minuteSetting == "15"{
                    compareDiff = 900
                }
        var count:Int = 0
        
        let a = "http://113.140.66.34:6099/Analyze.svc/GetAlarmInformation/1"
        
        Alamofire.request(a).responseJSON { (reponse) in
            if reponse.result.isSuccess{
                let result = reponse.result.value
                let data = JSON(result)
                for (_,alarm) in data{
                    let model = AlarmModel.init(data: alarm)
                    let diff = (model.DiffSeconds! as NSString).integerValue
//                    if diff <= compareDiff{
                        count += 1
//                    }
                }
                
                if count > 0 {
//                    self.playNotification(count)
                }
            }else{
                return
            }
        }
        
//        if count > 0 {
//            playNotification(count)
//        }
        
        
//        let voicePath = Bundle.main.path(forResource: "alarm", ofType: "mp3")!
//        let voiceUrl = URL(fileURLWithPath: voicePath)
//        playerItem = AVPlayerItem.init(url: voiceUrl)
//        player = AVPlayer.init(playerItem: playerItem)
//        player?.play()
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
    }
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
    }
    
    func playNotification(_ count:Int) {
        let voicePath = Bundle.main.path(forResource: "alarm", ofType: "mp3")!
        let voiceUrl = URL(fileURLWithPath: voicePath)
        playerItem = AVPlayerItem.init(url: voiceUrl)
        player = AVPlayer.init(playerItem: playerItem)
        player?.play()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        let content = UNMutableNotificationContent()
        content.title = "通知"
        content.body = "共有\(count)条报警信息"
        content.badge = NSNumber.init(value: count)

        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let iden = "com.wangbo.notification"
        let request = UNNotificationRequest.init(identifier: iden, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error == nil {
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        accountTF.resignFirstResponder()
        pwdTF.resignFirstResponder()
        IP1.resignFirstResponder()
        IP2.resignFirstResponder()
        IP3.resignFirstResponder()
        IP4.resignFirstResponder()
        IP5.resignFirstResponder()
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
}

extension LoginViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last?.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        let alert = UIAlertController.init(title: "允许定位服务", message: "请在设置中打开定位", preferredStyle: .alert)
//        alert.addAction(UIAlertAction.init(title: "打开", style: .default, handler: nil))
//        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: MKDropdownMenuDataSource,MKDropdownMenuDelegate{
    func numberOfComponents(in dropdownMenu: MKDropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, rowHeightForComponent component: Int) -> CGFloat {
        return 0
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, numberOfRowsInComponent component: Int) -> Int {
        let groups = realm?.objects(GroupIPModel.self)
        return groups!.isEmpty ? 0 : groups!.count
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let drop = DropItemView()
        let a = realm?.objects(GroupIPModel.self)[row]
        drop.group.text = a?.group_name
        return drop
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, didSelectRow row: Int, inComponent component: Int) {
        self.operateIPS(text: (realm?.objects(GroupIPModel.self)[row].ip_port)!)
        dropdownMenu.reloadComponent(component)
        dropdownMenu.closeAllComponents(animated: true)
    }
    
    
    func operateIPS(text:String) {
        let arr = text.components(separatedBy: ".")
        IP1.text = arr[0]
        IP2.text = arr[1]
        IP3.text = arr[2]
        let arr1 = arr[3].components(separatedBy: ":")
        IP4.text = arr1[0]
        IP5.text = arr1[1]
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: "历史", attributes: [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10, weight: .regular)])
//        return NSAttributedString.init(string: "历史")
    }
    
    func dropdownMenu(_ dropdownMenu: MKDropdownMenu, attributedTitleForSelectedComponent component: Int) -> NSAttributedString? {
        return NSAttributedString.init(string: "历史", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1),NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10, weight: .regular)])
    }
}


extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 120)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateViewMoving(up: true, moveValue: 120)
    }
    
    
    
    
    
}
