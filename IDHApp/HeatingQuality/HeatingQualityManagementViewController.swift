//
//  HeatingQualityManagementViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/24.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class HeatingQualityManagementViewController: UIViewController {
    
    var main:UIViewController!
    var menu:UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        let quality = UIStoryboard.init(name: "HeatQualityStoryBoard", bundle: nil)
        
        let qua = quality.instantiateViewController(withIdentifier: "quality") as! HeatQualityViewController
        self.main = UINavigationController.init(rootViewController: qua)
        
        qua.backHome = {
            self.dismiss(animated: true, completion: nil)
        }
        
//        let reveal = self.revealViewController()
//        reveal?.panGestureRecognizer()
//        reveal?.tapGestureRecognizer()
        
        self.view.addSubview(self.main.view)
        
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
