//
//  InputBarCell.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit

class InputBarCell: UITableViewCell {
    @IBOutlet weak var leftKeyboardButton: UIButton!
    @IBOutlet weak var leftVoiceButton: UIButton!
    @IBOutlet weak var backgroundTextView: UITextView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var rightKeyboardButton: UIButton!
    @IBOutlet weak var rightFaceButton: UIButton!
    @IBOutlet weak var rightAddButton: UIButton!
    @IBOutlet weak var midInputOutView: UIView!
    @IBOutlet weak var midVoiceOutView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.midInputOutView.layer.masksToBounds = true;
        self.midInputOutView.layer.cornerRadius = 2;
        self.midVoiceOutView.layer.masksToBounds = true;
        self.midVoiceOutView.layer.cornerRadius = 2;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
