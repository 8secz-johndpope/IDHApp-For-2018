//
//  Toast.swift
//  IDHApp
//
//  Created by boolean_wang on 2017/12/22.
//  Copyright © 2017年 SR_TIMES. All rights reserved.
//

import UIKit
import Foundation

struct YMSingleton{
    static var predicate:Int = 0
    static var instance:Toast? = nil
}

class Toast: UIView {
    private static var __once: () = {
        YMSingleton.instance = Toast(frame: CGRect.zero)
    }()
    var loadingLab:UILabel!
    var masks:UIView!
    var timer:Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 1
        self.isOpaque = false
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = 10;
        self.layer.borderColor = UIColor.gray.cgColor;
        self.backgroundColor = UIColor.clear
        
        let point:CGPoint  = self.center
        self.frame = CGRect(x: point.x-120,y: point.y-15, width: 240, height: 30)
        
        let tmpView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 30))
        tmpView.backgroundColor = UIColor.black
        tmpView.alpha = 0.5
        tmpView.layer.masksToBounds = true;
        tmpView.layer.cornerRadius = 10;
        self.addSubview(tmpView)
        
        loadingLab = UILabel(frame: CGRect(x: 0, y: 5, width: 240, height: 20));
        loadingLab.backgroundColor = UIColor.clear;
        loadingLab.textAlignment = NSTextAlignment.center
        loadingLab.textColor = UIColor.white
        loadingLab.font = UIFont.systemFont(ofSize: 15);
        self.addSubview(loadingLab)
        
        //添加超时定时器
        timer = Timer(timeInterval: 30, target: self, selector: #selector(timerDeadLine), userInfo: nil, repeats: false)
    }
    
    class func shareInstance() -> Toast{
        
        _ = Toast.__once
        
        return YMSingleton.instance!
    }
    
    func showView(_ view:UIView , title:String) {
        loadingLab.text = title
        
        if masks==nil {
            masks = UIView(frame: UIScreen.main.bounds)
            masks.backgroundColor = UIColor.clear
            masks.addSubview(self)
            UIApplication.shared.keyWindow?.addSubview(masks)
            self.center = view.center
            masks.alpha = 1
        }
        
        masks.isHidden = false
        
        if timer != nil {
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
    }
    
    @objc func timerDeadLine(){
        self.hideView()
    }
    
    func hideView() {
        if Thread.current.isMainThread{
            self.removeView()
        }
        else {
            DispatchQueue.main.async(execute: { () -> Void in
                self.removeView()
            })
        }
    }
    
    func removeView(){
        if masks != nil {
            masks.isHidden = true
            timer.invalidate()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}
