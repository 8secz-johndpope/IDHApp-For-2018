//
//  ResultTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/4/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift

typealias transModels = (heatModel?, IndexPath) ->Void

class ResultTableViewCell: UITableViewCell ,UICollectionViewDelegate, UICollectionViewDataSource{
    
    var transBlock:transModels?
    
    var realm:Realm?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fac = self.model {
            if fac.isHaveGroup{
                return fac.groups[section].exchangers.count
            }else{
                return fac.heatExchangers.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        if let fac = self.model {
            if fac.isHaveGroup{
                cell.exchangerModel = fac.groups[indexPath.section].exchangers[indexPath.item]
            }else{
                cell.exchangerModel = fac.heatExchangers[indexPath.item]
            }
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fac = self.model {
            if fac.isHaveGroup{
                return fac.groups.count
            }else{
                return 1
            }
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
        if (model?.isHaveGroup)! {
            view.model = model?.groups[indexPath.section]
            return view
        }
        return view
//        else{
//            let view1 = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
//            view.bounds.height = 0
//            return view1
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var exmodel:exchangerModel?
        if let fac = self.model {
            if fac.isHaveGroup{
                exmodel = fac.groups[indexPath.section].exchangers[indexPath.item]
            }else{
                exmodel = fac.heatExchangers[indexPath.item]
            }
        }
        if let id = exmodel {
        realm = try! Realm()
        let modelRealm = realm?.objects(heatModel.self).filter("idh_id = '\(id)' AND type = '换热站'").first
        guard let postBlock = self.transBlock else { return }
        postBlock(modelRealm, indexPath)
        }
        
    }
    


    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var model:HFModel?
    
    
    func reloadData(_ data: HFModel) {
        self.model = data
        if data.isHaveGroup {
//            self.title =
        }else{
//            self.title.isHidden = true
        }
        //更新collectionView的高度约束
        if let model = self.model {
            if model.isHaveGroup{
                flowLayout.headerReferenceSize = CGSize.init(width: self.contentView.bounds.width, height: 40)
            }else{
                
                flowLayout.headerReferenceSize = CGSize.init(width: self.contentView.bounds.width, height: 0)
            }
        }
        flowLayout.itemSize = CGSize.init(width: ceil(self.contentView.bounds.width/3)-15, height: 130)
//        flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
//        flowLayout.minimumLineSpacing = 5
//        flowLayout.minimumInteritemSpacing = 5
        self.collection.reloadData()
        let contentSize = self.collection.collectionViewLayout.collectionViewContentSize
        collectionViewHeight.constant = contentSize.height
        self.collection.collectionViewLayout.invalidateLayout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collection.dataSource = self
        self.collection.delegate = self
        self.collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collection.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
//        if let model = self.model {
//            if model.isHaveGroup{
//                flowLayout.headerReferenceSize = CGSize.init(width: self.contentView.bounds.width, height: 40)
//            }else{
//
//                flowLayout.headerReferenceSize = CGSize.init(width: self.contentView.bounds.width, height: 0)
//            }
//        }
//        if (self.model?.isHaveGroup)! {
//        }else{
//        }
//        flowLayout.itemSize = CGSize.init(width: self.contentView.bounds.width/3 - 10, height: 130)
        
//        flowLayout.
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
