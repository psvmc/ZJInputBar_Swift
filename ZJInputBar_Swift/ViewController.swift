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
    var screenHeight:CGFloat! = UIScreen.main.bounds.height;//屏幕的高度
    
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
        inputBarCell.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 200);
        
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
    }
    
    @objc func leftVoiceButtonClick(_ button:UIButton){
        self.inputBarCell.changeStyle(.LeftVoice)
        showMoreView();
        self.inputBarCell?.frame = CGRect(x: 0, y: screenHeight - 50, width: screenWidth, height: 250);
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
        self.inputBarCell.changeStyle(.RightAdd)
        if(self.inputBarCell.isShowMoreView){
            if(inputBarCell.otherView.isHidden){
            }else{
                hideMoreView();
            }
        }else{
            showMoreView();
        }
        
    }
    
    //更多对应View显示
    func showMoreView(){
        self.inputBarCell.isShowMoreView = true;
        self.inputBarCell.viewPaddingBottom = 200;
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.inputBarCell!.transform = CGAffineTransform(translationX: 0,y: -200)
        }) { (result) -> Void in
            
        }
    }
    
    //更多对应View隐藏
    func hideMoreView(){
        self.inputBarCell.isShowMoreView = false;
        self.inputBarCell.viewPaddingBottom = 0;
        inputBarCell.rightKeyboardButton.isHidden = true;
        inputBarCell.rightFaceButton.isHidden = false;
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.inputBarCell!.transform = CGAffineTransform.identity
        }) { (result) -> Void in
            
        }
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
                        self.inputBarCell.isShowKeyboard = false;
                        self.inputBarCell.viewPaddingBottom = 0;
                    }else{
                        self.inputBarCell.isShowKeyboard = true;
                        self.inputBarCell.viewPaddingBottom = keyboardheight;
                    }
                }
            }else{
                self.inputBarCell.isShowKeyboard = false;
                self.inputBarCell.viewPaddingBottom = 0;
            }
            
            if(self.inputBarCell.isShowKeyboard){
                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                    self.inputBarCell!.transform = CGAffineTransform(translationX: 0,y: -keyboardheight)
                }, completion: { (result) in
                    self.textViewDidChange(self.inputBarCell.inputTextView);
                })
            }else{
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                    self.inputBarCell!.transform = CGAffineTransform.identity;
                }, completion: { (result) in
                    self.textViewDidChange(self.inputBarCell.inputTextView);
                })
            }
            
        }
        
    }
    
    //点击其他隐藏输入法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(self.inputBarCell.isShowMoreView){
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
        if(textView.text!.endIndex.encodedOffset > 0){
            self.inputBarCell!.backgroundTextView.text = "";
        }else{
            self.inputBarCell!.backgroundTextView.text = "请输入回复";
        }
        
        var textViewHeight: CGFloat = textView.contentSize.height + 14;
        if(textViewHeight <= 50){
            textViewHeight = 50;
        }
        if (textViewHeight > 130) {
            textViewHeight = 130
        }
      
        self.inputBarCell?.frame = CGRect(x: 0, y: screenHeight - textViewHeight - self.inputBarCell.viewPaddingBottom, width: screenWidth, height: textViewHeight + 200);
        
        //滚动到TextView的底部
        let offset = textView.contentSize.height - textView.bounds.size.height;
        if(offset > 0){
            textView.setContentOffset(CGPoint(x: 0, y: offset), animated: true);
        }
    }
}

