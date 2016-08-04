//
//  RootViewController.swift
//  iTHU
//
//  Created by 果小橙 on 16/7/30.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import ChameleonFramework

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor(red: 0.23, green: 0.55, blue: 0.92, alpha: 1.0)
        
//        let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
//        let navigationController = InfoViewController(rootViewController: pageController)
//        self.setViewControllers([navigationController], animated: true)

        // Do any additional setup after loading the view.
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
