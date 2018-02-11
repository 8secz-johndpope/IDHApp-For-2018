//
//  HeatExchangerTabBarControllerViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/29.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//


//Just for funture IDH coding

import UIKit

class HeatExchangerTabBarControllerViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let exchangerSB = UIStoryboard.init(name: "HomsExchanger", bundle: nil)
        let monitorController = exchangerSB.instantiateViewController(withIdentifier: "HomsMonitor")
        monitorController.tabBarItem = UITabBarItem(title: "监控画面", image: UIImage(named: "heat_btn_look_unselect"), selectedImage: UIImage(named: "heat_btn_look_select"))
        self.viewControllers = [monitorController, monitorController, monitorController, monitorController]
        
        // Do any additional setup after loading the view.
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
