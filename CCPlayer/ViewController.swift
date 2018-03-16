//
//  ViewController.swift
//  CCPlayer
//
//  Created by chang on 2018/3/14.
//  Copyright © 2018年 chang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.defaultBackgroundColor
        
        let button = UIButton.init(type: .custom)
        button.frame = CGRect.init(x: 30, y: 150, width: MAINSCREEN_WIDTH-60, height: 50)
        button.backgroundColor = UIColor.defaultRedColor
        button.setTitle("点击跳转", for: .normal)
        button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        self.view.addSubview(button)
    }

    @objc func buttonClick(sender: UIButton) {
        let oneVC = OneViewController.init()
        self.present(oneVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

