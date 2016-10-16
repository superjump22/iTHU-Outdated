//
//  InfoViewController.swift
//  iTHU
//
//  Created by 果小橙 on 16/8/5.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import Alamofire

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let formData =
            [
                "userid": "2014011778", "userpass": "zxb3724650GC", "submit1": "登录"
        ]
        Alamofire.request("http://info.tsinghua.edu.cn/Login", method: .post, parameters: formData).validate().responseString
            {
                response in
        }
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
