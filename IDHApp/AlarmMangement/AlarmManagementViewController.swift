//
//  AlarmManagementViewController.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/23.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//





import UIKit



// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}

class AlarmManagementViewController: UIViewController {
    var mainVC:UIViewController?
    var menuVC:UIViewController?
    
    //滑动速率
    var speed:CGFloat = 0.5
    //条判断什么时候显示中间的view什么时候显示右边的view
    var condition:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let alarmStory = UIStoryboard.init(name: "AlarmStoryBoard", bundle: nil)
        
        let menu = alarmStory.instantiateViewController(withIdentifier: "menu")
        let main = alarmStory.instantiateViewController(withIdentifier: "alarm") as! AlarmViewController
        self.menuVC = UINavigationController.init(rootViewController: menu)
        self.view.addSubview((self.menuVC?.view)!)
        main.backHomeClosure = {
            self.dismiss(animated: true, completion: nil)
        }
        
        self.mainVC = UINavigationController.init(rootViewController: main)
        self.view.addSubview((self.mainVC?.view)!)
        
        self.menuVC?.view.isHidden = true
        
        //添加滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(showRightMenu(_:)))
        self.mainVC?.view.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
    }
    
    //滑动显示右侧菜单
    @objc func showRightMenu(_ sender:UIPanGestureRecognizer){
        //获取手指的位置
        let point = sender.translation(in: sender.view)
        
        if sender.view?.frame.origin.x <= 0
        {
            condition = point.x * self.speed + condition
            
            sender.view?.center = CGPoint(x: (sender.view?.center.x)! + point.x * speed, y: (sender.view?.center.y)!)
            sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
            self.menuVC?.view.isHidden = false
        }
        
        //当手指离开屏幕时
        if sender.state == .ended {
            UIView.beginAnimations(nil, context: nil)
            
            if condition < UIScreen.main.bounds.width * CGFloat(-0.5) * speed {
                mainVC?.view.center = CGPoint(x: CGFloat(150) - UIScreen.main.bounds.size.width * CGFloat(0.5), y: UIScreen.main.bounds.size.height/2)
            }
            else {
                mainVC?.view.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
            }
            //滑完后条件归零
            condition = 0
            UIView.commitAnimations()
        }
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
