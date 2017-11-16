//
//  ViewController.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func startTalkClick(_ sender: Any) {
        let chatViewController = ChatViewController();
        chatViewController.title = "聊天"
        let chatNavController = UINavigationController(rootViewController: chatViewController)
        self.present(chatNavController, animated: true, completion: nil);
    }


}

