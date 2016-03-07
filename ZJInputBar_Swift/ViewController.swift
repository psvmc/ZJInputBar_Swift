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
    var inputMoreCell:InputMoreCell!;//更多对应的View
    var screenWidth:CGFloat! = UIScreen.mainScreen().bounds.width;//屏幕的宽度
    var screenHeight:CGFloat! = UIScreen.mainScreen().bounds.height;//屏幕的高度
    var viewPaddingBottom:CGFloat = 0;//输入条距离底部的距离
    var isShowMoreView = false;//是否显示更多的View
    var isShowKeyboard = false;//是否显示输入法

    override func viewDidLoad() {
        super.viewDidLoad()
        initInputBar();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //添加键盘的观察者
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyBoardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    //初始化
    func initInputBar(){
        inputBarCell = NSBundle.mainBundle().loadNibNamed("InputBarCell", owner: self, options: nil).first as! InputBarCell;
        inputBarCell.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
        inputMoreCell = NSBundle.mainBundle().loadNibNamed("InputMoreCell", owner: self, options: nil).first as! InputMoreCell;
        inputMoreCell.frame = CGRectMake(0, screenHeight, screenWidth, 150);
        
        //添加事件
        inputBarCell.leftVoiceButton.addTarget(self, action: "leftVoiceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside);
        inputBarCell.leftKeyboardButton.addTarget(self, action: "leftKeyboardButtonClick:", forControlEvents: UIControlEvents.TouchUpInside);
        inputBarCell.rightFaceButton.addTarget(self, action: "rightFaceButtonClick:", forControlEvents: UIControlEvents.TouchUpInside);
        inputBarCell.rightKeyboardButton.addTarget(self, action: "rightKeyboardButtonClick:", forControlEvents: UIControlEvents.TouchUpInside);
        inputBarCell.rightAddButton.addTarget(self, action: "rightAddButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        inputBarCell.inputTextView.returnKeyType = UIReturnKeyType.Done;
        inputBarCell.inputTextView.delegate = self;
        
        self.view.addSubview(inputBarCell);
        self.view.addSubview(inputMoreCell);
    }
    
    func leftVoiceButtonClick(button:UIButton){
        inputBarCell.leftKeyboardButton.hidden = false;
        inputBarCell.leftVoiceButton.hidden = true;
        inputBarCell.rightFaceButton.hidden = false;
        inputBarCell.rightKeyboardButton.hidden = true;
        inputBarCell.midVoiceOutView.hidden = false;
        inputBarCell.midInputOutView.hidden = true;
        inputBarCell.inputTextView.resignFirstResponder();
        if(self.isShowMoreView){
            hideMoreView();
        }
        
        self.inputBarCell?.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
    }
    
    func leftKeyboardButtonClick(button:UIButton){
        inputBarCell.leftKeyboardButton.hidden = true;
        inputBarCell.leftVoiceButton.hidden = false;
        inputBarCell.midVoiceOutView.hidden = true;
        inputBarCell.midInputOutView.hidden = false;
        inputBarCell.inputTextView.becomeFirstResponder();
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightFaceButtonClick(button:UIButton){
        inputBarCell.rightFaceButton.hidden = true;
        inputBarCell.rightKeyboardButton.hidden = false;
        inputBarCell.leftKeyboardButton.hidden = true;
        inputBarCell.leftVoiceButton.hidden = false;
        inputBarCell.inputTextView.resignFirstResponder();
        showMoreView();
        
        //表情输入时  切换成输入框
        inputBarCell.midVoiceOutView.hidden = true;
        inputBarCell.midInputOutView.hidden = false;
        inputMoreCell.faceView.hidden = false;
        inputMoreCell.otherItemView.hidden = true;
        
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightKeyboardButtonClick(button:UIButton){
        inputBarCell.rightKeyboardButton.hidden = true;
        inputBarCell.rightFaceButton.hidden = false;
        inputBarCell.midVoiceOutView.hidden = true;
        inputBarCell.midInputOutView.hidden = false;
        inputBarCell.inputTextView.becomeFirstResponder();
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightAddButtonClick(button:UIButton){
        inputBarCell.inputTextView.resignFirstResponder();
        if(self.isShowMoreView){
            if(inputMoreCell.otherItemView.hidden){
                inputMoreCell.faceView.hidden = true;
                inputMoreCell.otherItemView.hidden = false;
            }else{
                hideMoreView();
            }
        }else{
            showMoreView();
            inputMoreCell.faceView.hidden = true;
            inputMoreCell.otherItemView.hidden = false;
        }
        
    }
    
    //更多对应View显示
    func showMoreView(){
        self.isShowMoreView = true;
        viewPaddingBottom = 150;
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.inputBarCell!.transform = CGAffineTransformMakeTranslation(0,-150)
                self.inputMoreCell.transform = CGAffineTransformMakeTranslation(0,-150)
            }) { (result) -> Void in
            
            }
    }
    
    //更多对应View隐藏
    func hideMoreView(){
        self.isShowMoreView = false;
        viewPaddingBottom = 0;
        inputBarCell.rightKeyboardButton.hidden = true;
        inputBarCell.rightFaceButton.hidden = false;
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.inputBarCell!.transform = CGAffineTransformIdentity
            self.inputMoreCell.transform = CGAffineTransformIdentity
            }) { (result) -> Void in
                
        }
    }
    
    //键盘显示
    func keyBoardWillShow(notification:NSNotification){
        hideMoreView();
        inputBarCell.rightKeyboardButton.hidden = true;
        inputBarCell.rightFaceButton.hidden = false;
        self.isShowKeyboard = true;
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let deltaY = keyBoardBounds.size.height;
        viewPaddingBottom = deltaY;
        let animations:(() -> Void) = {
            self.inputBarCell!.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    //键盘隐藏
    func keyBoardWillHide(note:NSNotification){
        self.isShowKeyboard = false;
        viewPaddingBottom = 0;
        let userInfo = NSDictionary(dictionary: note.userInfo!)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations:(() -> Void) = {
            //还原到动画之前的状态
            self.inputBarCell!.transform = CGAffineTransformIdentity;
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    //点击其他隐藏输入法
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        if(isShowMoreView){
            hideMoreView();
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
    
    
    func textViewDidChange(textView: UITextView) {
        if(textView.text!.characters.count != 0){
            self.inputBarCell!.backgroundTextView.text = "";
        }else{
            self.inputBarCell!.backgroundTextView.text = "请输入回复";
        }
        
        var textViewHeight: CGFloat = textView.contentSize.height + 16;
        if(textViewHeight <= 50){
            textViewHeight = 50;
        }
        if (textViewHeight > 130) {
            textViewHeight = 130
        }
        self.inputBarCell?.frame = CGRectMake(0, screenHeight - textViewHeight - self.viewPaddingBottom, screenWidth, textViewHeight);
        
        //滚动到TextView的底部
        let offset = textView.contentSize.height - textView.bounds.size.height;
        if(offset > 0){
            textView.setContentOffset(CGPoint(x: 0, y: offset), animated: true);
        }
    }
}

