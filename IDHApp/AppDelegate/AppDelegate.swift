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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //        registWX()
        RealmUtil.configurRealm()
        //        openDB()
        setupAppearance()
                if let user = Defaults.instance.getForKey(key: "userInfo") {
        IDH.setupCore(user)
        provider.setVersion()
        
        if UserDefaults.standard.value(forKey: "roleID") != nil {
            let str = provider.providerLogin()
            role_id = UserDefaults.standard.value(forKey: "roleID") as! String
            if provider.appVersion == .homs03 || provider.appVersion == .homsOther{
                //初始加载
                let nav = UINavigationController.init(rootViewController: IDH.getVCFromStr(str))
                self.window?.rootViewController = nav
            }else{
                toHome()
            }
        }
                }else{
                    self.window?.rootViewController = AlertViewController()
                }
        return true
    }
    
    func toHome() {
        let main = UIStoryboard.init(name: "Home", bundle: nil)
        let home = main.instantiateViewController(withIdentifier: "home")
        self.window?.rootViewController = home
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

