//
//  InputBarCell.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit


enum InputBarCellType{
    case Default
    case LeftVoice
    case LeftKeybord
    case RightFace
    case RightKeybord
    case RightAdd
}

public protocol InputBarCellDelegate : NSObjectProtocol{
    func inputBarCellSendText(text:String);
    func inputBarCellSendVoice(file: String!, duration: TimeInterval);
    func inputBarCellSendOther(name: String!);
    func inputBarCellChangeY(_ y:CGFloat);
}

class InputBarCell: UITableViewCell,AudioRecordViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    var delegate:InputBarCellDelegate?;
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
    @IBOutlet weak var faceSendButton: UIButton!
    
    var inputText:String! = "";
    var viewPaddingBottom:CGFloat = 0;//输入条距离底部的距离
    var inputBarHeight:CGFloat = 50;//上面输入条的高度
    var isShowMoreView = false;//是否显示更多的View
    var keyboardMaxHeight:CGFloat = 0;
    var screenWidth:CGFloat! = UIScreen.main.bounds.width;//屏幕的宽度
    var inputBarDefaultY:CGFloat! = UIScreen.main.bounds.height+1;//输入框默认的最大高度
    
    
    var chatVoiceState:ChatVoiceState! = .ready;
    var duration = 0;//录音的时长（秒）
    var timer:Timer!;
    @IBOutlet weak var recordView: AudioRecordView!
    @IBOutlet weak var topAudioOuterView: UIView!
    @IBOutlet weak var chatVoiceLabel: UILabel!
    @IBOutlet weak var leftAudioVolume: AudioVolumeView!
    @IBOutlet weak var rightAudioVolume: AudioVolumeView!
    @IBOutlet weak var midAudioTimeLabel: UILabel!
    
    @IBOutlet weak var faceCollectionView: UICollectionView!
    @IBOutlet weak var otherCollectionView: UICollectionView!
    var faceColldata:[[String:Any]] = [];
    var otherColldata:[[String:String]] = [
        ["text":"图片","image":"chat_other_pic"],
        ["text":"拍照","image":"chat_other_photo"]
    ];
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.midInputOutView.layer.masksToBounds = true;
        self.midInputOutView.layer.cornerRadius = 18;
        self.midInputOutView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor;
        self.midInputOutView.layer.borderWidth = 1;
        
        recordView.delegate = self;
        leftAudioVolume.type = .left;
        rightAudioVolume.type = .right;
        self.updateVoiceState(.ready);
        self.inputTextView.returnKeyType = UIReturnKeyType.send;
        initFaceCollView();
        initOtherCollView();
        addEvent();
    }
    
    func initDefaultY(_ defaultY:CGFloat){
        self.inputBarDefaultY = defaultY;
    }
    
    func initFrame (){
        self.frame = CGRect(x: 0, y: inputBarDefaultY - 50, width: screenWidth, height: 250);
    }
    
    func restoreDefault(){
        self.hideMoreView();
        self.changeStyle(.Default)
    }
    
    func clearInputTextView (){
        self.inputText = "";
        self.updateInputTextView();
    }
    
    func addEvent(){
        //添加事件
        self.leftVoiceButton.addTarget(self, action: #selector(InputBarCell.leftVoiceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        self.voiceHideButton.addTarget(self, action: #selector(InputBarCell.voiceHideButtonClick(_:)), for: UIControlEvents.touchUpInside);
        self.leftKeyboardButton.addTarget(self, action: #selector(InputBarCell.leftKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        self.rightFaceButton.addTarget(self, action: #selector(InputBarCell.rightFaceButtonClick(_:)), for: UIControlEvents.touchUpInside);
        self.rightKeyboardButton.addTarget(self, action: #selector(InputBarCell.rightKeyboardButtonClick(_:)), for: UIControlEvents.touchUpInside);
        self.rightAddButton.addTarget(self, action: #selector(InputBarCell.rightAddButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        self.faceSendButton.addTarget(self, action: #selector(InputBarCell.faceSendButtonClick(_:)), for: UIControlEvents.touchUpInside)
        
        self.inputTextView.delegate = self;
        self.inputTextView.alwaysBounceVertical = false;
    }
    
    func initFaceData(){
        DispatchQueue.global().async {
            for (key,value) in ZJEmoji.emojiMap{
                let image = UIImage(named:value);
                let itemData = ["text":key,"image":value,"imageData":image as Any] as [String : Any];
                self.faceColldata.append(itemData);
            }
            DispatchQueue.main.async {
                self.faceCollectionView.reloadData();
            }
            
        }
        
    }
    
    func initFaceCollView(){
        
        self.faceCollectionView.register(UINib.init(nibName: "FaceCollCell", bundle: nil), forCellWithReuseIdentifier: "FaceCollCell");
        self.faceCollectionView.showsHorizontalScrollIndicator = false;
        self.faceCollectionView.showsVerticalScrollIndicator = true;
        self.faceCollectionView.backgroundColor = UIColor.clear;
        self.faceCollectionView.isScrollEnabled = true;
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        self.faceCollectionView.tag = 1;
        self.faceCollectionView.collectionViewLayout = flowLayout;
        self.faceCollectionView.dataSource = self;
        self.faceCollectionView.delegate = self;
        initFaceData();
    }
    
    func initOtherCollView(){
        self.otherCollectionView.register(UINib.init(nibName: "OtherCollCell", bundle: nil), forCellWithReuseIdentifier: "OtherCollCell");
        self.otherCollectionView.showsHorizontalScrollIndicator = false;
        self.otherCollectionView.showsVerticalScrollIndicator = true;
        self.otherCollectionView.backgroundColor = UIColor.clear;
        self.otherCollectionView.isScrollEnabled = true;
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        self.otherCollectionView.tag = 2;
        self.otherCollectionView.collectionViewLayout = flowLayout;
        self.otherCollectionView.dataSource = self;
        self.otherCollectionView.delegate = self;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    func startTimer()  {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increaseRecordTime), userInfo: nil, repeats: true);
    }
    
    func stopTimer(){
        if(self.timer != nil){
            self.timer.invalidate();
            self.timer = nil;
        }
    }
    
    func updateVoiceState(_ state:ChatVoiceState){
        switch state {
        case .ready:
            self.chatVoiceState = .ready;
            self.topAudioOuterView.isHidden = true;
            self.chatVoiceLabel.isHidden = false;
            self.chatVoiceLabel.text = "按住说话";
            break;
        case .recording:
            self.chatVoiceState = .recording;
            self.topAudioOuterView.isHidden = false;
            self.chatVoiceLabel.isHidden = true;
            self.midAudioTimeLabel.text = formattedTime(duration);
            break;
        case .cancel:
            self.chatVoiceState = .cancel;
            self.topAudioOuterView.isHidden = true;
            self.chatVoiceLabel.isHidden = false;
            self.chatVoiceLabel.text = "松开取消";
            break;
            
        }
    }
    
    func formattedTime(_ duration:Int) -> String{
        return String.init(format: "%02d:%02d", duration / 60,duration % 60);
    }
    
    @objc func increaseRecordTime(){
        duration = duration + 1;
        if(self.chatVoiceState == .recording){
            self.updateVoiceState(.recording);
        }
        
    }
    
    //AudioRecordViewDelegate
    func recordViewRecordStarted(_ recordView: AudioRecordView!) {
        self.chatVoiceState = ChatVoiceState.recording;
        self.updateVoiceState(.recording);
        self.startTimer();
    }
    
    func recordViewRecordFinished(_ recordView: AudioRecordView!, file: String!, duration: TimeInterval) {
        self.stopTimer();
        if(self.chatVoiceState == .cancel){
            do{
                try FileManager.default.removeItem(atPath: file)
            }catch{
                
            }
        }else{
            self.delegate?.inputBarCellSendVoice(file: file, duration: duration);
        }
        self.updateVoiceState(.ready);
        self.duration = 0;
    }
    
    func recordView(_ recordView: AudioRecordView!, touchStateChanged touchState: AudioRecordViewTouchState) {
        if(self.chatVoiceState != .ready){
            if(touchState == .inside){
                self.updateVoiceState(.recording);
            }else{
                self.updateVoiceState(.cancel);
            }
        }
    }
    
    func recordView(_ recordView: AudioRecordView!, volume: Double) {
        leftAudioVolume.addVolume(volume);
        rightAudioVolume.addVolume(volume);
    }
    
    func recordViewRecord(_ recordView: AudioRecordView!, err: Error!) {
        self.stopTimer();
        self.updateVoiceState(.ready);
        duration = 0;
    }
    
    @objc func leftVoiceButtonClick(_ button:UIButton){
        self.changeStyle(.LeftVoice)
        showMoreView();
        self.frame = CGRect(x: 0, y: self.inputBarDefaultY - self.viewPaddingBottom - 50, width: self.screenWidth, height: 250);
        self.delegate?.inputBarCellChangeY(self.inputBarDefaultY - self.viewPaddingBottom - 50)
    }
    
    @objc func voiceHideButtonClick(_ button:UIButton){
        self.changeStyle(.Default)
        hideMoreView();
    }
    
    @objc func leftKeyboardButtonClick(_ button:UIButton){
        self.changeStyle(.LeftKeybord)
    }
    
    @objc func rightFaceButtonClick(_ button:UIButton){
        self.changeStyle(.RightFace)
        showMoreView();
    }
    
    @objc func rightKeyboardButtonClick(_ button:UIButton){
        self.changeStyle(.RightKeybord)
    }
    
    @objc func rightAddButtonClick(_ button:UIButton){
        if(self.isShowMoreView){
            if(self.otherView.isHidden){
                showMoreView();
            }else{
                hideMoreView();
            }
        }else{
            showMoreView();
        }
        self.changeStyle(.RightAdd)
    }
    
    
    @objc func faceSendButtonClick(_ button:UIButton){
        if(!self.inputText.isEmpty){
            delegate?.inputBarCellSendText(text:self.inputText);
        }
    }
    
    //更多对应View显示
    func showMoreView(){
        self.isShowMoreView = true;
        self.viewPaddingBottom = 200;
        self.changeInputBarFrame(0);
    }
    
    //更多对应View隐藏
    func hideMoreView(){
        self.isShowMoreView = false;
        self.viewPaddingBottom = 0;
        self.rightKeyboardButton.isHidden = true;
        self.rightFaceButton.isHidden = false;
        self.changeInputBarFrame(0);
    }
    
    @objc func keyBoardWillUIKeyboardWillChangeFrame(_ noti:Notification){
        let screenMaxY = UIScreen.main.bounds.height;
        if let userInfo = noti.userInfo{
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue;
            let keyboardEndY = (userInfo[UIKeyboardFrameEndUserInfoKey]! as! CGRect).origin.y;
            let keyboardheight = (userInfo[UIKeyboardFrameEndUserInfoKey]! as! CGRect).height;
            
            if(keyboardheight != 0){
                if(keyboardheight>self.keyboardMaxHeight){
                    self.keyboardMaxHeight = keyboardheight;
                }
                
                if(keyboardEndY == screenMaxY){
                    self.viewPaddingBottom = 0;
                }else{
                    self.viewPaddingBottom = keyboardheight;
                }
            }else{
                self.viewPaddingBottom = 0;
            }
            self.changeInputBarFrame(duration);
            
        }
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("range:\(range)")
        //print("text:\(text)")
        let length = range.length;
        if(text == "\n"){
            //点击了发送键
            if(!self.inputText.isEmpty){
                delegate?.inputBarCellSendText(text:self.inputText);
            }
            return false;
        }else if(text == ""){
            //点击了删除键
            if(!self.inputText.isEmpty){
                if(self.inputText.hasSuffix("]")){
                    var tempText = String(self.inputText.reversed());
                    //print("tempText\(tempText)");
                    if let range = tempText.range(
                        of: "\\][^\\[^\\]]+\\[",
                        options: NSString.CompareOptions.regularExpression,
                        range: nil,
                        locale: nil){
                        tempText = tempText.replacingCharacters(in: range, with: "")
                        //print("tempText\(tempText)");
                        self.inputText = String(tempText.reversed());
                    }else{
                        self.inputText = String(self.inputText[..<self.inputText.index(before: self.inputText.endIndex)])
                    }
                }else{
                    self.inputText = String(self.inputText[..<self.inputText.index(before: self.inputText.endIndex)])
                }
                updateInputTextView();
            }
            
            return false;
        }else{
            //有文字新增
            if(textView.markedTextRange == nil){
                self.inputText.append(text);
                updateInputTextView();
                return true;
            }else{
                return true;
            }
        }
        
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.changeStyle(.Default)
    }
    
    func updateInputTextView(){
        self.inputTextView.attributedText = ZJEmoji.getAttributedText(self.inputText);
        if(self.inputText.endIndex.encodedOffset > 0){
            self.backgroundTextView.text = "";
        }else{
            self.backgroundTextView.text = "请输入回复";
        }
        
        let textViewSize = self.inputTextView.sizeThatFits(CGSize(width:self.inputTextView.frame.width,height:CGFloat(MAXFLOAT)));
        var textViewHeight: CGFloat = textViewSize.height + 16;
        if(textViewHeight <= 50){
            textViewHeight = 50;
            self.inputTextView.isScrollEnabled = false;
        }else if (textViewHeight > 130) {
            textViewHeight = 130
            self.inputTextView.isScrollEnabled = true;
        }else{
            self.inputTextView.isScrollEnabled = false;
        }
        
        self.inputBarHeight = textViewHeight;
        self.frame = CGRect(x: 0, y: self.inputBarDefaultY - textViewHeight - self.viewPaddingBottom, width: self.screenWidth, height: textViewHeight + 200);
        self.delegate?.inputBarCellChangeY(self.inputBarDefaultY - textViewHeight - self.viewPaddingBottom)
    }
    
    func changeInputBarFrame(_ duration:TimeInterval){
        self.delegate?.inputBarCellChangeY(self.inputBarDefaultY - self.viewPaddingBottom - self.inputBarHeight);
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.frame = CGRect(x: 0, y: self.inputBarDefaultY - self.viewPaddingBottom - self.inputBarHeight, width: self.screenWidth, height: 250);
        }, completion: { (result) in
            
        })
        
        if(self.inputBarHeight > 50){
            self.updateInputTextView();
        }
    }
    
    
    func viewWillAppear() {
        NotificationCenter.default.addObserver(self, selector:#selector(InputBarCell.keyBoardWillUIKeyboardWillChangeFrame(_:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func viewWillDisappear()  {
        NotificationCenter.default.removeObserver(self);
    }
    
    //CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 1){
            return faceColldata.count;
        }else{
            return otherColldata.count;
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView.tag == 1){
            let itemdata = faceColldata[indexPath.row];
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCollCell", for: indexPath) as! FaceCollCell;
            if let img = itemdata["imageData"]{
                cell.faceImageView.image = img as? UIImage;
            }
            return  cell;
        }else{
            let itemdata = otherColldata[indexPath.row];
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherCollCell", for: indexPath) as! OtherCollCell;
            DispatchQueue.global(qos: .userInitiated).async {
                let image = UIImage(named:itemdata["image"]!);
                DispatchQueue.main.async {
                    cell.topImageView.image = image;
                }
            }
            cell.bottomLabel.text = itemdata["text"]
            return  cell;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == 1){
            return CGSize(width: collectionView.frame.width/7, height: collectionView.frame.width/7);
        }else{
            return CGSize(width: collectionView.frame.width/4, height: collectionView.frame.height/2);
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 1){
            let itemdata = faceColldata[indexPath.row];
            self.inputText = self.inputText + (itemdata["text"] as! String);
            updateInputTextView();
        }else{
            let itemdata = otherColldata[indexPath.row];
            self.delegate?.inputBarCellSendOther(name: itemdata["text"]!);
        }
        
    }
}

