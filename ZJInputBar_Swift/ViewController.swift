//
//  ViewController.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextViewDelegate {
    
    var inputBarCell:InputBarCell!;//输入的Bar
    var screenWidth:CGFloat! = UIScreen.main.bounds.width;//屏幕的宽度
    var inputBarDefaultY:CGFloat! = UIScreen.main.bounds.height - 64;//输入框默认的最大高度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initInputBar();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //添加键盘的观察者
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.keyBoardWillUIKeyboardWillChangeFrame(_:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    //初始化
    func initInputBar(){
        inputBarCell = Bundle.main.loadNibNamed("InputBarCell", owner: self, options: nil)?.first as! InputBarCell;
        inputBarCell.frame = CGRect(x: 0, y: inputBarDefaultY - 50, width: screenWidth, height: 200);
        
        //添加事件
        inputBarCell.leftVoiceButton.addTarget(self, action: #selector(ViewController.leftVoiceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.voiceHideButton.addTarget(self, action: #selector(ViewController.voiceHideButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.leftKeyboardButton.addTarget(self, action: #selector(ViewController.leftKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightFaceButton.addTarget(self, action: #selector(ViewController.rightFaceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightKeyboardButton.addTarget(self, action: #selector(ViewController.rightKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightAddButton.addTarget(self, action: #selector(ViewController.rightAddButtonClick(_:)), for: UIControlEvents.touchUpInside)
        inputBarCell.inputTextView.returnKeyType = UIReturnKeyType.done;
        inputBarCell.inputTextView.delegate = self;
        inputBarCell.inputTextView.alwaysBounceVertical = false;
        self.view.addSubview(inputBarCell);
    }
    
    @objc func leftVoiceButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.LeftVoice)
        showMoreView();
    }
    
    @objc func voiceHideButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.Default)
        hideMoreView();
    }
    
    @objc func leftKeyboardButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.LeftKeybord)
    }
    
    @objc func rightFaceButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.RightFace)
        showMoreView();
    }
    
    @objc func rightKeyboardButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.RightKeybord)
    }
    
    @objc func rightAddButtonClick(_ button:UIButton){
        if(self.inputBarCell.isShowMoreView){
            if(self.inputBarCell.otherView.isHidden){
                showMoreView();
            }else{
                hideMoreView();
            }
        }else{
            showMoreView();
        }
         self.inputBarCell.changeStyle(.RightAdd)
        
    }
    
    //更多对应View显示
    func showMoreView(){
        self.inputBarCell.isShowMoreView = true;
        self.inputBarCell.viewPaddingBottom = 200;
        self.changeInputBarFrame(0);
    }
    
    //更多对应View隐藏
    func hideMoreView(){
        self.inputBarCell.isShowMoreView = false;
        self.inputBarCell.viewPaddingBottom = 0;
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        self.changeInputBarFrame(0);
    }
    
    @objc func keyBoardWillUIKeyboardWillChangeFrame(_ noti:Notification){
        let screenMaxY = self.view.frame.maxY;

        if let userInfo = noti.userInfo{
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue;
            let keyboardEndY = (userInfo[UIKeyboardFrameEndUserInfoKey]! as! CGRect).origin.y;
            let keyboardheight = (userInfo[UIKeyboardFrameEndUserInfoKey]! as! CGRect).height;
          
            if(keyboardheight != 0){
                if(keyboardheight>self.inputBarCell.keyboardMaxHeight){
                    self.inputBarCell.keyboardMaxHeight = keyboardheight;
                }
                if(keyboardheight == self.inputBarCell.keyboardMaxHeight){
                    if(keyboardEndY == screenMaxY){
                        self.inputBarCell.viewPaddingBottom = 0;
                    }else{
                        self.inputBarCell.viewPaddingBottom = keyboardheight;
                    }
                }
            }else{
                self.inputBarCell.viewPaddingBottom = 0;
            }
        
            self.changeInputBarFrame(duration);
            
        }
        
    }
    
    //点击其他隐藏输入法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("触控事件")
        for touch in touches{
            if(touch.view != self.inputBarCell.inputTextView){
                self.view.endEditing(true);
                if(self.inputBarCell.isShowMoreView){
                    hideMoreView();
                }
            }
        }
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            if(text != ""){
                print("提交输入框中的内容");
            }else{
                print("提交内容不能为空");
            }
            
            return false;
        }else{
            return true;
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text!.endIndex.encodedOffset > 0){
            self.inputBarCell!.backgroundTextView.text = "";
        }else{
            self.inputBarCell!.backgroundTextView.text = "请输入回复";
        }

        let textViewSize = textView.sizeThatFits(CGSize(width:textView.frame.width,height:CGFloat(MAXFLOAT)));
        var textViewHeight: CGFloat = textViewSize.height + 16;
        if(textViewHeight <= 50){
            textViewHeight = 50;
        }
        if (textViewHeight > 130) {
            textViewHeight = 130
        }

        self.inputBarCell.inputBarHeight = textViewHeight;
        self.inputBarCell?.frame = CGRect(x: 0, y: self.inputBarDefaultY - textViewHeight - self.inputBarCell.viewPaddingBottom, width: self.screenWidth, height: textViewHeight + 200);
    }
    
    
    func changeInputBarFrame(_ duration:TimeInterval){
        if(self.inputBarCell.midInputOutView.isHidden){
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.inputBarCell?.frame = CGRect(x: 0, y: self.inputBarDefaultY - self.inputBarCell.viewPaddingBottom - 50, width: self.screenWidth, height: 250);
            }, completion: { (result) in
            })
        }else{
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.inputBarCell?.frame = CGRect(x: 0, y: self.inputBarDefaultY - self.inputBarCell.viewPaddingBottom - self.inputBarCell.inputBarHeight, width: self.screenWidth, height: 250);
            }, completion: { (result) in
                self.textViewDidChange(self.inputBarCell.inputTextView);
            })
        }
        
    }
}

