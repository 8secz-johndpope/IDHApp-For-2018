//
//  HeatExchangerTabBarController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/28.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class HeatExchangerTabBarController: UITabBarController {
    static let instance = HeatExchangerTabBarController()
//
//    private init(){
//        super.init()
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    /**
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        //        //创建监控画面、运行趋势、能耗、概况、供热质量分析控制器
        let heatFactoryStoryBoard = UIStoryboard(name: "ExchangerTabBar", bundle: nil)
        //
        //        let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excMonitor")
        let trendController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "trend")
        let energyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excAna")
        let surveyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "survey")
        let qualityController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "quality")
        trendController.tabBarItem = UITabBarItem(title: "运行趋势", image: UIImage(named: "heat_btn_trend_unselect"), selectedImage: UIImage(named: "heat_btn_trend_select"))
        energyController.tabBarItem = UITabBarItem(title: "能耗", image: UIImage(named: "heat_btn_power_unselect"), selectedImage: UIImage(named: "heat_btn_power_select"))
        surveyController.tabBarItem = UITabBarItem(title: "概况", image: UIImage(named: "heat_btn_survey_unselect"), selectedImage: UIImage(named: "heat_btn_survey_select"))
        //
        qualityController.tabBarItem = UITabBarItem(title: "供热质量", image: UIImage(named: "heat_btn_qu_unselect"), selectedImage: UIImage(named: "heat_btn_qu_select"))
        //        self.tabBar.barTintColor = UIColor.gray
        self.tabBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        //
        //        //添加到工具栏
        //        self.viewControllers?.insert(monitorController, at: 0)
        AppProvider.instance.setVersion()
        if AppProvider.instance.appVersion == .idh {
            let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excMonitor")
            monitorController.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            self.viewControllers = [monitorController,trendController,energyController,surveyController,qualityController]
        }else{
            //            if heatExchangerID.isEmpty{
            //                heatExchangerID = exchangersArr[0].ID
            //                heatExchangerName = exchangersArr[0].Name
            //            }
            
            Tools.setMonitors(heatExchangerID,isFactor: false)
            
            
            //            let monitorIdhAndHoms = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "EMixMonitor")
            //            monitorIdhAndHoms.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            ////            Tools.setMonitors(heatExchangerID, myVC: monitorIdhAndHoms)
            
            let heatStoryBoard = UIStoryboard(name: "MixMonitorVC", bundle: nil)
            let monitor = heatStoryBoard.instantiateViewController(withIdentifier: "excMixMonitor")
            monitor.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            self.viewControllers = [monitor,trendController,energyController,surveyController,qualityController]
        }
    }
 **/

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
        //        //创建监控画面、运行趋势、能耗、概况、供热质量分析控制器
        let heatFactoryStoryBoard = UIStoryboard(name: "ExchangerTabBar", bundle: nil)
        //
        //        let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excMonitor")
        let trendController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "trend")
        let energyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excAna")
        let surveyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "survey")
        let qualityController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "quality")
        trendController.tabBarItem = UITabBarItem(title: "运行趋势", image: UIImage(named: "heat_btn_trend_unselect"), selectedImage: UIImage(named: "heat_btn_trend_select"))
        energyController.tabBarItem = UITabBarItem(title: "能耗", image: UIImage(named: "heat_btn_power_unselect"), selectedImage: UIImage(named: "heat_btn_power_select"))
        surveyController.tabBarItem = UITabBarItem(title: "概况", image: UIImage(named: "heat_btn_survey_unselect"), selectedImage: UIImage(named: "heat_btn_survey_select"))
        //
        qualityController.tabBarItem = UITabBarItem(title: "供热质量", image: UIImage(named: "heat_btn_qu_unselect"), selectedImage: UIImage(named: "heat_btn_qu_select"))
        //        self.tabBar.barTintColor = UIColor.gray
        self.tabBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        factoryMonitor = false
        
        //        //添加到工具栏
        //        self.viewControllers?.insert(monitorController, at: 0)
        AppProvider.instance.setVersion()
        if AppProvider.instance.appVersion == .idh {
            let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "excMonitor")
            monitorController.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            self.viewControllers = [monitorController,trendController,energyController,surveyController,qualityController]
        }else{
            //            if heatExchangerID.isEmpty{
            //                heatExchangerID = exchangersArr[0].ID
            //                heatExchangerName = exchangersArr[0].Name
            //            }
            if group_name == "西安市热力"{
            }else{
                Tools.setMonitors(heatExchangerID,isFactor: false)
            }
            //            let monitorIdhAndHoms = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "EMixMonitor")
            //            monitorIdhAndHoms.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            ////            Tools.setMonitors(heatExchangerID, myVC: monitorIdhAndHoms)
            
            let heatStoryBoard = UIStoryboard(name: "MixMonitorVC", bundle: nil)
            let monitor = heatStoryBoard.instantiateViewController(withIdentifier: "excMixMonitor")
            monitor.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            self.viewControllers = [monitor,trendController,energyController,surveyController,qualityController]
        }
    }
    
//    @objc func back(){
//        let home = UIStoryboard.init(name: "Home", bundle: nil)
//        let vc = home.instantiateViewController(withIdentifier: "home")
//        self.present(vc, animated: true, completion: nil)
//    }

        @objc func toTrans() {
            switch self.selectedIndex {
            case 0:
                globalFromVC = .heatExchangerMonitor
            case 1:
                globalFromVC = .heatExchangerTrend
            case 2:
                globalFromVC = .heatExchangerEnergy
            case 3:
                globalFromVC = .heatExchangerSurvey
            case 4:
                globalFromVC = .heatExchangerQuality
            default:
                return
            }
            
            let transSB = UIStoryboard(name: "Transfer", bundle: nil)
            let trans = transSB.instantiateViewController(withIdentifier: "transfer")
//            let trans = TransferViewController.newInstance()
            
//            let nav = UINavigationController.init(rootViewController: trans)
            self.navigationController?.pushViewController(trans, animated: true)
//            self.present(nav, animated: true, completion: nil)
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func back() {
//        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
//        self.dis
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
