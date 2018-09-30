//
//  AppDelegate.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/19.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import KissXML
import SwiftyJSON

enum themeMode:Int {
    case day = 0
    case night
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var landscape: Bool = false
    var provider = AppProvider.instance
    var brightnessValue:CGFloat = 0
    var nightMode:themeMode = .day
    
//    let notificationHandler = NotificationHandler()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        requestNotification()
        
//        openDB()
        
        RealmUtil.configurRealm()
        setupAppearance()
        registWX()
        
//        if let user = Defaults.instance.getForKey(key: "userInfo") {
//        IDH.setupCore(user)
//        provider.setVersion()
//        registWX()
//        checkVersion()

        if let user = Defaults.instance.getForKey(key: "userInfo"){
            if UserDefaults.standard.value(forKey: "roleID") != nil{
                IDH.setupCore(user)
                provider.setVersion()
                let str = provider.providerLogin()
                role_id = UserDefaults.standard.value(forKey: "roleID") as! String
                if provider.appVersion == .homs03 || provider.appVersion == .homsOther{
                    let nav = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                    self.window?.rootViewController = nav
                }else{
                    toHome()
                }
            }
        }
//                }else{
//                    self.window?.rootViewController = AlertViewController()
//                }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func requestNotification() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("允许通知")
                return
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (accepted, error) in
                    if !accepted{
//                        ToastView.instance.showToast(text: "通知", pos: .Mid)
                    }
                }
            case .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    let alert = UIAlertController.init(title: "消息推送已关闭", message: "想要获取消息，点击设置，开启通知权限", preferredStyle: .alert)
                    let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                    let set = UIAlertAction.init(title: "设置", style: .default, handler: { (action) -> Void in
                        let url = URL.init(string: UIApplicationOpenSettingsURLString)
                        if let u = url, UIApplication.shared.canOpenURL(u){
                            UIApplication.shared.open(u, options: [:], completionHandler: { (sucess) in
                                
                            })
                        }
                    })
                    
                    alert.addAction(cancel)
                    alert.addAction(set)
//                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                })
                
            }
        }
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (accepted, error) in
//            <#code#>
//        }
    }
    
    
    
    //版本监测
    func checkVersion() {
            let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        print("\(currentVersion)")
        Alamofire.request(ChecekUpdateURL, method: .post, parameters: ["version": currentVersion, "type": "ios", "name": "IDH"]).responseJSON { reponse in
            if reponse.result.isSuccess{
                let result = reponse.result.value as? NSDictionary
                if let update = result!["is_update"]{
                    let updated = update as! Bool
                    if updated{
                        let data = result!["data"] as! NSDictionary
                        let url = data["url"] as! String
                        let toast = result!["toast"] as! String
                        let is_must = data["is_must"] as! Bool
                        self.alertNewVersion(url: url, is_must, toast)
                    }
                }
            }else{
                print("访问失败")
            }
        }
    }
    
    func alertNewVersion(url:String, _ is_must: Bool = false, _ toast: String){
        let alertController = UIAlertController(title: "提示",
                                                message: "\(toast)", preferredStyle: .alert)
        if !is_must {
            let cancle = UIAlertAction(title: "暂不更新", style: .cancel, handler: nil)
            alertController.addAction(cancle)
        }
        
        let okAction = UIAlertAction(title: "立即更新", style: .default, handler: {
            action in
            if let u = URL(string: url){
                    UIApplication.shared.open(u, options: [:], completionHandler: nil)
            }
        })
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    func toHome() {
        let main = UIStoryboard.init(name: "Home", bundle: nil)
        let home = main.instantiateViewController(withIdentifier: "home")
        self.window?.rootViewController = home
        
//        let home = UIStoryboard(name: "TabbarStoryboard", bundle: nil).instantiateViewController(withIdentifier: "facbar") as! UITabBarController
//        self.window?.rootViewController = home
    }
    
    
    func isFirstLaunch() -> Bool{
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppFirstLaunch") != nil {
            return false
        }else{
            defaults.set(false, forKey: "isAppFirstLaunch")
            return true
        }
        
    }
    func openDB(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red: CGFloat(0)/255.0, green: CGFloat(178)/255.0, blue: CGFloat(178)/255.0, alpha: CGFloat(1.0))
        UITabBar.appearance().backgroundColor = UIColor.gray
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        brightnessValue = UIScreen.main.brightness
        UIApplication.shared.statusBarStyle = .default
        #if Debug
            print("debug")
        #else
            print("release")
        #endif
    }
    
    func registWX() {
        WXApi.registerApp("wx5d9d3f6590fd96f2")
    }
    
    /*
     func registJpush(options: [UIApplicationLaunchOptionsKey: Any]?) {
     
     let entity = JPUSHRegisterEntity()
     
     entity.types = Int(JPAuthorizationOptions.alert.rawValue)
     
     JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
     JPUSHService.setup(withOption: options, appKey: "example", channel: "", apsForProduction: true, advertisingIdentifier: nil)
     }
     
     func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
     let userinfo = notification.request.content.userInfo
     
     JPUSHService.handleRemoteNotification(userinfo)
     completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
     }
     
     func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
     let userinfo = response.notification.request.content.userInfo
     JPUSHService.handleRemoteNotification(userinfo)
     completionHandler()
     
     }
     
     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
     print("\(error)")
     }
     
     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     JPUSHService.registerDeviceToken(deviceToken)
     }
     */
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return landscape ? UIInterfaceOrientationMask.landscapeRight : UIInterfaceOrientationMask.portrait
    }
    func applicationWillResignActive(_ application: UIApplication) {
        nightMode = .day
        UIScreen.main.brightness = brightnessValue
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        //        application.cancelAllLocalNotifications()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

extension AppDelegate:UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.body)
        print(response.notification.request.content.title)
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = 0
//        let a = RootTabBarController()
//        a.selectedIndex = 3
        //        NotificationHandler
        //        UIApplication.shared.windows.first?.rootViewController
        //        self.window?.rootViewController?.present(a, animated: true, completion: nil)
//        self.window?.rootViewController? = a
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
        UIApplication.shared.applicationIconBadgeNumber = 10
    }
}

//class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print(response.notification.request.content.body)
//        print(response.notification.request.content.title)
//        let userInfo = response.notification.request.content.userInfo
//        print(userInfo)
//        let a = RootTabBarController()
//        a.selectedIndex = 3
////        NotificationHandler
////        UIApplication.shared.windows.first?.rootViewController
////        self.window?.rootViewController?.present(a, animated: true, completion: nil)
//        completionHandler()
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound, .badge])
//    }
//}

