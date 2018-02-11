//
//  WorkingFactoryContainerViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/26.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit

class WorkingFactoryContainerViewController: UIViewController {
    
    var mainController: UIViewController?
    var rightController: UIViewController?
    
    var speed:CGFloat = 0.5
    var condition:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let factorStoryBoard = UIStoryboard(name: "Storyboard", bundle: nil)
        
        let menuController = factorStoryBoard.instantiateViewController(withIdentifier: "menu")
        self.rightController = UINavigationController(rootViewController: menuController)
        
        self.rightController?.navigationController?.navigationBar.barTintColor = UIColor.red
        self.view.addSubview((self.rightController?.view)!)
        
        let factorController = factorStoryBoard.instantiateViewController(withIdentifier: "main")
        self.mainController = UINavigationController(rootViewController: factorController)
        self.view.addSubview((self.mainController?.view)!)
        
        self.rightController?.view.isHidden = true
        
        //添加滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(showRightMenu(_:)))
        self.mainController?.view.addGestureRecognizer(panGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedName(_:)), name: NSNotification.Name(rawValue: "working"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedName(_:)), name: NSNotification.Name(rawValue: "mode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar(_:)), name: NSNotification.Name(rawValue: "hideFactor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBar(_:)), name: NSNotification.Name(rawValue: "showFactor"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(showHomePage(_:)), name: NSNotification.Name(rawValue: "showHome"), object: nil)
    }
    
    //进入到下一级界面时隐藏TabBar
    @objc func hideTabBar(_ sender:Notification)
    {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //返回到本级界面时显示TabBar
    @objc func showTabBar(_ sender:Notification)
    {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //返回到首页
    @objc func showHomePage(_ sender:Notification)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //选中右侧菜单中的某一项时隐藏右侧菜单
    @objc func selectedName(_ sender:Notification)
    {
        UIView.beginAnimations(nil, context: nil)
        
        mainController?.view.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        
        UIView.commitAnimations()
    }
    
    @objc func showRightMenu(_ sender: UIPanGestureRecognizer) {
        //防止此级下的子页面还能侧滑
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            //获取手指的位置
            let point = sender.translation(in: sender.view)
            
            if (sender.view?.frame.origin.x)! <= CGFloat(0)
            {
                condition = point.x * self.speed + condition
                
                sender.view?.center = CGPoint(x: (sender.view?.center.x)! + point.x * speed, y: (sender.view?.center.y)!)
                sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                
                self.rightController?.view.isHidden = false
            }
            
            //当手指离开屏幕时
            if sender.state == .ended {
                UIView.beginAnimations(nil, context: nil)
                
                if condition < UIScreen.main.bounds.width * CGFloat(-0.5) * speed {
                    mainController?.view.center = CGPoint(x: CGFloat(150) - UIScreen.main.bounds.size.width * CGFloat(0.5), y: UIScreen.main.bounds.size.height/2)
                }
                else {
                    mainController?.view.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
                }
                
                //滑完后条件归零
                condition = 0
                UIView.commitAnimations()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
