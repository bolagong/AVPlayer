//
//  CWPlayer.swift
//  SwiftStudy
//
//  Created by chang on 2018/2/12.
//  Copyright © 2018年 chang. All rights reserved.
//

import UIKit
import AVFoundation

class CWPlayer: UIView {
    
    /** 背景 imageView */
    var bgImageView : UIImageView!
    
    /** 工具条*/
    var toolView : UIView!
    
    /** 播放,暂停*/
    var playOrPauseBtn : UIButton!
    
    /** 滑动条 */
    var progressSlider : UISlider!
    
    /** 播放时间 */
    var timeLabel : UILabel!
    
    /** 总时间 */
    var allTimeLabel : UILabel!
    
    /** 全屏按钮 */
    var fullScreen : UIButton!
    
    /** 屏幕中央的开始按钮 */
    var playOrPauseBigBtn : UIButton!
    
    /** playerLayer */
    var playerLayer : AVPlayerLayer!
    
    /** player */
    var player : AVPlayer!
    
    /** playerItem */
    var playerItem : AVPlayerItem!
    
    /** 是否显示toolView */
    var isShowToolView = Bool.init()
    
    /** 播放完毕遮盖View */
    var coverView : UIView!
    
    /** 重播按钮 */
    var replayBtn : UIButton!
    
    /** 加载 */
    var indicatorView : UIActivityIndicatorView!
    
    /* 包含在哪一个控制器中 */
    var contrainerVC : UIViewController!
    
    /* 记录原始屏幕坐标 */
    var originalRect : CGRect!
    
    /** 添加toolView显示计时，5s后隐藏toolView */
    var showTime : Timer?
    
    /** 全屏播放控制器～～懒加载 */
    lazy var fullVC : CCPlayerFullVC =  {
        let vc = CCPlayerFullVC.init()
        return vc
    }()
    
    /** slider定时器添加 */
    lazy var progressTimer : Timer! = {
        let aTimer = Timer.init(timeInterval: 1.0, target: self, selector: #selector(updateProgressInfo), userInfo: nil, repeats: true)
        aTimer.fireDate = Date.distantFuture //初始先暂停timer
        RunLoop.main.add(aTimer, forMode: .commonModes)
        return aTimer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.defaultBackgroundColor
        // 记录一下原坐标
        self.originalRect = frame;
        
        self.viewLayout()
        self.initPlayerConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //刷新横竖屏布局
        bgImageView.frame = self.bounds
        playerLayer.frame = bgImageView.bounds
        toolView.frame = CGRect.init(x: 0, y: self.height-50, width: self.width, height: 50)
        playOrPauseBtn.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        fullScreen.frame = CGRect.init(x: toolView.width-50, y: 0, width: 50, height: 50)
        timeLabel.frame = CGRect.init(x: playOrPauseBtn.right, y: 0, width: 56, height: toolView.height)
        allTimeLabel.frame = CGRect.init(x: toolView.width-fullScreen.width-timeLabel.width, y: timeLabel.top, width: timeLabel.width, height: timeLabel.height)
        progressSlider.frame  = CGRect.init(x: timeLabel.right, y: (toolView.height-20)/2, width: toolView.width-timeLabel.right-allTimeLabel.width-fullScreen.width, height: 20)
        playOrPauseBigBtn.bounds = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        playOrPauseBigBtn.center = bgImageView.center
        coverView.frame = CGRect.init(x: 0, y: 0, width: self.width, height: self.height)
        replayBtn.bounds = CGRect.init(x: 0, y: 0, width: 56, height: 56)
        replayBtn.center = coverView.center
    }
    
    /** 播放的视频资源方法 */
    func urlString(url: NSString) {
        let nUrl = NSURL.init(string: url as String)
        playerItem = AVPlayerItem.init(url: nUrl! as URL)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }
    
    /** 监听播放状态 */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = object as! AVPlayerItem
        if keyPath == "loadedTimeRanges" {
            //"loaded time ranges"
        }else if keyPath == "status" {
            if playerItem.status == .readyToPlay {
                indicatorView.stopAnimating()
            }else{
                //indicatorView.stopAnimating()
            }
        }
    }
    
    /** toolView隐藏和显示 */
    func isShowBottomToolView(isShow: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.toolView.alpha = (isShow == true) ? 1 : 0
        }
        isShowToolView = isShow
        
        if isShowToolView == true {
            self.addShowTimer()  // 添加timer
        }else{
            self.removeShowTime() //移除timer
        }
    }
    
    /** 将toolView隐藏 */
    @objc func upDateToolView() {
        isShowToolView = !isShowToolView
        UIView.animate(withDuration: 0.5) {
            self.toolView.alpha = 0
        }
    }
    
    /** 更新slider和timeLabel */
    @objc func updateProgressInfo() {
        //视频当前的播放进度
        let currentTime = CMTimeGetSeconds(player.currentTime())
        //视频的总长度
        let durationTime = CMTimeGetSeconds(player.currentItem!.duration)
        timeLabel.text = self.timeToStringWithTimeInterval(interval: currentTime) as String
        allTimeLabel.text = self.timeToStringWithTimeInterval(interval: durationTime) as String
        
        progressSlider.value = Float(currentTime / durationTime)
        
        if progressSlider.value == 1 {
            progressTimer.fireDate = Date.distantFuture //暂停timer
            self.removeShowTime() //移除timer
            UIView.animate(withDuration: 0.5) { self.toolView.alpha = 1 } //播放完展示出来，按需求自己设置显示
            coverView.isHidden = false //播放完遮盖板展示出来，按需求显示
            print("播放完了")
        }
    }
    
    /** 转换播放时间和总时间的方法 */
    func timeToStringWithTimeInterval(interval: TimeInterval) -> NSString {
        let Min = interval / 60
        let Sec = interval.truncatingRemainder(dividingBy: 60)
        let intervalString = NSString.init(format: "%02.0f:%02.0f", Min,Sec)
        return intervalString as NSString
    }
    
    /** 弹出全屏播放器 */
    func videoplayViewSwitchOrientation(isFull: Bool) {
        if isFull == true {
            self.contrainerVC.present(self.fullVC, animated: false, completion: {
                self.fullVC.view.addSubview(self)
                self.center = self.fullVC.view.center
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .layoutSubviews, animations: {
                    self.frame = self.fullVC.view.bounds
                }, completion: nil)
            })
        }else{
            self.fullVC.dismiss(animated: false, completion: {
                
                /**
                 切记：contrainerVC是播放器所在的父视图，
                 如果播放器是添加在父视图中的某一个view中，
                 辣么这里需要再添加到contrainerVC里面的那个view中去。
                 
                 把： self.contrainerVC.view.addSubview(self)
                 改成： 父视图View.addSubview(self)
                 */
                self.contrainerVC.view.addSubview(self)
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .layoutSubviews, animations: {
                    self.frame = self.originalRect
                }, completion: nil)
            })
        }
    }
    
    /** 添加toolView显示计时，5s后隐藏toolView */
    func addShowTimer() {
        self.removeShowTime()
        showTime = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: {
            [weak self] (timer) in
            self?.upDateToolView()
        })
        RunLoop.main.add(showTime!, forMode: .commonModes)
    }

    /** 移除showTime定时器 */
    func removeShowTime() {
        showTime?.fireDate = Date.distantFuture //暂停timer
        //销毁定时器
        guard let aTimer = self.showTime
            else{ return }
        aTimer.invalidate()
    }
    
    /** 移除slider定时器 */
    func removeProgressTimer() {
        progressTimer.fireDate = Date.distantFuture //暂停timer
        //销毁定时器
        guard let aTimer = self.progressTimer
            else{ return }
        aTimer.invalidate()
    }
    
    /** 移除和销毁播放器 */
    func playerDealloc() {
        playerItem.removeObserver(self, forKeyPath: "status")
        //playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.removeShowTime()
        self.removeProgressTimer()
        player.pause()
        playerLayer.removeFromSuperlayer()
        self.removeFromSuperview()
    }
}



//MARK: init ui
extension CWPlayer {
    
    func viewLayout() {
        bgImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: self.height))
        bgImageView.backgroundColor = UIColor.gray
        //bgImageView.image = UIImage.init(named: "") //这里可以自己定义一张背景图
        bgImageView.isUserInteractionEnabled = true
        self.addSubview(bgImageView)
        
        //imageView添加手势
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:)))
        bgImageView.addGestureRecognizer(tap)
        
        toolView = UIView.init(frame: CGRect.init(x: 0, y: self.height-50, width: self.width, height: 50))
        toolView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        toolView.alpha = 0
        self.addSubview(toolView)
        
        isShowToolView = false // 设置工具栏状态
        
        playOrPauseBtn = UIButton.init(type: .custom)
        playOrPauseBtn.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        playOrPauseBtn.setImage(UIImage.init(named: "icon_play_btn"), for: .normal)
        playOrPauseBtn.setImage(UIImage.init(named: "icon_pause_btn"), for: .selected)
        playOrPauseBtn.isSelected = false
        playOrPauseBtn.addTarget(self, action: #selector(playOrPauseBtnClick(sender:)), for: .touchUpInside)
        toolView.addSubview(playOrPauseBtn)
        
        fullScreen = UIButton.init(type: .custom)
        fullScreen.frame = CGRect.init(x: toolView.width-50, y: 0, width: 50, height: 50)
        fullScreen.setImage(UIImage.init(named: "icon_launchFullScreen"), for: .normal)
        fullScreen.addTarget(self, action: #selector(fullViewBtnClick(sender:)), for: .touchUpInside)
        toolView.addSubview(fullScreen)
        
        timeLabel = UILabel.init(frame: CGRect.init(x: playOrPauseBtn.right, y: 0, width: 56, height: toolView.height))
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = UIColor.white
        timeLabel.text = "00:00"
        toolView.addSubview(timeLabel)
        
        allTimeLabel = UILabel.init(frame: CGRect.init(x: toolView.width-fullScreen.width-timeLabel.width, y: timeLabel.top, width: timeLabel.width, height: timeLabel.height))
        allTimeLabel.font = UIFont.systemFont(ofSize: 14)
        allTimeLabel.textColor = UIColor.gray
        allTimeLabel.textAlignment = .right
        allTimeLabel.text = "00:00"
        toolView.addSubview(allTimeLabel)
        
        progressSlider = UISlider.init(frame: CGRect.init(x: timeLabel.right, y: (toolView.height-20)/2, width: toolView.width-timeLabel.right-allTimeLabel.width-fullScreen.width, height: 20))
        progressSlider.setThumbImage(UIImage.init(named: "icon_thumbImage"), for: .normal)
        //设置滑块未划过部分的线条图案
        progressSlider.setMaximumTrackImage(UIImage.init(named: "icon_MaximumTrackImage"), for: .normal)
        //设置滑块划过部分的线条图案
        progressSlider.setMinimumTrackImage(UIImage.init(named: "icon_MinimumTrackImage"), for: .normal)
        progressSlider.addTarget(self, action: #selector(touchDownSlider(sender:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(valueChangedSlider(sender:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUpInside(sender:)), for: .touchUpInside)
        toolView.addSubview(progressSlider)
        
        playOrPauseBigBtn = UIButton.init(type: .custom)
        playOrPauseBigBtn.bounds = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        playOrPauseBigBtn.center = bgImageView.center
        playOrPauseBigBtn.setImage(UIImage.init(named: "icon_play"), for: .normal)
        playOrPauseBigBtn.addTarget(self, action: #selector(playOrPauseBigBtnClick(sender:)), for: .touchUpInside)
        self.addSubview(playOrPauseBigBtn)
        
        coverView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: self.height))
        coverView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        coverView.isHidden = true  // 隐藏遮盖版
        self.addSubview(coverView)
        
        replayBtn = UIButton.init(type: .custom)
        replayBtn.bounds = CGRect.init(x: 0, y: 0, width: 56, height: 56)
        replayBtn.center = coverView.center
        replayBtn.setTitle("重播", for: .normal)
        replayBtn.setTitleColor(UIColor.white, for: .normal)
        replayBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        replayBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        replayBtn.layer.cornerRadius = replayBtn.width/2
        replayBtn.layer.masksToBounds = true
        replayBtn.addTarget(self, action: #selector(repeatBtnClick(sender:)), for: .touchUpInside)
        coverView.addSubview(replayBtn)
        
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        indicatorView.bounds = replayBtn.bounds
        indicatorView.center = replayBtn.center
        indicatorView.hidesWhenStopped = true
        self.addSubview(indicatorView)
    }
    
    func initPlayerConfig() {
        // 初始化player 和 playerLayer
        player = AVPlayer.init()
        playerLayer = AVPlayerLayer.init(player: player)
        /***
         //设置视频的三种格式：
         /** 按原视频比例显示，是竖屏的就显示出竖屏的，显示不完的留黑边 **/
         AVLayerVideoGravity: resizeAspect
         /** 以原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分就被切割了 **/
         AVLayerVideoGravity: resizeAspectFill
         /** 不按原比例拉伸,拉伸视频内容达到边框占满 **/
         AVLayerVideoGravity: resize
         ***/
        playerLayer.videoGravity = .resize
        // imageView上添加playerLayer
        bgImageView.layer.addSublayer(playerLayer)
    }
}



//MARK: related click methods
extension CWPlayer {
    
    /** 背景点击事件 */
    @objc func tapAction(sender: UITapGestureRecognizer) {
        if player.status == .unknown {
            self.playOrPauseBigBtnClick(sender: playOrPauseBigBtn)
            return;
        }
        isShowToolView = !isShowToolView
        self.isShowBottomToolView(isShow: isShowToolView)
    }
    
    /** toolView上暂停按钮的点击事件 */
    @objc func playOrPauseBtnClick(sender: UIButton) {
        // 播放状态按钮selected为true,暂停状态selected为false
        sender.isSelected = !sender.isSelected
        
        self.addShowTimer()
        if sender.isSelected == false {
            player.pause()
            progressTimer.fireDate = Date.distantFuture //暂停timer
        }else{
            player.play()
            progressTimer.fireDate = Date.distantPast // 启动timer
        }
    }
    
    /** 全屏按钮点击事件 */
    @objc func fullViewBtnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.videoplayViewSwitchOrientation(isFull: sender.isSelected)
    }
    
    /** slider拖动和点击事件 */
    @objc func touchDownSlider(sender: UISlider) {
        indicatorView.startAnimating()
        progressTimer.fireDate = Date.distantFuture //暂停timer
        self.removeShowTime()
    }
    
    @objc func valueChangedSlider(sender: UISlider) {
        // 计算slider拖动的点对应的播放时间
        let currentTime = CMTimeGetSeconds((player.currentItem?.duration)!) * Double(sender.value)
        timeLabel.text = self.timeToStringWithTimeInterval(interval: currentTime) as String
    }
    
    @objc func sliderTouchUpInside(sender: UISlider) {
        progressTimer.fireDate = Date.distantPast // 启动timer
        //计算当前slider拖动对应的播放时间
        let currentTime = CMTimeGetSeconds((player.currentItem?.duration)!) * Double(sender.value)
        // 播放移动到当前播放时间
        self.player.seek(to: CMTimeMakeWithSeconds(currentTime, Int32(NSEC_PER_SEC)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) {
            [weak self] (isFinish) in
            self?.indicatorView.stopAnimating()
        }
        self.addShowTimer()   //添加timer
    }
    
    /** 中间播放按钮点击 */
    @objc func playOrPauseBigBtnClick(sender: UIButton) {
        sender.isHidden = true
        playOrPauseBtn.isSelected = true
        // 替换界面
        player.replaceCurrentItem(with: playerItem)
        player.play()
        indicatorView.startAnimating()
        progressTimer.fireDate = Date.distantPast // 启动timer
    }
    
    /** 重播按钮点击 */
    @objc func repeatBtnClick(sender: UIButton) {
        progressSlider.value = 0
        self.sliderTouchUpInside(sender: progressSlider)
        coverView.isHidden = true
        self.playOrPauseBigBtnClick(sender: playOrPauseBigBtn)
    }
}



//MARK: -->全屏播放控制器
class CCPlayerFullVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //当前viewcontroller是否支持转屏
    override var shouldAutorotate: Bool {
        return true
    }
    
    //当前viewcontroller支持哪些转屏方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.landscapeRight.rawValue | UIInterfaceOrientationMask.landscapeLeft.rawValue | UIInterfaceOrientationMask.portrait.rawValue))
    }
    
    //当前viewcontroller默认的屏幕方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


