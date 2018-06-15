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

//var glo = <#value#>


class LoginViewController: UIViewController {
    
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var IPTF: UITextField!
    //播放器相关
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        askNet()
        alertVoice()
    }
    
    func askNet() {
        Alamofire.request("http://www.baidu.com")
    }
    
    func setUp() {
        pwdTF.delegate = self
        accountTF.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        let alomo = Alamofire.SessionManager.default
        alomo.session.configuration.timeoutIntervalForRequest = 5.0
        
        AppProvider.instance.setVersion()
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
