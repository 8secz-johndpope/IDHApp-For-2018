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

class LoginViewController: UIViewController {

    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var accountTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
//        isNeedScan()
    }
    
//    func isNeedScan() {
//        if let user = Defaults.instance.getForKey(key: "userInfo"){
//        }else{
//            let alert = UIAlertController.init(title: "去扫码", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction.init(title: "scan code", style: .default, handler: { (action) in
//                self.present(AlertViewController(), animated: true, completion: nil)
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }

    func setUp() {
        pwdTF.delegate = self
        accountTF.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        AppProvider.instance.setVersion()
        if AppProvider.instance.appVersion == .homs03 {
            let str = AppProvider.instance.providerLogin()
            let vc = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
            self.present(vc, animated: true, completion: nil)
        }else{

        if let user = accountTF.text, let pwd = pwdTF.text {
            let match = MyRegex("^[^\\u4e00-\\u9fa5]{0,}$")
            if(match.match(user)){
                let url = "http://\(idh_ip_port)/Analyze.svc/GetRole/\(user)/\(pwd.MD5()!)"
                print("\(url)")
                var roleID = ""
                
                Alamofire.request(url, method: .get).responseJSON(completionHandler: { reponse in
                    if reponse.result.isSuccess{
                        let result = reponse.result.value as? NSDictionary
                        if let role = result!["RoleID"]{
                            roleID = role as! String
                        }
                        if roleID.isEmpty{
                            //弹出页面
                    Toast.shareInstance().showView(self.view, title: "用户名和密码有误")
                    Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                        }else{
                                UserDefaults.standard.set(roleID, forKey: "roleID")
                                UserDefaults.standard.synchronize()
                                role_id = roleID
                            AppProvider.instance.setVersion()
                            let str = AppProvider.instance.providerLogin()
                            var vc:UIViewController
                            if str == "home"{
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
                        print("\(reponse)")
                        Toast.shareInstance().showView(self.view, title:"登录失败")
                        Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
                    }
                    })
            }
        }else{
            Toast.shareInstance().showView(self.view, title: "请输入用户名和密码！")
            Thread.detachNewThreadSelector(#selector(self.hidenThreadView), toTarget: self, with: nil)
        }
            
        }
        
    }
    
    @objc func alertVoice() {
        }
    
    //隐藏Toast提示并销毁其中的定时器
    @objc func hidenThreadView(){
        Thread.sleep(forTimeInterval: 1.5)
        Toast.shareInstance().hideView()
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

}


extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
