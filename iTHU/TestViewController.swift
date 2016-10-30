//
//  TestViewController.swift
//  iTHU
//
//  Created by 果小橙 on 2016/10/22.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    var isOpened: Bool = false
    
    @IBOutlet weak var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/cn/app/pulse-secure/id945832041?mt=8")!)
        if !UIApplication.sharedApplication().canOpenURL(NSURL(string: "junospulse://")!) {
            btn.setTitle("下载", forState: .Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func press(sender: AnyObject) {
        if !UIApplication.sharedApplication().canOpenURL(NSURL(string: "junospulse://")!) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/cn/app/pulse-secure/id945832041?mt=8")!)
            return
        }
        if isOpened {
            btn.setTitle("打开", forState: .Normal)
            isOpened = !UIApplication.sharedApplication().openURL(NSURL(string: "junospulse://sslvpn.tsinghua.edu.cn?method=vpn&action=stop")!)
        }
        else
        {
            btn.setTitle("关闭", forState: .Normal)
            isOpened = UIApplication.sharedApplication().openURL(NSURL(string: "junospulse://sslvpn.tsinghua.edu.cn?method=vpn&username=2014011778&password=zxb3724650GC&action=start")!)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
