//
//  HomsTreeTableViewCell.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/2/5.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import RealmSwift
protocol TreeCellProtocol {
    func chooseCell(_ data: heatModel)
}

class HomsTreeTableViewCell: UITableViewCell {
    var level:Int = 0   //等级
    let offset:CGFloat = 20//偏移量 每一级偏移20
    var isOpen:Bool = false{//是否打开状态
        didSet{
            changeImage()
        }
    }
    
    //是否打开
    var data:heatModel?{
        didSet{
            getLevel()
            setModel()
            childs = getChilds()!
        }
    }
    
    var childs:[heatModel] = []{
        didSet{
            changeImageState()
        }
    }
    var delegate: TreeCellProtocol!
    
    
    var icon = UIImageView()
    var titleLabel = UILabel()
    var editor = LayoutableView()
    var button = UIButton()
    
    func changeImage() {
        let image = isOpen ? "open" : "close"
        icon.image = UIImage.init(named: image)
    }
    
    func setTitle() {
        titleLabel.text = data?.area_name
    }
    
    func changeImageState() {
        icon.isHidden = childs.count > 0 ? false : true
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        editor.layout = WeightsLayout.init(horizontal: true)
        editor.layout?.weights = [1,4]
        editor.addSubview(icon)
        editor.addSubview(titleLabel)
        button.setTitle("监控", for: .normal)
        button.addTarget(self, action: #selector(toMonitor), for: .touchUpInside)
        button.backgroundColor = UIColor.lightGray
        self.addSubview(editor)
        self.addSubview(button)
        
    }
    func setModel() {
        titleLabel.text = data?.area_name
    }
    
    @objc func toMonitor() {
        delegate.chooseCell(data!)
    }
    
    //得到当前数据的层级 --最外层为0
    func getLevel(){
        var count = 0
        let realm = try! Realm()
        var model:heatModel = data!
        while !(realm.objects(heatModel.self).filter("area_id == \(model.parent_id)").isEmpty) {
            count += 1
            model = (realm.objects(heatModel.self).filter("area_id == \(model.parent_id)").first)!
        }
        self.level = count
    }
    
    //得到当前数据的子数据
    func getChilds() -> [heatModel]? {
        let realm = try! Realm()
        if let id = data?.area_id{
            let objects = realm.objects(heatModel.self).filter("parent_id == \(id)").toArray(of: heatModel.self)
            return objects.count > 0 ? objects : []
        }
        return []
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        editor.frame = CGRect.init(x: CGFloat(level)*offset, y: 5, width: 220, height: self.contentView.frame.height-10)
        button.frame = CGRect.init(x: self.contentView.frame.width - 60, y: 10, width: 50, height: 25)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


