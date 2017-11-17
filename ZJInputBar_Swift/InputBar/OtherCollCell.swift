//
//  OtherCollCell.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 2017/11/15.
//  Copyright © 2017年 张剑. All rights reserved.
//

import UIKit

class OtherCollCell: UICollectionViewCell {
    @IBOutlet weak var imageOuterView: UIView!
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageOuterView.layer.masksToBounds = true;
        imageOuterView.layer.cornerRadius = 10;
        imageOuterView.layer.borderColor = UIColor.lightGray.cgColor;
        imageOuterView.layer.borderWidth = 1.0/UIScreen.main.scale;
    }

}
