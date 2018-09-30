//
//  TrendCollectionLayout.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/9/20.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class TrendCollectionLayout: UICollectionViewLayout {
    override var collectionViewContentSize: CGSize{
        let cellCount = self.collectionView!.numberOfItems(inSection: 0)
        return CGSize(width: self.collectionView!.frame.size.width, height: CGFloat(15*cellCount))
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        let cellCount = self.collectionView!.numberOfItems(inSection: 0)
        for i in 0..<cellCount{
            let indexPath = IndexPath(item: i, section: 0)
            let attribute = self.layoutAttributesForItem(at: indexPath)
            attributesArray.append(attribute!)
        }
        return attributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        print(self.collectionView!.frame.size.height)
        if indexPath.item % 2 == 0{
            attribute.frame = CGRect(x: 10 , y: indexPath.item/2*30+10, width: Int(self.collectionView!.frame.size.width/2-15), height: 30)
//            label.frame = CGRect.init(x: 10, y: 230 + (index/2) * 15, width: Int(self.contentView.bounds.width/2), height: 20)
        }else{
            attribute.frame = CGRect(x: Int(self.collectionView!.frame.size.width/2)+5 , y: Int(floorf(Float(indexPath.item/2))*30)+10, width: Int(self.collectionView!.frame.size.width/2-15), height: 30)
//            label.frame = CGRect.init(x: Int(self.contentView.bounds.width/2), y: Int(230 + floorf(Float(index / 2)) * 15), width: Int(self.contentView.bounds.width/2), height: 20)
        }
        return attribute
    }

}
