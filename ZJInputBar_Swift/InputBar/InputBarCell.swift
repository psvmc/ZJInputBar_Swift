//
//  InputBarCell.swift
//  ZJInputBar_Swift
//
//  Created by 张剑 on 16/3/7.
//  Copyright © 2016年 张剑. All rights reserved.
//

import UIKit
import SDWebImage


enum InputBarCellType{
    case Default
    case LeftVoice
    case LeftKeybord
    case RightFace
    case RightKeybord
    case RightAdd
}

class InputBarCell: UITableViewCell,AudioRecordViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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
    
    var viewPaddingBottom:CGFloat = 0;//输入条距离底部的距离
    var inputBarHeight:CGFloat = 50;//上面输入条的高度
    var isShowMoreView = false;//是否显示更多的View
    var keyboardMaxHeight:CGFloat = 0;
    
    
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
    var faceColldata:[[String:String]] = [];
    
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
        initFaceCollView();
    }
    
    func initFaceData(){
        for (key,value) in ZJEmoji.emojiMap{
            let itemData = ["text":key,"image":value];
            self.faceColldata.append(itemData);
        }
    }
    
    func initFaceCollView(){
        initFaceData();
        self.faceCollectionView.register(UINib.init(nibName: "FaceCollCell", bundle: nil), forCellWithReuseIdentifier: "FaceCollCell");
        self.faceCollectionView.showsHorizontalScrollIndicator = false;
        self.faceCollectionView.showsVerticalScrollIndicator = true;
        self.faceCollectionView.backgroundColor = UIColor.clear;
        self.faceCollectionView.isScrollEnabled = true;
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        self.faceCollectionView.collectionViewLayout = flowLayout;
        self.faceCollectionView.dataSource = self;
        self.faceCollectionView.delegate = self;
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
    
    //CollectionView Delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faceColldata.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemdata = faceColldata[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCollCell", for: indexPath) as! FaceCollCell;
        //cell.faceImageView.image = UIImage(named:itemdata["image"]!)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(named:itemdata["image"]!);
            DispatchQueue.main.async {
                cell.faceImageView.image = image;
            }
        }
        
        return  cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.faceCollectionView.frame.width/7, height: self.faceCollectionView.frame.width/7);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
