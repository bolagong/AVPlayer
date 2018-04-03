//
//  OneViewController.swift
//  CCPlayer
//
//  Created by chang on 2018/3/14.
//  Copyright © 2018年 chang. All rights reserved.
//

import UIKit

class OneViewController: UIViewController {

    var playView : CWPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.defaultBackgroundColor
        
        //记得设置plist文件的网络连接，不然请求不到 http哦
        let url = "http://120.25.226.186:32812/resources/videos/minion_02.mp4"
        
        playView = CWPlayer.init(frame: CGRect.init(x: 0, y: 100, width: MAINSCREEN_WIDTH, height: 200))
        playView.contrainerVC = self
        playView.urlString(url: url as NSString)
        self.view.addSubview(playView)
        
        let button = UIButton.init(type: .custom)
        button.frame = CGRect.init(x: 30, y: playView.bottom+50, width: MAINSCREEN_WIDTH-60, height: 50)
        button.backgroundColor = UIColor.defaultRedColor
        button.setTitle("点击返回（之后移除player）", for: .normal)
        button.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        self.view.addSubview(button)
    }

    @objc func backAction(sender: UIBarButtonItem) {
        playView.playerDealloc() //返回移除player
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
