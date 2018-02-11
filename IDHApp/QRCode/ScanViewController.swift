//
//  NewScanViewController.swift
//  Activation
//
//  Created by shuoren on 2018/1/18.
//  Copyright © 2018年 shuoren. All rights reserved.
//

import UIKit
import AVFoundation

import CryptoSwift

let kMargin = 35
let kBorderW = 140
let scanViewW = UIScreen.main.bounds.width - CGFloat(kMargin * 2)
let scanViewH = UIScreen.main.bounds.width - CGFloat(kMargin * 2)

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,
UIAlertViewDelegate{
    
    var scanRectView:UIView!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!

    var scanView: UIView? = nil
    var scanImageView: UIImageView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMaskView() //设置遮罩
        self.setupScanView() //设置扫描框
        self.scaning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetAnimatinon), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            self.resetAnimatinon() //开始扫描动画

    }
    
    /// 扫描区域设置
    fileprivate func setupScanView() {
        
        scanView = UIView(frame: CGRect(x: CGFloat(kMargin), y: CGFloat((view.bounds.height - scanViewW) / 2), width: scanViewW, height: scanViewH))
        scanView?.backgroundColor = UIColor.clear
        scanView?.clipsToBounds = true
        view.addSubview(scanView!)
        
        scanImageView = UIImageView(image: UIImage.init(named: "sweep_bg_line.png"));
        let widthOrHeight: CGFloat = 18
        
        let topLeft = UIButton(frame: CGRect(x: 0, y: 0, width: widthOrHeight, height: widthOrHeight))
        topLeft.setImage(UIImage.init(named: "sweep_kuangupperleft.png"), for: .normal)
        scanView?.addSubview(topLeft)
        
        let topRight = UIButton(frame: CGRect(x: scanViewW - widthOrHeight, y: 0, width: widthOrHeight, height: widthOrHeight))
        topRight.setImage(UIImage.init(named: "sweep_kuangupperright.png"), for: .normal)
        scanView?.addSubview(topRight)
        
        let bottomLeft = UIButton(frame: CGRect(x: 0, y: scanViewH - widthOrHeight, width: widthOrHeight, height: widthOrHeight))
        bottomLeft.setImage(UIImage.init(named: "sweep_kuangdownleft.png"), for: .normal)
        scanView?.addSubview(bottomLeft)
        
        let bottomRight = UIButton(frame: CGRect(x: scanViewH - widthOrHeight, y: scanViewH - widthOrHeight, width: widthOrHeight, height: widthOrHeight))
        bottomRight.setImage(UIImage.init(named: "sweep_kuangdownright.png"), for: .normal)
        scanView?.addSubview(bottomRight)
        
        let back_btn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width/2 - 30, y: UIScreen.main.bounds.height - 40, width: 60, height: 30))
        back_btn.setTitle("返回", for: .normal)
        back_btn.setTitleColor(UIColor.black, for: .normal)
        back_btn.backgroundColor = UIColor.white
        back_btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(back_btn)
    }
    
    //返回
    @objc func back(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 整体遮罩设置
    fileprivate func setupMaskView() {
        let maskView = UIView(frame: CGRect(x: -(view.bounds.height - view.bounds.width) / 2, y: 0, width: view.bounds.height, height: view.bounds.height))
        maskView.layer.borderWidth = (view.bounds.height - scanViewW) / 2
        maskView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        view.addSubview(maskView)
    }
    

    
    ///重置动画
    @objc fileprivate func resetAnimatinon() {
        let anim = scanImageView?.layer.animation(forKey: "translationAnimation")
        if (anim != nil) {
            //将动画的时间偏移量作为暂停时的时间点
            let pauseTime = scanImageView?.layer.timeOffset
            //根据媒体时间计算出准确的启动时间,对之前暂停动画的时间进行修正
            let beginTime = CACurrentMediaTime() - pauseTime!
            ///便宜时间清零
            scanImageView?.layer.timeOffset = 0.0
            //设置动画开始时间
            scanImageView?.layer.beginTime = beginTime
            scanImageView?.layer.speed = 1.1
        } else {
            
            let scanImageViewH = 241
            let scanViewH = view.bounds.width - CGFloat(kMargin) * 2
            let scanImageViewW = scanView?.bounds.width
            
            scanImageView?.frame = CGRect(x: 0, y: -scanImageViewH, width: Int(scanImageViewW!), height: scanImageViewH)
            let scanAnim = CABasicAnimation()
            scanAnim.keyPath = "transform.translation.y"
            scanAnim.byValue = [scanViewH]
            scanAnim.duration = 1.8
            scanAnim.repeatCount = MAXFLOAT
            scanImageView?.layer.add(scanAnim, forKey: "translationAnimation")
            scanView?.addSubview(scanImageView!)
        }
    }
    
    //通过摄像头扫描
     fileprivate  func scaning(){
        do{
            self.device = AVCaptureDevice.default(for: AVMediaType.video)
            
            self.input = try AVCaptureDeviceInput(device: device)
            
            self.output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            self.session = AVCaptureSession()
            if UIScreen.main.bounds.size.height<500 {
                self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
            }else{
                self.session.sessionPreset = AVCaptureSession.Preset.high
            }
            
            self.session.addInput(self.input)
            self.session.addOutput(self.output)
            
            self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //计算中间可探测区域
            let windowSize = UIScreen.main.bounds.size
            let scanSize = CGSize(width:windowSize.width*3/4, height:windowSize.width*3/4)
            var scanRect = CGRect(x:(windowSize.width-scanSize.width)/2,
                                  y:(windowSize.height-scanSize.height)/2,
                                  width:scanSize.width, height:scanSize.height)
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                              y:scanRect.origin.x/windowSize.width,
                              width:scanRect.size.height/windowSize.height,
                              height:scanRect.size.width/windowSize.width);
            //设置可探测区域
            self.output.rectOfInterest = scanRect
            
            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.preview.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preview, at:0)
            
            
            //开始捕获
            self.session.startRunning()
        }catch _ {
            //打印错误消息
            let alertController = UIAlertController(title: "提醒",
                                                    message: "请在iPhone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //摄像头捕获
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
        self.Decode_AES_ECB(strToDecode: stringValue!)
//        self.dismiss(animated: true, completion: nil)
    }
    
    func Decode_AES_ECB(strToDecode:String)
    {
        do {
//            let key = "1101121191221200"
            print("key密钥：\(key)")
//            //使用AES-128-ECB加密模式
            let aes = try AES(key: key.bytes, blockMode: .ECB)
            
            //开始解密
            let strBytes:[UInt8] =  Array.init(base64: strToDecode)
            print(strBytes)
            let decrypted = try aes.decrypt(strBytes)
            let data = Data.init(bytes: decrypted)
            do{
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let dic = json as! Dictionary<String, Any>
                
                if dic.contain(["version"]){
                    Defaults.instance.setValue(forKey: "userInfo", forValue: dic)
                    IDH.setupCore(Defaults.instance.getForKey(key: "userInfo") as Any)
                    
                    let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
                    let login = storyboard.instantiateViewController(withIdentifier: "login")
                    self.present(login, animated: true, completion: nil)
                
                }else{
                    let alert = UIAlertController.init(title: "失败", message: "请扫描正确的二维码", preferredStyle: .alert)
                    let action = UIAlertAction.init(title: "完成", style: .default, handler: { (action) in
                        self.session.startRunning()
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            } catch {
                print("失败")
                let alert = UIAlertController.init(title: "失败", message: "请重新扫描二维码", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "完成", style: .default, handler: { (action) in
                    self.session.startRunning()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            print("解密结果：\(String(data: Data(decrypted), encoding: .utf8)!)")
            
        } catch {
            
            let alert = UIAlertController.init(title: "失败", message: "请扫描正确的二维码", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "完成", style: .default, handler: { (action) in
                self.session.startRunning()
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension Dictionary{
    func contain(_ keys: [Key]) -> Bool {
        for key in keys {
            if !self.keys.contains(key){
                return false
            }
        }
        return true
    }
}
