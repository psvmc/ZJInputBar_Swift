//
//  InputBarCell.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit
import SnapKit


enum InputBarCellType{
    case Default
    case LeftVoice
    case LeftKeybord
    case RightFace
    case RightKeybord
    case RightAdd
}

class InputBarCell: UITableViewCell {
    @IBOutlet weak var leftKeyboardButton: UIButton!
    @IBOutlet weak var leftVoiceButton: UIButton!
    @IBOutlet weak var backgroundTextView: UITextView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var voiceHideButton: UIButton!
    @IBOutlet weak var rightKeyboardButton: UIButton!
    @IBOutlet weak var rightFaceButton: UIButton!
    @IBOutlet weak var rightAddButton: UIButton!
    @IBOutlet weak var midInputOutView: UIView!
    @IBOutlet weak var midVoiceOutView: UIView!
    
    @IBOutlet weak var talkView: UIView!
    @IBOutlet weak var faceView: UIView!
    @IBOutlet weak var otherView: UIView!
    
    @IBOutlet weak var talkButton: UIButton!
    
    var recordView:AudioRecordView!
    
    var viewPaddingBottom:CGFloat = 0;//输入条距离底部的距离
    var inputBarHeight:CGFloat = 50;//上面输入条的高度
    var isShowMoreView = false;//是否显示更多的View
    var keyboardMaxHeight:CGFloat = 0;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.midInputOutView.layer.masksToBounds = true;
        self.midInputOutView.layer.cornerRadius = 18;
        self.midInputOutView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor;
        self.midInputOutView.layer.borderWidth = 1;
        initRecordView();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initRecordView(){
//        recordView = AudioRecordView(frame: CGRect(x: 0, y: 0, width: 86, height: 86));
//        talkView.addSubview(recordView);
//        recordView.snp.makeConstraints { (make) in
//            make.width.height.equalTo(86);
//            make.center.equalTo(talkView);
//        }
        
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 86, height: 86));
        talkView.addSubview(view);
        view.backgroundColor = UIColor.red
        view.snp.makeConstraints { (make) in
            make.width.height.equalTo(86);
            make.center.equalTo(talkView);
        }
    }
    
    func changeStyle(_ style:InputBarCellType){
        switch style {
        case .Default:
            self.leftKeyboardButton.isHidden = true;
            self.leftVoiceButton.isHidden = false;
            self.rightFaceButton.isHidden = false;
            self.rightKeyboardButton.isHidden = true;
            self.midVoiceOutView.isHidden = true;
            self.midInputOutView.isHidden = false;
            self.inputTextView.resignFirstResponder();
            
            self.talkView.isHidden = false;
            self.faceView.isHidden = true;
            self.otherView.isHidden = true;
        case .LeftVoice:
            self.leftKeyboardButton.isHidden = false;
            self.leftVoiceButton.isHidden = true;
            self.rightFaceButton.isHidden = false;
            self.rightKeyboardButton.isHidden = true;
            self.midVoiceOutView.isHidden = false;
            self.midInputOutView.isHidden = true;
            self.inputTextView.resignFirstResponder();
            
            self.talkView.isHidden = false;
            self.faceView.isHidden = true;
            self.otherView.isHidden = true;
        case .LeftKeybord:
            self.leftKeyboardButton.isHidden = true;
            self.leftVoiceButton.isHidden = false;
            self.midVoiceOutView.isHidden = true;
            self.midInputOutView.isHidden = false;
            self.inputTextView.becomeFirstResponder();
        case .RightFace:
            self.rightFaceButton.isHidden = true;
            self.rightKeyboardButton.isHidden = false;
            self.leftKeyboardButton.isHidden = true;
            self.leftVoiceButton.isHidden = false;
            self.inputTextView.resignFirstResponder();
            //表情输入时  切换成输入框
            self.midVoiceOutView.isHidden = true;
            self.midInputOutView.isHidden = false;
            
            self.talkView.isHidden = true;
            self.faceView.isHidden = false;
            self.otherView.isHidden = true;
        case .RightKeybord:
            self.rightKeyboardButton.isHidden = true;
            self.rightFaceButton.isHidden = false;
            self.midVoiceOutView.isHidden = true;
            self.midInputOutView.isHidden = false;
            self.inputTextView.becomeFirstResponder();
        case .RightAdd:
            self.leftKeyboardButton.isHidden = true;
            self.leftVoiceButton.isHidden = false;
            self.midVoiceOutView.isHidden = true;
            self.midInputOutView.isHidden = false;
            self.rightFaceButton.isHidden = false;
            self.rightKeyboardButton.isHidden = true;
            self.inputTextView.resignFirstResponder();
            self.talkView.isHidden = true;
            self.faceView.isHidden = true;
            self.otherView.isHidden = false;
            
        }
    }
    
}
