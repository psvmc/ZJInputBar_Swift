//
//  ChatViewController.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 2017/11/16.
//  Copyright © 2017年 张剑. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController,InputBarCellDelegate {
   
    
   var inputBarCell:InputBarCell!;//输入的Bar
    override func viewDidLoad() {
        super.viewDidLoad()
        initInputBar();
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //添加键盘的观察者
    override func viewWillAppear(_ animated: Bool) {
        self.inputBarCell.viewWillAppear();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.inputBarCell.viewWillDisappear()
    }
    
    
    //初始化
    func initInputBar(){
        self.inputBarCell = Bundle.main.loadNibNamed("InputBarCell", owner: self, options: nil)?.first as! InputBarCell;
        self.inputBarCell.initFrame();
        self.view.addSubview(inputBarCell);
        self.inputBarCell.delegate = self;
    }
    
    //点击其他隐藏输入法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.inputBarCell.restoreDefault();
        self.view.endEditing(true);
    }
    
    func inputBarCellSendText(text: String) {
        print("发送文字消息:\(text)")
        self.inputBarCell.clearInputTextView();
    }
    
    func inputBarCellSendVoice(file: String!, duration: TimeInterval) {
        print("发送语音消息:file：\(file!) duration：\(duration)")
    }
    
    func inputBarCellSendOther(name: String!) {
        print("点击更多页面:项：\(name!)")
    }
   

}
