//
//  HeatFactoryTabBarControllerViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/17.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class HeatFactoryTabBarControllerViewController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
//        let heatFactoryStoryBoard = UIStoryboard(name: "TabbarStoryboard", bundle: nil)
//        //
//        let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "HomsMonitor")
//                let trendController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "trend")
//                let energyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "energy")
//                let surveyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "survey")
//                let qualityController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "quality")
        //
        //        //设置选项卡的选中与反选中背景图片
        self.navigationController?.navigationBar.isTranslucent = false
//        monitorController.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
//        self.viewControllers?.insert(monitorController, at: 0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back").withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "back_factory"), style: .done, target: self, action: #selector(toTrans))
//        //创建监控画面、运行趋势、能耗、概况、供热质量分析控制器
        let heatFactoryStoryBoard = UIStoryboard(name: "TabbarStoryboard", bundle: nil)
//
        let monitorController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "HomsMonitor")
        let trendController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "trend")
        let energyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "energy")
        let surveyController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "survey")
        let qualityController = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "quality")
        
        let monitorIdhAndHoms = MonitorViewController()
        
        monitorIdhAndHoms.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
        
//        //设置选项卡的选中与反选中背景图片
        monitorController.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
        trendController.tabBarItem = UITabBarItem(title: "运行趋势", image: UIImage(named: "heat_btn_trend_unselect"), selectedImage: UIImage(named: "heat_btn_trend_select"))
        energyController.tabBarItem = UITabBarItem(title: "能耗", image: UIImage(named: "heat_btn_power_unselect"), selectedImage: UIImage(named: "heat_btn_power_select"))
        surveyController.tabBarItem = UITabBarItem(title: "概况", image: UIImage(named: "heat_btn_survey_unselect"), selectedImage: UIImage(named: "heat_btn_survey_select"))
//
        qualityController.tabBarItem = UITabBarItem(title: "供热质量", image: UIImage(named: "heat_btn_qu_unselect"), selectedImage: UIImage(named: "heat_btn_qu_select"))
//        self.tabBar.barTintColor = UIColor.gray
        self.tabBar.isTranslucent = false
//        //消除滚动视图与导航栏、标签栏的垂直空隙
        self.automaticallyAdjustsScrollViewInsets = false
//
//        //添加到工具栏
//        self.viewControllers?.insert(monitorController, at: 0)
        AppProvider.instance.setVersion()
        factoryMonitor = true
        if AppProvider.instance.appVersion == .idh {
            self.viewControllers = [monitorController,trendController,energyController,surveyController,qualityController]
        }else{
            Tools.setMonitors(heatFactoryID,isFactor: true)
            //            let monitorIdhAndHoms = heatFactoryStoryBoard.instantiateViewController(withIdentifier: "EMixMonitor")
            //            monitorIdhAndHoms.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            ////            Tools.setMonitors(heatExchangerID, myVC: monitorIdhAndHoms)
            
            let heatStoryBoard = UIStoryboard(name: "MixMonitorVC", bundle: nil)
            let monitor = heatStoryBoard.instantiateViewController(withIdentifier: "excMixMonitor")
            monitor.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
            self.viewControllers = [monitor,trendController,energyController,surveyController,qualityController]
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toTrans() {
        switch self.selectedIndex {
        case 0:
            globalFromVC = .heatFactoryMonitor
        case 1:
            globalFromVC = .heatFactoryTrend
        case 2:
            globalFromVC = .heatFactoryEnergy
        case 3:
            globalFromVC = .heatFactorySurvey
        case 4:
            globalFromVC = .heatFactoryQuality
        default:
            return
        }
        let trans = TransferViewController.newInstance()
//        let nav = UINavigationController.init(rootViewController: trans)
//        self.present(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(trans, animated: true)
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
