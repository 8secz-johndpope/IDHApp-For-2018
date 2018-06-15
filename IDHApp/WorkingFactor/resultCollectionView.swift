////
////  resultCollectionView.swift
////  IDHApp
////
////  Created by boolean_wang on 2018/4/3.
////  Copyright © 2018年 SR_TIMES. All rights reserved.
////
//
//import UIKit
//
//class resultCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewFlowLayout {
//    var collectionView:UICollectionView?
//
//    var model:HFModel?{
//        didSet{
//            self.reloadData()
//        }
//    }
//
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        super.init(frame: frame, collectionViewLayout: layout)
//
//        self.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identify.header)
//        self.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
////        collectionView.dat
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let fac = model {
//            if fac.isHaveGroup{
//                return fac.groups[section].exchangers.count
//            }else{
//                return fac.heatExchangers.count
//            }
//        }
//        return 0
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        if (self.model?.isHaveGroup)! {
//            return (self.model?.groups.count)!
//        }else{
//            return 1
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
//
//        cell.exchangerModel = (self.model?.isHaveGroup)! ? self.model?.groups[indexPath.section].exchangers[indexPath.row] : self.model?.heatExchangers[indexPath.row]
//
//        return cell
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identify.header, for: indexPath) as! CollectionReusableView
//        if let fac = model {
//            if fac.isHaveGroup{
//                view.factoryTitle.text = fac.groups[indexPath.section].Name
//            }else{
//                view.factoryTitle.text = fac.Name
//            }
//        }
//        return view
//    }
//
//
//
//
//    /*
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
//    */
//
//}

