//
//  ZJTextKit.swift
//  Meixue
//
//  Created by 张剑 on 16/1/20.
//  Copyright © 2016年 ChaMobile. All rights reserved.
//

import Foundation
import UIKit

class ZJEmoji{
    static var emojiMap:[String:String] = [
        "[呵呵]": "d_hehe",
        "[嘻嘻]": "d_xixi",
        "[哈哈]": "d_haha",
        "[爱你]": "d_aini",
        "[挖鼻屎]": "d_wabishi",
        "[吃惊]": "d_chijing",
        "[晕]": "d_yun",
        "[泪]": "d_lei",
        "[馋嘴]": "d_chanzui",
        "[抓狂]": "d_zhuakuang",
        "[哼]": "d_heng",
        "[可爱]": "d_keai",
        "[怒]": "d_nu",
        "[汗]": "d_han",
        "[害羞]": "d_haixiu",
        "[睡觉]": "d_shuijiao",
        "[钱]": "d_qian",
        "[偷笑]": "d_touxiao",
        "[笑cry]": "d_xiaoku",
        "[doge]": "d_doge",
        "[喵喵]": "d_miao",
        "[酷]": "d_ku",
        "[衰]": "d_shuai",
        "[闭嘴]": "d_bizui",
        "[鄙视]": "d_bishi",
        "[花心]": "d_huaxin",
        "[鼓掌]": "d_guzhang",
        "[悲伤]": "d_beishang",
        "[思考]": "d_sikao",
        "[生病]": "d_shengbing",
        "[亲亲]": "d_qinqin",
        "[怒骂]": "d_numa",
        "[太开心]": "d_taikaixin",
        "[懒得理你]": "d_landelini",
        "[右哼哼]": "d_youhengheng",
        "[左哼哼]": "d_zuohengheng",
        "[嘘]": "d_xu",
        "[委屈]": "d_weiqu",
        "[吐]": "d_tu",
        "[可怜]": "d_kelian",
        "[打哈气]": "d_dahaqi",
        "[挤眼]": "d_jiyan",
        "[失望]": "d_shiwang",
        "[顶]": "d_ding",
        "[疑问]": "d_yiwen",
        "[困]": "d_kun",
        "[感冒]": "d_ganmao",
        "[拜拜]": "d_baibai",
        "[黑线]": "d_heixian",
        "[阴险]": "d_yinxian",
        "[打脸]": "d_dalian",
        "[傻眼]": "d_shayan",
        "[猪头]": "d_zhutou",
        "[熊猫]": "d_xiongmao",
        "[兔子]": "d_tuzi",
    ];
    
    
    
    static func getAttributedText(_ message:String) -> NSMutableAttributedString{
        var isContain:Bool = true;
        let mutableAttributedString = NSMutableAttributedString();
        var tempMessage = message;
        
        
        //判断当前字符串是否还有表情的标志。
        while isContain{
            
            let range = tempMessage.range(
                of: "\\[[^\\[^\\]]+\\]",
                options: NSString.CompareOptions.regularExpression,
                range: nil,
                locale: nil
            );
            
            if (range != nil && (range!.lowerBound != range!.upperBound)){
                let leftStr = String(tempMessage[tempMessage.startIndex..<range!.lowerBound]);
                let midStr = String(tempMessage[range!]);
                let rightStr = String(tempMessage[range!.upperBound..<tempMessage.endIndex]);
                
                tempMessage = rightStr;
                
                let imageUrl = emojiMap[midStr];
                //能找到图片资源
                if(imageUrl != nil){
                    mutableAttributedString.insert(
                        NSAttributedString(string: leftStr),
                        at: mutableAttributedString.string.endIndex.encodedOffset
                    );
                    
                    let textAttachment = ZJTextAttachment();
                    textAttachment.image = UIImage(named: imageUrl!);
                    let attributedString = NSAttributedString(attachment: textAttachment);
                    mutableAttributedString.insert(
                        attributedString,
                        at: mutableAttributedString.string.endIndex.encodedOffset
                    );
                }else{
                    mutableAttributedString.insert(
                        NSAttributedString(string: leftStr + midStr),
                        at: mutableAttributedString.string.endIndex.encodedOffset
                    )
                }
                
            }else{
                mutableAttributedString.insert(
                    NSAttributedString(string: tempMessage),
                    at: mutableAttributedString.string.endIndex.encodedOffset
                )
                isContain = false;
            }
        }
        
        return mutableAttributedString;
    }
    
    
}
