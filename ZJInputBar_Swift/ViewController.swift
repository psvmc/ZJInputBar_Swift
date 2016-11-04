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
    var screenWidth:CGFloat! = UIScreen.main.bounds.width;//屏幕的宽度
    var screenHeight:CGFloat! = UIScreen.main.bounds.height;//屏幕的高度
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
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.keyBoardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ViewController.keyBoardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //初始化
    func initInputBar(){
        inputBarCell = Bundle.main.loadNibNamed("InputBarCell", owner: self, options: nil)?.first as! InputBarCell;
        inputBarCell.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 50);
        inputMoreCell = Bundle.main.loadNibNamed("InputMoreCell", owner: self, options: nil)?.first as! InputMoreCell;
        inputMoreCell.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 150);
        
        //添加事件
        inputBarCell.leftVoiceButton.addTarget(self, action: #selector(ViewController.leftVoiceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.leftKeyboardButton.addTarget(self, action: #selector(ViewController.leftKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightFaceButton.addTarget(self, action: #selector(ViewController.rightFaceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightKeyboardButton.addTarget(self, action: #selector(ViewController.rightKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        inputBarCell.rightAddButton.addTarget(self, action: #selector(ViewController.rightAddButtonClick(_:)), for: UIControlEvents.touchUpInside)
        inputBarCell.inputTextView.returnKeyType = UIReturnKeyType.done;
        inputBarCell.inputTextView.delegate = self;
        inputBarCell.inputTextView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag;
        self.view.addSubview(inputBarCell);
        self.view.addSubview(inputMoreCell);
    }
    
    func leftVoiceButtonClick(_ button:UIButton){
        inputBarCell.leftKeyboardButton.isHidden = false;
        inputBarCell.leftVoiceButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.midVoiceOutView.isHidden = false;
        inputBarCell.midInputOutView.isHidden = true;
        inputBarCell.inputTextView.resignFirstResponder();
        if(self.isShowMoreView){
            hideMoreView();
        }
        
        self.inputBarCell?.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 50);
    }
    
    func leftKeyboardButtonClick(_ button:UIButton){
        inputBarCell.leftKeyboardButton.isHidden = true;
        inputBarCell.leftVoiceButton.isHidden = false;
        inputBarCell.midVoiceOutView.isHidden = true;
        inputBarCell.midInputOutView.isHidden = false;
        inputBarCell.inputTextView.becomeFirstResponder();
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightFaceButtonClick(_ button:UIButton){
        inputBarCell.rightFaceButton.isHidden = true;
        inputBarCell.rightKeyboardButton.isHidden = false;
        inputBarCell.leftKeyboardButton.isHidden = true;
        inputBarCell.leftVoiceButton.isHidden = false;
        inputBarCell.inputTextView.resignFirstResponder();
        showMoreView();
        
        //表情输入时  切换成输入框
        inputBarCell.midVoiceOutView.isHidden = true;
        inputBarCell.midInputOutView.isHidden = false;
        inputMoreCell.faceView.isHidden = false;
        inputMoreCell.otherItemView.isHidden = true;
        
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightKeyboardButtonClick(_ button:UIButton){
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        inputBarCell.midVoiceOutView.isHidden = true;
        inputBarCell.midInputOutView.isHidden = false;
        inputBarCell.inputTextView.becomeFirstResponder();
        textViewDidChange(inputBarCell.inputTextView);
    }
    
    func rightAddButtonClick(_ button:UIButton){
        inputBarCell.inputTextView.resignFirstResponder();
        if(self.isShowMoreView){
            if(inputMoreCell.otherItemView.isHidden){
                inputMoreCell.faceView.isHidden = true;
                inputMoreCell.otherItemView.isHidden = false;
            }else{
                hideMoreView();
            }
        }else{
            showMoreView();
            inputMoreCell.faceView.isHidden = true;
            inputMoreCell.otherItemView.isHidden = false;
        }
        
    }
    
    //更多对应View显示
    func showMoreView(){
        self.isShowMoreView = true;
        viewPaddingBottom = 150;
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.inputBarCell!.transform = CGAffineTransform(translationX: 0,y: -150)
                self.inputMoreCell.transform = CGAffineTransform(translationX: 0,y: -150)
            }) { (result) -> Void in
            
            }
    }
    
    //更多对应View隐藏
    func hideMoreView(){
        self.isShowMoreView = false;
        viewPaddingBottom = 0;
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.inputBarCell!.transform = CGAffineTransform.identity
            self.inputMoreCell.transform = CGAffineTransform.identity
            }) { (result) -> Void in
                
        }
    }
    
    //键盘显示
    func keyBoardWillShow(_ notification:Notification){
        hideMoreView();
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        self.isShowKeyboard = true;
        let userInfo = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let deltaY = keyBoardBounds.size.height;
        viewPaddingBottom = deltaY;
        let animations:(() -> Void) = {
            self.inputBarCell!.transform = CGAffineTransform(translationX: 0,y: -deltaY)
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    //键盘隐藏
    func keyBoardWillHide(_ note:Notification){
        self.isShowKeyboard = false;
        viewPaddingBottom = 0;
        let userInfo = NSDictionary(dictionary: (note as NSNotification).userInfo!)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations:(() -> Void) = {
            //还原到动画之前的状态
            self.inputBarCell!.transform = CGAffineTransform.identity;
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    //点击其他隐藏输入法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(isShowMoreView){
            hideMoreView();
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
        self.inputBarCell?.frame = CGRect(x: 0, y: screenHeight - textViewHeight - self.viewPaddingBottom, width: screenWidth, height: textViewHeight);
        
        //滚动到TextView的底部
        let offset = textView.contentSize.height - textView.bounds.size.height;
        if(offset > 0){
            textView.setContentOffset(CGPoint(x: 0, y: offset), animated: true);
        }
    }
}

