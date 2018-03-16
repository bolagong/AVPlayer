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
        
        //设置plist文件，不然请求不到 http
        let url = "http://pgccdn.v.baidu.com/1389178559_958649323_20171022012537.mp4?authorization=bce-auth-v1%2Fc308a72e7b874edd9115e4614e1d62f6%2F2017-10-21T17%3A25%3A40Z%2F-1%2F%2F0949a7ae1d91d8790fc0f7445adbf67dbe0f2b276b61aaacf3a9b3212aa9f557&responseCacheControl=max-age%3D8640000&responseExpires=Tue%2C+30+Jan+2018+01%3A25%3A40+GMT&xcode=3507ae025d676e53692c9296264ed660826bde1385195bc1"
        
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
