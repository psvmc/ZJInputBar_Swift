//
//  ZJTextAttachment.swift
//  Meixue
//
//  Created by 张剑 on 16/1/20.
//  Copyright © 2016年 ChaMobile. All rights reserved.
//

import Foundation
import UIKit
class ZJTextAttachment:NSTextAttachment{
    var originalStr:String = "";
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        return CGRect(x: 0, y: -3, width: 18, height: 18);
    }
}
