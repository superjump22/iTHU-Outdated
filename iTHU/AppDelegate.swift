//
//  AppDelegate.swift
//  iTHU
//
//  Created by 果小橙 on 16/7/29.
//  Copyright © 2016年 THU_GC. All rights reserved.
//

import UIKit
import RealmSwift

let loginLearnUrl = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/teacher/loginteacher.jsp"
let loginInfoUrl = "http://info.tsinghua.edu.cn/Login"
let fullCourseListUrl = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/MyCourse.jsp?typepage=3"
let thisCourseLidtUrl = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/MyCourse.jsp?typepage=1"
let courseLidtUrl = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/MyCourse.jsp?typepage=||typepage||"
var bbsUrl: String = "http://learn.tsinghua.edu.cn/MultiLanguage/public/bbs/note_reply.jsp?bbs_type=课程公告&id=||BBSID||&course_id=||COURSEID||"
var hwkUrl: String = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/hom_wk_detail.jsp?id=||HWKID||&course_id=||COURSEID||"
let bbsListUrl: String = "http://learn.tsinghua.edu.cn/MultiLanguage/public/bbs/getnoteid_student.jsp?course_id=||COURSEID||"
var hwkListUrl: String = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/hom_wk_brw.jsp?course_id=||COURSEID||"
var fileListUrl: String = "http://learn.tsinghua.edu.cn/MultiLanguage/lesson/student/download.jsp?course_id=||COURSEID||"
var flag: Bool = true
var rowsCount = 0
var courseStrList: [String] = []
var year: [String] = []
let SEMESTER: [String] = ["夏季学期","春季学期","秋季学期"]

var configDefault = Realm.Configuration()
var config = Realm.Configuration()
var userNow: String = ""
var userNowPass: String = ""
var firstFlag = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Use the default directory, but replace the filename with the username
        configDefault.fileURL = configDefault.fileURL!.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("default.realm")
        Realm.Configuration.defaultConfiguration = configDefault
        let realm = try! Realm()
        let users = realm.objects(User)
        if users.count == 0 {
            firstFlag = true
        } else {
            let loginUsers = users.filter("login == true")
            if loginUsers.count == 1 {
                userNow = loginUsers[0].id
                userNowPass = loginUsers[0].pass
                config.fileURL = config.fileURL!.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("\(userNow).realm")
                Realm.Configuration.defaultConfiguration = config
            } else if loginUsers.count > 1 {
                try! realm.write
                    {
                        loginUsers.setValue(false, forKey: "login")
                }
                firstFlag = true
            } else {
                firstFlag = true
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // debug
        let realm = try! Realm(configuration: configDefault)
        let users = realm.objects(User)
        let loginUsers = users.filter("login == true")
        try! realm.write
            {
                loginUsers.setValue(false, forKey: "login")
        }
        //debug
    }


}

